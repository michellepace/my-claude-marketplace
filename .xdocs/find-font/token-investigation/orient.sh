#!/usr/bin/env bash
# orient.sh — orientation metrics for one Claude Code session (orchestrator + subagents).
#
# Usage: orient.sh <session-path>
#   <session-path> = directory under ~/.claude/projects/<proj>/ holding subagents/ + sibling <id>.jsonl
# Example: ./orient.sh <session-path> > experiment-NN/runK-orientation.txt

set -eu

case "${1:-}" in
  -h | --help)
    cat <<'EOF'
orient.sh — orientation metrics for one Claude Code session.

Usage: orient.sh <session-path>
  <session-path>  Reads <session-path>.jsonl and <session-path>/subagents/.
                  A trailing '.jsonl' is tolerated.

Emits four blocks (Peak CTX, Per-subagent rollup, Wall-clock duration,
Orchestrator tool-call counts). Run the script to see each block's `#` header
lines — they document columns and methodology.

Example: ./orient.sh <session-path> > experiment-NN/runK-orientation.txt
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
SESSION_PATH="${SESSION_PATH%/}"
SESSION_PATH="${SESSION_PATH%.jsonl}"
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
ROLLUP_TMP=$(mktemp)
PRICE_IN=$(mktemp)
PRICE_FI=$(mktemp)
PRICE_OUT=$(mktemp)
USD_BY_FI=$(mktemp)
TS_FILE=$(mktemp)
trap 'rm -f "$ROLLUP_TMP" "$PRICE_IN" "$PRICE_FI" "$PRICE_OUT" "$USD_BY_FI" "$TS_FILE"' EXIT

echo ""
echo "== Run-wide Peak CTX [$SESSION_ID] =="
echo "# max per-turn input window (input_tokens+cache_create_5m+cache_create_1h+cache_read) vs 200k - context-pressure, not cost."
cat "$ORCH" "$SUBDIR"/agent-*.jsonl |
  jq -r 'select(.message.usage) | .message.usage |
    (.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens)' |
  sort -n | tail -1

echo ""
echo "== Per-subagent rollup [$SESSION_ID] =="
printf "# peak = max per-turn; total = sum across turns (deduped); cache_read_%% and usd derived from priced per-bucket sums (cost_report.py --price-stdin); usd sums across all models present per file\n"
printf "# spawn-ts\tpeak-ctx\ttotal-tokens(deduped)\tcache_read_%%\tusd\tdescription\n"

