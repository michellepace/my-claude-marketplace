#!/usr/bin/env bash
# diagnose.sh — five behavioural signals to localise where a run blew out.
#
# Usage: diagnose.sh <session-path>
#   <session-path> = directory under ~/.claude/projects/<proj>/ holding subagents/ + sibling <id>.jsonl
# Example: ./diagnose.sh <session-path> > experiment-NN/runK-rootcause.txt

set -eu

case "${1:-}" in
  -h | --help)
    cat <<'EOF'
diagnose.sh — five behavioural signals to localise where a run blew out.
Run after cost_report.py flags a regression.

Usage: diagnose.sh <session-path>
  <session-path>  Reads <session-path>.jsonl and <session-path>/subagents/.
                  A trailing '.jsonl' is tolerated.

Emits §1–§5 (per-subagent tool counts; top-10 tool_result payloads with
next-turn bucket fate; orchestrator output histogram; first-user-message
sizes; orchestrator tool counts). Run the script to see each block's `#`
header lines — they document columns and methodology.

Example: ./diagnose.sh <session-path> > experiment-NN/runK-rootcause.txt
EOF
    exit 0
    ;;
esac

if [ $# -ne 1 ]; then
  echo "Usage: $0 <session-path>" >&2
  echo "       <session-path> is the full path to the session directory (no .jsonl extension)." >&2
  echo "       Run '$0 --help' for output-block descriptions." >&2
  exit 1
fi

SESSION_PATH="$1"
SESSION_PATH="${SESSION_PATH%/}"      # strip trailing slash
SESSION_PATH="${SESSION_PATH%.jsonl}" # tolerate .jsonl suffix if user passes the file
ORCH="${SESSION_PATH}.jsonl"
SUBDIR="${SESSION_PATH}/subagents"
SESSION_ID="$(basename "$SESSION_PATH")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$ORCH" ]; then
  echo "error: orchestrator transcript not found: $ORCH" >&2
  exit 2
fi
if [ ! -d "$SUBDIR" ]; then
  echo "error: subagents directory not found: $SUBDIR" >&2
  exit 2
fi

# Single trap for all temp files used across sections (multiple traps overwrite).
ENRICHED=$(mktemp)
TOP=$(mktemp)
ROWS_TSV=$(mktemp)
PRICE_OUT=$(mktemp)
trap 'rm -f "$ENRICHED" "$TOP" "$ROWS_TSV" "$PRICE_OUT"' EXIT

# Helper: extract plain text from a content field that may be a string or
# an array of {type,text,...} blocks. Used for tool_result and user messages.
TEXT_OF='if type == "string" then . else (map(.text // "") | join("")) end'

echo "== §1 Per-subagent tool-call counts [$SESSION_ID] =="
echo "# tool_use blocks per subagent; what each subagent actually did. NO dedup."
printf "# agent-id\tdescription\ttool-counts(descending)\n"
for f in "$SUBDIR"/agent-*.jsonl; do
  name=$(basename "$f" .jsonl)
  desc=$(jq -r '.description // "(description absent)"' "${f%.jsonl}.meta.json" 2>/dev/null || echo "")
  counts=$(jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="tool_use") | .name' "$f" \
    | sort | uniq -c | sort -rn | awk '{printf "%dx%s ", $1, $2}' | sed 's/ $//')
  printf "%s\t%s\t%s\n" "$name" "$desc" "$counts"
done

echo ""
echo "== §2 Top-10 largest tool_result payloads, orchestrator + subagents [$SESSION_ID] =="
echo "# single tool returns ranked by payload size; next_* columns show which bucket the payload landed in on the immediately following assistant turn (skipping sibling shards of the same message.id) — only next_create_* rows cost real money, next_read is ~free."
printf "# size_chars\tsrc_file\ttool_name\ttimestamp\tnext_create_5m\tnext_create_1h\tnext_read\tnext_usd\n"

