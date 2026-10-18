#!/usr/bin/env bash
# Validate the marketplace and every plugin, failing on any error or warning
# except a missing `version` or `author`, which this marketplace leaves out.
set -u
cd "$(dirname "$0")/.." || exit # repo root, so paths below resolve from anywhere

# shellcheck disable=SC2016  # $file and $root are jq variables
filter='input | (.manifest // empty), .contents[]
  | .file as $file
  | .errors[], (.warnings[] | select(.path | test("(^|→ )(version|author)$") | not))
  | "\($file | ltrimstr($root)): \(.path): \(.message)"'

failed=0
for target in . plugins/*/; do
  if ! problems=$(claude plugin validate "$target" --json | jq -nr --arg root "$PWD/" "$filter"); then
    problems="$target: no report from claude plugin validate"
  fi
  if [[ -n $problems ]]; then
    echo "$problems"
    failed=1
  fi
done
exit "$failed"
