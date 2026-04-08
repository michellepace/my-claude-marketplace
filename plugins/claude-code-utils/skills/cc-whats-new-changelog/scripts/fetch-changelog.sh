#!/usr/bin/env bash
set -euo pipefail

# Parse arguments
LATEST_N=8
while [[ $# -gt 0 ]]; do
  case "$1" in
    --latest-n) LATEST_N="$2"; shift 2 ;;
    *) echo "Usage: $0 [--latest-n N]" >&2; exit 1 ;;
  esac
done

# Output files in current working directory
CHANGELOG_FULL="x_cc-changelog-full.md"
CHANGELOG_INDEX="x_cc-changelog-index.csv"

# Fetch full changelog (v2.1.0+, 2026+)
curl -s https://raw.githubusercontent.com/anthropics/claude-code/refs/heads/main/CHANGELOG.md \
  | awk 'BEGIN{p=1} /^## 2\.0\./{p=0} /^## [01]\./{p=0} p' > "$CHANGELOG_FULL"
CHANGELOG=$(cat "$CHANGELOG_FULL")
echo "✅ Full changelog created (v2.1.0+, 2026+): $CHANGELOG_FULL"

# Build changelog index with item counts (v2.1.0+, 2026+)
CHANGELOG_COUNTS=$(echo "$CHANGELOG" | awk '/^## /{if(v)print v","c;v=$2;c=0}/^- /{c++}END{print v","c}')
echo "version,npm_release_date,changelog_items (0=npm-only)" > "$CHANGELOG_INDEX"
npm view @anthropic-ai/claude-code time \
  | grep -E "^ *'[0-9]+\.[0-9]+\.[0-9]+" \
  | grep -vE "'([01]\.|2\.0\.)" \
  | awk '{a[NR]=$0}END{for(i=NR;i>=1;i--)print a[i]}' \
  | sed "s/T.*Z'//" \
  | tr -d "':," \
  | column -t \
  | while read -r ver date; do
      items=$(echo "$CHANGELOG_COUNTS" | grep "^$ver," | cut -d',' -f2 || true)
      echo "$ver,$date,${items:-0}"
    done >> "$CHANGELOG_INDEX"
echo "✅ Changelog index created (v2.1.0+, 2026+): $CHANGELOG_INDEX"

# Latest versions (0 changelog items = npm-only)
echo ""
echo "<latest_version_summary>"
echo ""
echo "=== Version Stats ==="
echo "<version_stats>"
echo "total_versions=$(( $(wc -l < "$CHANGELOG_INDEX") - 1 ))"
echo "latest=$(sed -n '2p' "$CHANGELOG_INDEX" | cut -d',' -f1)"
echo "earliest=$(tail -1 "$CHANGELOG_INDEX" | cut -d',' -f1)"
echo "earliest_date=$(tail -1 "$CHANGELOG_INDEX" | cut -d',' -f2 | awk -F- '{split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec",m," "); printf "%s %s\n",m[$2+0],$1}')"
echo "</version_stats>"
echo ""
echo "=== Latest Versions ==="
echo "<latest_versions>"
head -$((LATEST_N + 1)) "$CHANGELOG_INDEX"
echo "</latest_versions>"
echo ""
echo "=== Latest Changelog Entries ==="
echo "<latest_changelog_entries>"
echo "$CHANGELOG" | awk -v n="$LATEST_N" '/^## [0-9]/{count++} count<=n'
echo "</latest_changelog_entries>"
echo ""
echo "</latest_version_summary>"
