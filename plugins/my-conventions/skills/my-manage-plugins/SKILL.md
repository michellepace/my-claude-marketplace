---
name: my-manage-plugins
description: Manage Claude plugins and marketplaces — use whenever these come up.
user-invocable: true
disable-model-invocation: false
allowed-tools:
  - Bash(claude plugin --help)
  - Bash(claude plugin * --help)
  - Bash(claude plugin list *)
  - Bash(claude plugin marketplace list *)
  - Bash(claude plugin details *)
  - Bash(jq '{enabledPlugins, extraKnownMarketplaces}' *)
---

# Plugins and Marketplaces

Source of truth is `enabledPlugins` and `extraKnownMarketplaces` in a settings file; the CLI just edits it. Scopes (highest wins: local > project > user):

- **project** `.claude/settings.json` — my default: "this project" means this file, and every write takes `--scope project` (the CLI never defaults to project — usually `user`)
- **user** `~/.claude/settings.json` — may be a small number of global plugins in here
- **local** `.claude/settings.local.json` — should never be in play

| To… | Run |
| :-- | :-- |
| See this project's plugins (`true` = enabled) and marketplaces | `jq '{enabledPlugins, extraKnownMarketplaces}' <settings.json>` |
| Find which marketplace offers a plugin | `claude plugin list --json --available \| jq -r '.available[] \| select(.name=="<name>") \| .marketplaceName'` |
| Inspect an installed plugin | `claude plugin details <name>@<mkt>` |
| Add a marketplace | `claude plugin marketplace add <owner/repo> --scope project` |
| Refresh marketplaces from source | `claude plugin marketplace update` |
| Remove a marketplace from this project only | `claude plugin marketplace remove <mkt> --scope project` |
| Install / enable / disable / uninstall a plugin | `claude plugin <verb> <name>@<mkt> --scope project` |
| Anything else | `claude plugin --help`, `claude plugin <cmd> --help` |

## Replying

To the point: a table for plugin state (✅ / ❌), a code block for commands to run, one line of context if needed. No commentary on what wasn't asked.

## Gotchas

- `claude plugin list` and `claude plugin marketplace list` are machine-wide with duplicates — never a per-project answer; read the settings file.
- `details` only sees installed plugins, and `--available` only works with `--json` — hence the "which marketplace" row.
- `marketplace remove` without `--scope` hits every scope and uninstalls that marketplace's plugins.

## Testing a Plugin Locally

No install needed. Edit, then `/reload-plugins` or restart:

```shell
claude --plugin-dir ~/projects/my-claude-marketplace/plugins/<plugin-name>
```