# Pass 1: per-file rollup with sentinel for usd; emit per-(file,model) usage to PRICE_IN.
: >"$ROLLUP_TMP"
: >"$PRICE_IN"
file_idx=0
for f in "$SUBDIR"/agent-*.jsonl; do
  ts=$(jq -r 'select(.timestamp) | .timestamp' "$f" | sort | head -1)
  desc=$(jq -r '.description // "(description absent)"' "${f%.jsonl}.meta.json")
  peak=$(jq -r 'select(.message.usage) | .message.usage |
    (.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens)' "$f" | sort -n | tail -1)
  total=$(jq -s 'map(select(.message.usage and .message.id)) | unique_by(.message.id)
    | [.[] | .message.usage |
       (.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens + .output_tokens)] | add // 0' "$f")
  cread=$(jq -s 'map(select(.message.usage and .message.id)) | unique_by(.message.id)
    | [.[] | .message.usage.cache_read_input_tokens // 0] | add // 0' "$f")

  # Emit one {fi, model, usage} JSONL line per (file, model) pair — group dedup by msg.id then by model.
  jq -cs --argjson 'fi' "$file_idx" '
    map(select(.type == "assistant" and .message.usage and .message.id and .message.model)) |
    unique_by(.message.id) |
    group_by(.message.model) |
    map({
      fi: $fi,
      model: .[0].message.model,
      usage: {
        input_tokens: ([.[] | .message.usage.input_tokens // 0] | add),
        cache_creation: {
          ephemeral_5m_input_tokens: ([.[] | .message.usage.cache_creation.ephemeral_5m_input_tokens // 0] | add),
          ephemeral_1h_input_tokens: ([.[] | .message.usage.cache_creation.ephemeral_1h_input_tokens // 0] | add)
        },
        cache_read_input_tokens: ([.[] | .message.usage.cache_read_input_tokens // 0] | add),
        output_tokens: ([.[] | .message.usage.output_tokens // 0] | add)
      }
    }) | .[]
  ' "$f" >>"$PRICE_IN"

  if [ "${total:-0}" = "0" ] || [ -z "$total" ]; then
    pct="0.0"
  else
    pct=$(awk -v c="${cread:-0}" -v t="$total" 'BEGIN { printf "%.1f", (c/t)*100 }')
  fi

  printf "%d\t%s\t%s\t%s\t%s\t__USD_%d__\t%s\n" "$file_idx" "$ts" "$peak" "$total" "$pct" "$file_idx" "$desc" >>"$ROLLUP_TMP"
  file_idx=$((file_idx + 1))
done

# Pass 2: single subprocess prices all (file, model) pairs; preserves order.
jq -r '.fi' "$PRICE_IN" >"$PRICE_FI"
jq -c 'del(.fi)' "$PRICE_IN" |
  uv run "$SCRIPT_DIR/cost_report.py" --price-stdin >"$PRICE_OUT"
paste "$PRICE_FI" "$PRICE_OUT" |
  awk -F'\t' '{ sums[$1] += $2 } END { for (k in sums) printf "%s\t%.4f\n", k, sums[k] }' \
    >"$USD_BY_FI"

# Pass 3: substitute __USD_<fi>__ markers with summed $; strip leading fi column; sort by spawn-ts.
awk -v usd_file="$USD_BY_FI" '
  BEGIN {
    FS = "\t"
    while ((getline line < usd_file) > 0) {
      split(line, a, "\t")
      usd[a[1]] = a[2]
    }
    close(usd_file)
  }
  {
    fi = $1
    rest = substr($0, length(fi) + 2)
    gsub("__USD_" fi "__", (fi in usd ? usd[fi] : "0.0000"), rest)
    print rest
  }
' "$ROLLUP_TMP" | sort

echo ""
echo "== Wall-clock duration [$SESSION_ID] =="
echo "# first/last .timestamp across orchestrator + subagents."
{
  jq -r 'select(.timestamp) | .timestamp' "$ORCH"
  for f in "$SUBDIR"/agent-*.jsonl; do
    jq -r 'select(.timestamp) | .timestamp' "$f"
  done
} | sort >"$TS_FILE"

first=$(head -1 "$TS_FILE")
last=$(tail -1 "$TS_FILE")
elapsed=$(($(date -u -d "$last" +%s) - $(date -u -d "$first" +%s)))

# Single awk pass: emit one "GAP\t<seconds>\t<prev>\t<next>" line per gap >50s,
# plus a final "SUM\t<idle_total>\t<gap_count>" line. Threshold tuned for
# find-font: observed max intra-skill orchestrator gap is ~33s (end-of-skill
# consolidation); >50s reliably indicates user idle (e.g. /context post-skill).
awk_out=$(awk '
  { cmd="date -u -d \""$0"\" +%s"; cmd|getline e; close(cmd);
    if (p && e-p>50) { printf "GAP\t%d\t%s\t%s\n", e-p, pt, $0; idle += e-p; n++ }
    p=e; pt=$0 }
  END { printf "SUM\t%d\t%d\n", idle+0, n+0 }
' "$TS_FILE")
idle=$(echo "$awk_out" | awk -F'\t' '/^SUM/ {print $2}')
n_gaps=$(echo "$awk_out" | awk -F'\t' '/^SUM/ {print $3}')
active=$((elapsed - idle))

echo "first:    $first"
echo "last:     $last"
echo "elapsed:  ${elapsed}s"
if [ "$n_gaps" -eq 0 ]; then
  echo "idle:     0s"
elif [ "$n_gaps" -eq 1 ]; then
  echo "idle:     ${idle}s   (1 gap >50s)"
else
  echo "idle:     ${idle}s   ($n_gaps gaps >50s)"
fi
echo "active:   ${active}s"
if [ "$n_gaps" -gt 0 ]; then
  echo "-- idle gaps (>50s) --"
  echo "$awk_out" | awk -F'\t' '/^GAP/ { printf "%ds   %s -> %s\n", $2, $3, $4 }'
fi

echo ""
echo "== Orchestrator tool-call counts [$SESSION_ID] =="
echo "# tool_use blocks per tool name; NO dedup (parallel-shard rows are distinct tool_use blocks)."
printf "# tool-name\ttool_use_count\n"
jq -r 'select(.message.content) | .message.content[]? | select(.type=="tool_use") | .name' \
  "$ORCH" | sort | uniq -c | sort -rn | awk '{printf "%s\t%s\n", $2, $1}'