# Per-file: emit one JSON line per tool_result, enriched with next-turn lookup.
# Forward-scan algorithm (in JSONL order): for each tool_result at row k,
#   next-turn = first row at position > k with type=="assistant" && message.id != emitter_msg_id.
# Naive parentUuid matching breaks for parallel-tool turns where N shards share one message.id.
: >"$ENRICHED"
for f in "$ORCH" "$SUBDIR"/agent-*.jsonl; do
  src=$(basename "$f")
  jq -cs --arg src "$src" '
    . as $rows |
    # Index every tool_use.id -> {emitter message.id, tool name}
    (reduce ($rows[] | select(.type == "assistant") | .message.id as $mid |
             (.message.content // [])[] | select(.type == "tool_use") |
             {id, mid: $mid, name}) as $e
     ({}; .[$e.id] = {mid: $e.mid, name: $e.name})) as $idx |
    ($rows | to_entries[]) |
    .key as $k | .value as $row |
    select($row.type == "user" and ($row.message.content | type == "array")) |
    $row.message.content[] | select(.type == "tool_result") |
    . as $tr |
    ($idx[$tr.tool_use_id].mid // null)  as $eid |
    ($idx[$tr.tool_use_id].name // "?")  as $tn |
    ($rows[($k + 1):] |
       map(select(.type == "assistant" and .message.id and .message.id != $eid)) |
       first) as $nxt |
    {
      size: (($tr.content | if type == "string" then . else (map(.text // "") | join("")) end) | length),
      src: $src,
      tool_name: $tn,
      ts: $row.timestamp,
      next_5m: ($nxt.message.usage.cache_creation.ephemeral_5m_input_tokens // 0),
      next_1h: ($nxt.message.usage.cache_creation.ephemeral_1h_input_tokens // 0),
      next_read: ($nxt.message.usage.cache_read_input_tokens // 0),
      next_model: ($nxt.message.model // null),
      next_usage: ($nxt.message.usage // null)
    }
  ' "$f" >>"$ENRICHED"
done

# Sort by payload size, take top 10.
jq -cs 'sort_by(-.size) | .[0:10][]' "$ENRICHED" >"$TOP"

# Emit TSV with sentinel for next_usd (PRICE_NULL when no next turn; PRICE_TBD otherwise).
jq -r '
  if .next_model == null then
    [.size, .src, .tool_name, .ts, "-", "-", "-", "PRICE_NULL"] | @tsv
  else
    [.size, .src, .tool_name, .ts, .next_5m, .next_1h, .next_read, "PRICE_TBD"] | @tsv
  end
' "$TOP" >"$ROWS_TSV"

# Single subprocess pricing for non-null rows; preserves order.
jq -c 'select(.next_model != null) | {model: .next_model, usage: .next_usage}' "$TOP" \
  | uv run "$SCRIPT_DIR/cost_report.py" --price-stdin >"$PRICE_OUT"

# Substitute PRICE_TBD sentinels with priced values; PRICE_NULL becomes "-".
awk -v prices_file="$PRICE_OUT" '
  BEGIN {
    FS = OFS = "\t"
    n = 0
    while ((getline line < prices_file) > 0) { p[n++] = line }
    close(prices_file)
    pi = 0
  }
  {
    if ($8 == "PRICE_NULL") { $8 = "-" }
    else if ($8 == "PRICE_TBD") { $8 = p[pi++] }
    print
  }
' "$ROWS_TSV"

echo ""
echo "== §3 Orchestrator per-turn output histogram [$SESSION_ID] =="
echo "# turns by output_tokens (descending); DEDUPED by message.id (parallel-shard rows collapse to one). Contrast §5 (no dedup)."
printf "# output\ttimestamp\ttools_in_turn\n"
jq -rs 'map(select(.type=="assistant" and .message.usage)) |
  group_by(.message.id) |
  map({
    ts: (map(.timestamp) | min),
    output: .[0].message.usage.output_tokens,
    tools: ([.[] | .message.content[]? | select(.type=="tool_use") | .name] | join(","))
  }) |
  sort_by(-.output) |
  .[] | [.output, .ts, .tools] | @tsv' "$ORCH"

echo ""
echo "== §4 First user message size per subagent (spawn prompt) [$SESSION_ID] =="
echo "# spawn-prompt size; flags front-loaded context."
printf "# size_chars\tagent-id\tdescription\n"
for f in "$SUBDIR"/agent-*.jsonl; do
  name=$(basename "$f" .jsonl)
  desc=$(jq -r '.description // "(description absent)"' "${f%.jsonl}.meta.json" 2>/dev/null || echo "")
  size=$(jq -s "([.[] | select(.type==\"user\")] | .[0]?) as \$first | \
    ((\$first.message.content // \"\") | $TEXT_OF) | length" "$f")
  printf "%s\t%s\t%s\n" "${size:-0}" "$name" "$desc"
done | sort -rn -k1,1

echo ""
echo "== §5 Orchestrator tool-call counts [$SESSION_ID] =="
echo "# tool_use blocks per tool name; NO dedup (parallel-shard rows are distinct tool_use blocks)."
printf "# tool-name\ttool_use_count\n"
jq -r 'select(.message.content) | .message.content[]? | select(.type=="tool_use") | .name' \
  "$ORCH" | sort | uniq -c | sort -rn | awk '{printf "%s\t%s\n", $2, $1}'
