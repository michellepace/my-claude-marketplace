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
---

# Plugins and Marketplaces: manage via CLI, project scope by default

Use user or local scope only when asked.

```shell
# Discover the full command set
claude plugin --help
claude plugin marketplace --help

# Inspect
claude plugin marketplace list    # configured marketplaces
claude plugin list                # installed plugins and enabled state
claude plugin details <name>      # a plugin's components and token cost

# Change, --scope project unless asked otherwise
claude plugin marketplace add anthropics/claude-plugins-official --scope project
claude plugin marketplace update  # re-fetch marketplaces from their source
claude plugin install receipts@claude-plugins-official --scope project
claude plugin disable receipts@claude-plugins-official --scope project
claude plugin enable receipts@claude-plugins-official --scope project
claude plugin uninstall receipts@claude-plugins-official --scope project
```

`marketplace add` and `install` write to the project's `.claude/settings.json`: `extraKnownMarketplaces` and `enabledPlugins`.

## Gotchas

- `claude plugin marketplace remove` has no `--scope`. It is global and uninstalls every plugin from that marketplace. To drop a marketplace from one project only, delete its `extraKnownMarketplaces` entry in `.claude/settings.json` by hand.
- `claude plugin list` is a machine-wide aggregate across every project, hence duplicates. For a true per-project view, read that project's `.claude/settings.json` and look at `enabledPlugins`.

## Testing a Plugin Locally

No install needed. Edit, then `/reload-plugins` or restart:

```shell
claude --plugin-dir ~/projects/my-claude-marketplace/plugins/<plugin-name>
```
