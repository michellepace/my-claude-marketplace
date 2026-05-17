---
name: cc-manage-plugins
description: Manage Claude marketplaces & plugins
argument-hint: "GitHub URL or owner@marketplace"
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(claude plugin *)
---

# Install Marketplace + Plugin

Turn a marketplace or plugin request into the right `claude` commands

1. Parse `$ARGUMENTS` for the request. If the scope isn't stated, ask the user before running anything. If unsure or ambiguous - clarity.

2. Build the commands using `<example_project_scope>` and/or Appendix; for anything it doesn't cover, levereage `claude plugin --help` (and `claude plugin <subcommand> --help` for flags).

3. Present response in a clear format (`<format_guide>`), offer to run commands when relevant. Be clear and concise.

<format_guide>

*Short explanatory detail when valuable.*

```bash
# 1. Detail command(s) simply
```

🙂 Would you like me to run them?

</format_guide>

<example_project_scope>

From a GitHub URL like `https://github.com/anthropics/claude-plugins-official/tree/main/plugins/feature-dev` or `owner@marketplace` (like `anthropics@claude-plugins-official`)

```bash
# 1. Add the marketplace (writes "extraKnownMarketplaces")
claude plugin marketplace add anthropics/claude-plugins-official --scope project

# 2. Install plugins (writes "enabledPlugins")
claude plugin install feature-dev@claude-plugins-official --scope project
claude plugin install superpowers@claude-plugins-official --scope project

# 3. Disable / re-enable a plugin (keeps it installed)
claude plugin disable feature-dev@claude-plugins-official --scope project
claude plugin enable  feature-dev@claude-plugins-official --scope project

# 4. Uninstall a plugin; supports --scope user|project|local
claude plugin uninstall feature-dev@claude-plugins-official --scope project

# 5. Remove a marketplace (global): also uninstalls all its plugins
claude plugin marketplace remove claude-plugins-official
```

Note: `marketplace remove` has no `--scope` flag — always global. Verify the marketplace's `extraKnownMarketplaces` and `enabledPlugins` entries were removed from `settings.json`; delete any leftovers by hand.

After steps 1–3 above, `.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "feature-dev@claude-plugins-official": false,
    "superpowers@claude-plugins-official": true
  },
  "extraKnownMarketplaces": {
    "claude-plugins-official": {
      "source": {
        "source": "github",
        "repo": "anthropics/claude-plugins-official"
      }
    }
  }
}
```

</example_project_scope>

## Appendix

### About Plugin Scope

Plugins can be enabled at four scope levels. The override order (highest to lowest) is: managed > local > project > user.

| Scope | Settings file | Affects | Team-shared |
| :-- | :-- | :-- | :-- |
| `managed` | `managed-settings.json` | Whole machine | Yes — IT-deployed |
| `local` | `.claude/settings.local.json` | This repo, you only | No — gitignored |
| `project` | `.claude/settings.json` | This repo, all collaborators | Yes — committed |
| `user` | `~/.claude/settings.json` (default) | All your projects | No |

### Reading installed plugins

`claude plugin list` is a **machine-wide aggregate** across every project's `settings.json` (hence duplicates) — only its `Status` column is cwd-sensitive; it cannot be scoped to one project. For a true per-project view, read that project's `.claude/settings.json` `enabledPlugins` directly (Read tool).

### Developing Plugins

Test a plugin locally without installing:

```shell
claude --plugin-dir ~/projects/my-claude-marketplace/plugins/git-utils
```

`--plugin-dir` is a temporary session override, beating every scope except `managed`.

Edit your files, run `/reload-plugins`, test. No install/uninstall needed.
