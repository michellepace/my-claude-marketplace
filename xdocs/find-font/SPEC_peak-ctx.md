<!-- markdownlint-disable-file MD010 -->
# TASK: Create a `peak-ctx.sh` script

Keep it simple and elegant, do not over engineer.

## Input

Source: `~/.claude/projects/*/*.jsonl` — one level only. Don't recurse; nested `<uuid>/` subdirs hold `subagents/` and `tool-results/`, not sessions.

Each `.jsonl` is a single Claude Code session (one JSON record per line). Roughly a third of files have no title records — the script falls through to `(no title)` for these (see `title_custom_ai` below).

## Output

Writes `peak-ctx.tsv` to the current working directory (overwrites). Header row + one row per session, sorted descending by `last_modified` — the same field used for date filtering (see "Date filtering").

```tsv
last_modified	main_session_start	peak_ctx	session_file	title_custom_ai
2026-05-10T05:03	2026-05-09T21:00:35.211Z	43501	/home/mp/.claude/projects/-home-mp-projects-my-claude-marketplace/ac3b926e-d299-40f4-a796-6e155fa77644.jsonl	Horses, with commas, again.
```

## Field definitions

For each session file `$file`, derive one row:

### `last_modified`

File mtime, formatted `YYYY-MM-DDTHH:MM` in the runner's local timezone. Resuming an old session bumps mtime, so resumed sessions surface in recent windows (intended).

```bash
# Portable: GNU stat/date vs BSD stat/date.
epoch=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file")
last_modified=$(date -d "@$epoch" "+%Y-%m-%dT%H:%M" 2>/dev/null \
              || date -r "$epoch" "+%Y-%m-%dT%H:%M")
```

### `main_session_start`

Earliest `.timestamp` in the file, carried verbatim (ISO-8601 Z-suffixed UTC).

```bash
main_session_start=$(jq -rs '[.[] | .timestamp // empty] | min // empty' "$file")
```

### `peak_ctx`

Max per-turn input window across all assistant turns. For each record where `.message.usage` exists (assistant turns only), sum `input_tokens + cache_creation_input_tokens + cache_read_input_tokens`; take the file-wide max.

```bash
peak_ctx=$(jq -r 'select(.message.usage) | .message.usage |
  (.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens)' "$file" |
  sort -n | tail -1)
```

### `session_file`

Absolute path to the `.jsonl`.

### `title_custom_ai`

First non-empty of:
1. Last `.customTitle` from `type:"custom-title"` records (renames append; latest wins).
2. Last `.aiTitle` from `type:"ai-title"` records.
3. Literal `(no title)`.

Whitespace-only values count as empty.

```bash
title_custom_ai=$(jq -rs '
  def nonblank: select(. != null and (tostring | test("^\\s*$") | not));
  (map(select(.type=="custom-title") | .customTitle | nonblank) | .[-1]) //
  (map(select(.type=="ai-title")     | .aiTitle     | nonblank) | .[-1]) //
  "(no title)"
' "$file")
```

## CLI

`peak-ctx.sh --help` must print clear usage.

Every invocation writes `peak-ctx.tsv`. After writing, the script prints:

- `✅ Created "peak-ctx.tsv" for data analysis (N rows)`
- and either the `🎁 Run "peak-ctx.sh --pretty" for a pretty format` hint, **or** (when `--pretty` was passed) the pretty table itself.

| Invocation | Behaviour |
| :--- | :--- |
| `peak-ctx.sh` | **default: last 7 days (alias for `--last-days 7`)** |
| `peak-ctx.sh --all` | all sessions (no filter) |
| `peak-ctx.sh --today` | alias for `--last-days 1` |
| `peak-ctx.sh --last-days 1` | today only (`last_modified` ≥ today 00:00 local) |
| `peak-ctx.sh --last-days N` | today + previous `N-1` days (`last_modified` ≥ `(N-1)` days ago 00:00 local) |
| `peak-ctx.sh --last-days 0` | error: `N must be >= 1` |
| `peak-ctx.sh --pretty` | After writing TSV, also prints the pretty table to stdout. Composable with any window flag (e.g. `--last-days 3 --pretty`). |

`--all`, `--today`, and `--last-days` are mutually exclusive; passing more than one is an error. `--pretty` is orthogonal and may be combined with any window flag.

`--help` must state the default window explicitly (e.g. `Default window: last 7 days. Use --all to scan every session.`) and describe `--pretty`.

## Pretty output

`peak-ctx.sh --pretty` post-processes the TSV into a human-readable table written to stdout, columns space-padded via `column -t -s$'\t' -R 2` (right-aligns the `peak_ctx` column).

