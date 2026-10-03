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

Question: `$ARGUMENTS`

You are to answer a Question about Claude plugins and marketplaces. If the Question is blank or irrelevant to this, show me a friendly helpful message. List 3-4 examples of what I could ask. Keep it short and easy to read.

> 🤔 ...

Otherwise, leverage this information to help answer the question.

## Plugins and Marketplaces — Answer the Question

Source of truth is `enabledPlugins` and `extraKnownMarketplaces` in a settings file; the CLI just edits it.

Plugins from all scopes merge; on conflict the highest wins — local > project > user:

- **local** `.claude/settings.local.json` — rarely in play; ask me if I want to migrate strays to project scope
- **user** `~/.claude/settings.json` — alwayson-misc is okay to be here (it may not be). Anything else is likely my mistake: tell me, and offer `claude plugin uninstall <name>@<mkt> --scope user`.
- **project** `.claude/settings.json` — my default: every write takes `--scope project` (the CLI defaults to `user`, never project)

| To… | Run |
| :-- | :-- |
| See this project's plugins (`true` = enabled) and marketplaces | `jq '{file: input_filename, enabledPlugins, extraKnownMarketplaces}' .claude/settings.local.json .claude/settings.json ~/.claude/settings.json 2>/dev/null` |
| Find which marketplace offers a plugin | `claude plugin list --json --available \| jq -r '.available[] \| select(.name=="<name>") \| .marketplaceName'` |
| Inspect an installed plugin | `claude plugin details <name>@<mkt>` |
| Add a marketplace | `claude plugin marketplace add <owner/repo> --scope project` |
| Refresh every marketplace from source (plugins not updated; see below) | `claude plugin marketplace update` |
| Remove a marketplace from this project only | `claude plugin marketplace remove <mkt> --scope project` |
| Install / enable / disable / update / uninstall a plugin | `claude plugin <verb> <name>@<mkt> --scope project` |
| Anything else | `claude plugin --help`, `claude plugin <cmd> --help` |

## Gotchas

- `claude plugin list` and `claude plugin marketplace list` are machine-wide and contain duplicates — never a per-project answer; read the settings file.
- `details` only sees installed plugins, and `--available` only works with `--json` — hence the "which marketplace" row.
- `marketplace remove` without `--scope` hits every scope and uninstalls that marketplace's plugins.
- The `jq` row lists files highest-precedence first, so the **first** hit wins. A missing file is normal (exits 2; the output is still complete).

## Update All Plugins, Everywhere

Two layers, updated separately:

- **Marketplace copy**: one per machine, shared by every project. `claude plugin marketplace update [<mkt>]` refreshes it from source.
- **Install record**: one per `(plugin, scope, project)`, pinned to a version. Each is updated from its own project, including via the `/plugin` menu; there is no `--all`.

A record is behind when its version differs from the marketplace copy's. Plugins without `version` in `plugin.json` are versioned by marketplace commit, so every commit makes all of them new; plugins with `version` update only when it's bumped.

```shell
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

The loop changes other projects: show me the records it will touch (the `echo` preview) and confirm before running it. To preview, swap `claude plugin update` for `echo`. Sessions already open in a changed project need a restart or `/reload-plugins`.

`</dev/null` stops `update` reading the rest of the loop's input. A plugin whose marketplace changed its install command needs a person to confirm it, so it fails here; rerun that one alone in its project.

**Check, both must hold:**

```shell
# after the loop: one line per plugin; listed twice = a record behind
claude plugin list --json | jq -r '.[] | [.id, .version] | @tsv' | sort | uniq -c

# must print nothing
jq -r '.plugins[][].installPath' ~/.claude/plugins/installed_plugins.json | sort -u \
| while read -r p; do [ -d "$p" ] || echo "BROKEN: $p"; done
```

A `BROKEN` record still reports the latest version, so `update` won't repair it. From that project: `claude plugin uninstall <id> --scope <scope> && claude plugin install <id> --scope <scope>`.

**Never clean the cache by hand.** Old version dirs are swept automatically some time after an update. Deleting one that `installed_plugins.json` still references breaks that plugin silently (enabled in settings, files gone).

## Testing a Plugin Locally

No install needed. Edit, then run `/reload-plugins` or restart:

```shell
claude --plugin-dir ~/projects/my-claude-marketplace/plugins/<plugin-name>
```

## Replying

To the point: a table for plugin state (✅ / ❌), a code block for commands to run, one line of context if needed. No commentary on what wasn't asked.
