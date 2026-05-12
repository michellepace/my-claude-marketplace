#!/usr/bin/env bash
set -euo pipefail

OUTPUT_TSV="peak-ctx.tsv"

usage() {
  cat << 'EOF'
Usage: peak-ctx.sh [OPTION]

Scans Claude Code session files (~/.claude/projects/*/*.jsonl) across ALL
projects on this machine and writes peak-ctx.tsv to the current working
directory (one row per session, sorted by last_modified descending).

Peak CTX is the largest context-window size reached during a session,
computed as:
    max(input_tokens + cache_creation_input_tokens + cache_read_input_tokens)
across every message.usage entry in the session (output tokens are excluded;
they reappear as input on the next turn). This matches the value shown
by Claude Code's /context command for that session.

Window options (mutually exclusive):
  --all              Scan every session (no date filter).
  --today            Sessions modified today (alias for --last-days 1).
  --last-days N      Sessions modified in the last N calendar days
                     (today + previous N-1 days), local timezone. N >= 1.

Default window: last 7 days.

Other options:
  --pretty           After writing peak-ctx.tsv, also print it as a
                     human-readable table to stdout. Combine with any
                     window flag (e.g. --last-days 3 --pretty).
  --help             Show this help.

Output: peak-ctx.tsv (5 tab-separated columns)
  last_modified       File mtime, local timezone (YYYY-MM-DDTHH:MM).
  main_session_start  Earliest message timestamp in the session, UTC ISO-8601.
  peak_ctx            Peak context tokens (see formula above). Sessions where
                      this is 0 (no message.usage records) are always excluded.
  session_file        Absolute path to the .jsonl session file.
  title_custom_ai     User-set custom title; falls back to AI-generated
                      title; "(no title)" if neither exists.
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

# --- arg parsing ---

mode=days
days=7
window_flag=""
saw_pretty=0

while (($# > 0)); do
  case "$1" in
    --help)
      usage
      exit 0
      ;;
    --all)
      [[ -n $window_flag ]] && die "--all conflicts with $window_flag"
      window_flag=--all
      mode=all
      shift
      ;;
    --today)
      [[ -n $window_flag ]] && die "--today conflicts with $window_flag"
      window_flag=--today
      days=1
      shift
      ;;
    --last-days)
      [[ -n $window_flag ]] && die "--last-days conflicts with $window_flag"
      window_flag=--last-days
      [[ $# -ge 2 ]] || die "--last-days requires N"
      days=$2
      [[ $days =~ ^[0-9]+$ ]] || die "N must be an integer"
      ((days >= 1)) || die "N must be >= 1"
      shift 2
      ;;
    --pretty)
      saw_pretty=1
      shift
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

# --- pretty-table renderer ---

prettify() {
  awk -F'\t' -v OFS='\t' '
    function commafy(n,   s, r, i) {
      s = sprintf("%d", n)
      r = ""
      i = length(s)
      while (i > 3) {
        r = "," substr(s, i - 2, 3) r
        i -= 3
      }
      return substr(s, 1, i) r
    }
    NR == 1 {
      print "last_modified", "peak_ctx", "title_custom_ai", "project", "session_id"
      next
    }
    {
      n = split($4, parts, "/")
      project = parts[n - 1]
      sub(/^-/, "", project)
      session_id = parts[n]
      sub(/\.jsonl$/, "", session_id)
      title = ($5 == "(no title)") ? "" : $5
      if (length(title) > 40) title = substr(title, 1, 39) "…"
      print $1, commafy($3), title, project, session_id
    }
  ' "$1" | column -t -s "$(printf '\t')" -R 2
}

# --- threshold epoch ---

threshold_epoch=""
if [[ $mode == days ]]; then
  threshold_epoch=$(date -d "$((days - 1)) days ago 00:00:00" +%s 2> /dev/null ||
    date -v-$((days - 1))d -v0H -v0M -v0S +%s)
fi

# --- find session files ---

projects_dir="$HOME/.claude/projects"
[[ -d $projects_dir ]] || die "$projects_dir does not exist"

ref=""
cleanup() {
  [[ -n $ref ]] && rm -f "$ref"
}
trap cleanup EXIT

if [[ -n $threshold_epoch ]]; then
  ref=$(mktemp)
  ts=$(date -r "$threshold_epoch" +%Y%m%d%H%M.%S 2> /dev/null ||
    date -d "@$threshold_epoch" +%Y%m%d%H%M.%S)
  touch -t "$ts" "$ref"
  mapfile -t files < <(find "$projects_dir" -mindepth 2 -maxdepth 2 -name '*.jsonl' -newer "$ref")
else
  mapfile -t files < <(find "$projects_dir" -mindepth 2 -maxdepth 2 -name '*.jsonl')
fi

# --- extract row per session ---

extract_row() {
  local file=$1
  local epoch last_modified main_session_start peak_ctx title

  epoch=$(stat -c %Y "$file" 2> /dev/null || stat -f %m "$file")
  last_modified=$(date -d "@$epoch" "+%Y-%m-%dT%H:%M" 2> /dev/null ||
    date -r "$epoch" "+%Y-%m-%dT%H:%M")

  main_session_start=$(jq -rs '[.[] | .timestamp // empty] | min // empty' "$file")

  peak_ctx=$(jq -r 'select(.message.usage) | .message.usage |
    (.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens)' "$file" |
    sort -n | tail -1)
  [[ -z $peak_ctx ]] && peak_ctx=0

  title=$(jq -rs '
    def nonblank: select(. != null and (tostring | test("^\\s*$") | not));
    (map(select(.type=="custom-title") | .customTitle | nonblank) | .[-1]) //
    (map(select(.type=="ai-title")     | .aiTitle     | nonblank) | .[-1]) //
    "(no title)"
  ' "$file")

  printf '%s\t%s\t%s\t%s\t%s\n' "$last_modified" "$main_session_start" "$peak_ctx" "$file" "$title"
}

# --- write TSV ---

{
  printf 'last_modified\tmain_session_start\tpeak_ctx\tsession_file\ttitle_custom_ai\n'
  if ((${#files[@]} > 0)); then
    for f in "${files[@]}"; do
      [[ -n $f ]] && extract_row "$f"
    done | sort -t "$(printf '\t')" -k1,1r
  fi
} > "$OUTPUT_TSV"

# strip abandoned/empty sessions (peak_ctx == 0 means no usage records)
awk -F'\t' 'NR == 1 || $3 != "0"' "$OUTPUT_TSV" > "${OUTPUT_TSV}.tmp" &&
  mv "${OUTPUT_TSV}.tmp" "$OUTPUT_TSV"

n_rows=$(($(wc -l < "$OUTPUT_TSV") - 1))

if [[ $mode == all ]]; then
  window_label="All sessions"
elif ((days == 1)); then
  window_label="Last 1 day"
else
  window_label="Last $days days"
fi

# --- output ---

echo "✅ Created \"peak-ctx.tsv\" · $window_label · $n_rows sessions (empty excluded)"
echo "🌸 Run \"peak-ctx.sh --pretty\" for a pretty format"

if ((saw_pretty == 1)); then
  table=$(prettify "$OUTPUT_TSV")
  rule_width=$(echo "$table" | wc -L)
  printf -v rule '%*s' "$rule_width" ""
  rule=${rule// /─}

  echo
  echo "$rule"
  echo " 📊 Peak Context (like \"/context\") · $window_label · $n_rows sessions"
  echo "$rule"
  echo "$table"
fi
