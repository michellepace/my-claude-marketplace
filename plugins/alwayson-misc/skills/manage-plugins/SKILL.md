---
name: manage-plugins
description: Answer Claude plugin and marketplace questions
argument-hint: '"Which plugins apply to this project?"'
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(claude plugin --help)
  - Bash(claude plugin * --help)
  - Bash(claude plugin list *)
  - Bash(claude plugin marketplace list *)
  - Bash(claude plugin marketplace update *)
  - Bash(claude plugin update *)
  - Bash(claude plugin details *)
  - Bash(jq *)
---

# Answer Claude Plugin & Marketplace Questions

**Question to answer:** $ARGUMENTS

If blank or not about plugins or marketplaces, reply with a short message listing 3 questions as examples. Start with "🤔 ..."

## Scopes and Commands

What a project uses is `enabledPlugins` and `extraKnownMarketplaces` in its settings files. Plugins from all scopes merge; on conflict the highest wins — local > project > user:

- **local** `.claude/settings.local.json` — rarely in play; ask me if I want to migrate strays to project scope
- **project** `.claude/settings.json` — my default: every write takes `--scope project` (the CLI defaults to `user`)
- **user** `~/.claude/settings.json` — only alwayson-misc belongs here, if anything. Anything else is likely my mistake: tell me, and offer `claude plugin uninstall <name>@<mkt> --scope user`.

| To… | Run |
| :-- | :-- |
| See this project's plugins (`true` = enabled) and marketplaces | `jq '{file: input_filename, enabledPlugins, extraKnownMarketplaces}' .claude/settings.local.json .claude/settings.json ~/.claude/settings.json 2>/dev/null` |
| Find which marketplace offers a plugin | `claude plugin list --json --available \| jq -r '.available[] \| select(.name=="<name>") \| .marketplaceName'` |
| Inspect an installed plugin | `claude plugin details <name>@<mkt>` |
| Add a marketplace | `claude plugin marketplace add <owner/repo> --scope project` |
| Refresh every marketplace from source (plugins not updated; see below) | `claude plugin marketplace update` |
| Find which projects use a marketplace | Search `~/projects` for `.claude/settings*.json` files containing `<mkt>` (plus `~/.claude/settings.json`) |
| Remove a marketplace | **This project:** `claude plugin uninstall <name>@<mkt> --scope project` for each `*@<mkt>` plugin, then delete `<mkt>` from `extraKnownMarketplaces` in `.claude/settings.json`. **Every project:** `claude plugin marketplace remove <mkt>`, then delete `*@<mkt>` and `<mkt>` from each file the "which projects" row finds |
| Install / enable / disable / update a plugin | `claude plugin <verb> <name>@<mkt> --scope project` |
| Uninstall a plugin | `claude plugin uninstall <name>@<mkt> --scope project`; if no `*@<mkt>` plugin is left in that file, also delete `<mkt>` from its `extraKnownMarketplaces` |
| Test a plugin from my marketplace without installing it | Tell me to run `claude --plugin-dir ~/projects/my-claude-marketplace/plugins/<plugin-name>`, then `/reload-plugins` after each edit |
| Anything else | `claude plugin --help`, `claude plugin <cmd> --help` |

## Gotchas

- `claude plugin list` and `claude plugin marketplace list` are machine-wide and contain duplicates — never a per-project answer; read the settings files.
- `details` only sees installed plugins, and `--available` only works with `--json` — hence the "which marketplace" row.
- `marketplace remove` does one of two things, depending on whether it removes the last scope that declares `<mkt>` from this directory. Hence the "Remove a marketplace" row.
  - **Last scope** (no `--scope`, or the only declaring one): uninstalls its plugins in every project, and deletes `*@<mkt>` and `<mkt>` from this directory's files only. Other projects keep both, and `remove` and `uninstall` there now fail with `not found`. A leftover `extraKnownMarketplaces` entry re-clones the marketplace at the next session start.
  - **Any other scope**: deletes only that scope's `<mkt>` declaration. `*@<mkt>` and installs stay.
- `enable` / `disable` exit `1` when the plugin is already in that state. That's not a failure (`--json` gives `failureCode: "already_in_goal_state"`).
- The `jq` row lists files highest-precedence first, so the **first** hit wins. A missing file is normal (exits 2; the output is still complete).

## Update All Plugins, Everywhere

Two layers, updated separately:

- **Marketplace copy**: one per machine, shared by every project. `claude plugin marketplace update [<mkt>]` refreshes it from source.
- **Install record**: one per `(plugin, scope, project)`, pinned to a version. Each is updated from its own project, including via the `/plugin` menu; there is no `--all`.

A record is behind when its version differs from the marketplace copy's. Plugins without `version` in `plugin.json` are versioned by marketplace commit, so every commit makes all of them new; plugins with `version` update only when it's bumped.

```bash
claude plugin marketplace update   # every marketplace

# every install record; set m to a marketplace name to limit it
m=""
claude plugin list --json \
| jq -r --arg m "$m" '.[] | select($m == "" or (.id | endswith("@" + $m)))
    | [.id, .scope, .projectPath // ""] | @tsv' | sort -u \
| while IFS=$'\t' read -r id scope proj; do
    if [ -n "$proj" ] && [ ! -d "$proj" ]; then echo "skip (missing): $proj"; continue; fi
    ( cd "${proj:-.}" && claude plugin update "$id" --scope "$scope" </dev/null )
  done
```

The loop changes other projects. First run it with `echo` in place of `claude plugin update`, show me the records, and wait for my go-ahead. Sessions already open in a changed project need a restart or `/reload-plugins`.

`</dev/null` stops `update` reading the rest of the loop's input. An update that needs a command approved fails here instead. Don't pass `-y` or `--accept-command` yourself: give me `cd <project> && claude plugin update <id> --scope <scope>` to run in my own terminal.

**Check:** one line per plugin; a plugin on two lines has a record behind. Records of missing projects are left out, as the loop skips them.

```bash
claude plugin list --json \
| jq -r '.[] | [.id, .version, .projectPath // ""] | @tsv' \
| while IFS=$'\t' read -r id v p; do [ -z "$p" ] || [ -d "$p" ] && printf '%s\t%s\n' "$id" "$v"; done \
| sort | uniq -c
```

**Never clean the cache by hand.** Old versions are swept automatically.

## Replying

To the point: a table for plugin state (✅ / ❌), a code block for commands to run, one line of context if needed. No commentary on what wasn't asked. Get every count you report from a command (`wc -l`, `grep -c`, `jq length`), never by reading the output.