Column order: `last_modified  peak_ctx  title_custom_ai  project  session_id`. `peak_ctx` is sized for max `999,999` (the column header `peak_ctx` is 8 chars, ≥ 7 needed for the widest value); `session_id` (fixed-width UUID) goes last so the variable-width `project` doesn't push it around.

```
last_modified     peak_ctx  title_custom_ai                         project                              session_id
2026-05-01T10:18    45,788                                          home-mp-projects-shopify-sparklepop  5323d196-3d8e-4cee-9a31-844b1b326422
2026-04-29T15:54    59,219  Add authentication and user management  home-mp-projects-shopify-sparklepop  71791195-a881-4708-b16b-34ed5cc39f0b
```

Derivations from each TSV row:

- `project` = parent dir name of `session_file`, with leading `-` stripped. e.g., `-home-mp-projects-shopify-sparklepop` → `home-mp-projects-shopify-sparklepop`.
- `session_id` = basename of `session_file` minus `.jsonl`.
- `peak_ctx` = thousands-separated (portable awk `commafy` function, no locale dependency).
- `title_custom_ai` = blank if value equals literal `(no title)`, else verbatim. Truncated to 40 display chars (39 + `…`) when longer.
- Drop columns: `main_session_start`, full-path `session_file`.
- No truncation. Same row order as TSV (descending `last_modified`).

## Date filtering

Filter key: `last_modified` (file mtime, what `ls -ltr` shows). **Calendar-day semantics in local TZ** — a "day" is local 00:00 → 23:59:59. Resuming an old session bumps its mtime, so it surfaces in recent windows (intended).

Threshold = start of local calendar day `(N-1)` days ago. Portable shape (Ubuntu GNU + macOS BSD):

```bash
# Threshold epoch — branch on date flavour:
#   GNU:  date -d "$((N-1)) days ago 00:00:00" +%s
#   BSD:  date -v-$((N-1))d -v0H -v0M -v0S +%s
threshold_epoch=...

# POSIX `find -newer` takes a reference file, not a date string.
ref=$(mktemp)
touch -t "$(date -r "$threshold_epoch" +%Y%m%d%H%M.%S 2>/dev/null \
         || date -d "@$threshold_epoch" +%Y%m%d%H%M.%S)" "$ref"
find ~/.claude/projects -mindepth 2 -maxdepth 2 -name '*.jsonl' -newer "$ref"
```

Don't use `find -mtime -N` (rolling 24h, not calendar-aligned) or `find -newermt` (GNU-only).

## Verification

Deterministic fields (`last_modified`, `main_session_start`, `peak_ctx`, `session_file`, `title_custom_ai`) must match exactly.

### TSV (`peak-ctx.tsv`)

```tsv
last_modified	main_session_start	peak_ctx	session_file	title_custom_ai
2026-05-01T10:18	2026-05-01T06:15:07.430Z	45788	/home/mp/.claude/projects/-home-mp-projects-shopify-sparklepop/5323d196-3d8e-4cee-9a31-844b1b326422.jsonl	(no title)
2026-05-01T10:13	2026-05-01T06:06:36.742Z	56276	/home/mp/.claude/projects/-home-mp-projects-shopify-sparklepop/546340aa-2220-4d63-92f4-14708950d9c2.jsonl	(no title)
2026-04-29T15:54	2026-04-29T03:27:15.621Z	48010	/home/mp/.claude/projects/-home-mp-projects-shopify-sparklepop/d12c0278-ee40-4622-9c7e-4d86750c006d.jsonl	(no title)
2026-04-29T15:54	2026-04-29T03:48:45.199Z	59219	/home/mp/.claude/projects/-home-mp-projects-shopify-sparklepop/71791195-a881-4708-b16b-34ed5cc39f0b.jsonl	Add authentication and user management
```

### Pretty (`peak-ctx.sh --pretty`)

Given the TSV above, the pretty table must be:

```
last_modified     peak_ctx  title_custom_ai                         project                              session_id
2026-05-01T10:18    45,788                                          home-mp-projects-shopify-sparklepop  5323d196-3d8e-4cee-9a31-844b1b326422
2026-05-01T10:13    56,276                                          home-mp-projects-shopify-sparklepop  546340aa-2220-4d63-92f4-14708950d9c2
2026-04-29T15:54    48,010                                          home-mp-projects-shopify-sparklepop  d12c0278-ee40-4622-9c7e-4d86750c006d
2026-04-29T15:54    59,219  Add authentication and user management  home-mp-projects-shopify-sparklepop  71791195-a881-4708-b16b-34ed5cc39f0b
```

### Lint/format must pass clean

These must exit 0 with no diff against `peak-ctx.sh`:

```bash
shfmt -d -i 2 -ci -sr peak-ctx.sh
shellcheck peak-ctx.sh
```
