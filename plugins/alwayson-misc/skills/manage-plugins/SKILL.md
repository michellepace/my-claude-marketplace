---
name: manage-plugins
description: Manage Claude plugins and marketplaces — use whenever these come up.
user-invocable: true
disable-model-invocation: false
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

# Plugins and Marketplaces

Source of truth is `enabledPlugins` and `extraKnownMarketplaces` in a settings file; the CLI just edits it.

Scopes accumulate and highest wins: local > project > user:

- **project** `.claude/settings.json` — my default: every write takes `--scope project` (the CLI never defaults to project — usually `user`)
- **user** `~/.claude/settings.json` — may be a small number of global plugins in here
- **local** `.claude/settings.local.json` — should never be in play

| To… | Run |
| :-- | :-- |
| See this project's plugins (`true` = enabled) and marketplaces | `jq '{file: input_filename, enabledPlugins, extraKnownMarketplaces}' ~/.claude/settings.json .claude/settings.json .claude/settings.local.json` |
| Find which marketplace offers a plugin | `claude plugin list --json --available \| jq -r '.available[] \| select(.name=="<name>") \| .marketplaceName'` |
| Inspect an installed plugin | `claude plugin details <name>@<mkt>` |
| Add a marketplace | `claude plugin marketplace add <owner/repo> --scope project` |
| Refresh marketplaces from source | `claude plugin marketplace update` |
| Remove a marketplace from this project only | `claude plugin marketplace remove <mkt> --scope project` |
| Install / enable / disable / update / uninstall a plugin | `claude plugin <verb> <name>@<mkt> --scope project` |
| Anything else | `claude plugin --help`, `claude plugin <cmd> --help` |

## Gotchas

- `claude plugin list` and `claude plugin marketplace list` are machine-wide with duplicates — never a per-project answer; read the settings file.
- `details` only sees installed plugins, and `--available` only works with `--json` — hence the "which marketplace" row.
- `marketplace remove` without `--scope` hits every scope and uninstalls that marketplace's plugins.

## Update Everything, Everywhere

`marketplace update` is machine-wide and refreshes only the marketplace clones. Plugin installs are recorded per `(plugin, scope, project)`, so `update` is per project — there is no `--all`. Restart (or `/reload-plugins`) to apply.

```shell
claude plugin marketplace update   # every marketplace, one shot

# user scope
claude plugin list --json | jq -r '.[] | select(.scope=="user") | .id' | sort -u \
| while read -r id; do claude plugin update "$id" --scope user; done

# project scope — must cd into each project
claude plugin list --json | jq -r '.[] | select(.scope=="project") | "\(.projectPath)\t\(.id)"' | sort -u \
| while IFS=$'\t' read -r proj id; do
    [ -d "$proj" ] || { echo "skip (missing): $proj"; continue; }
    ( cd "$proj" && claude plugin update "$id" --scope project )
  done
```

To preview, swap `claude plugin update` for `echo`. Updating leaves the old version's cache dir behind, and `prune` only removes dependencies — list the dangling ones (safe to `rm -rf`) with:

```shell
comm -13 \
  <(jq -r '.plugins[][].installPath' ~/.claude/plugins/installed_plugins.json | sort -u) \
  <(find ~/.claude/plugins/cache -mindepth 3 -maxdepth 3 -type d | sort -u)
```

## Testing a Plugin Locally

No install needed. Edit, then `/reload-plugins` or restart:

```shell
claude --plugin-dir ~/projects/my-claude-marketplace/plugins/<plugin-name>
```

## Replying

To the point: a table for plugin state (✅ / ❌), a code block for commands to run, one line of context if needed. No commentary on what wasn't asked.
