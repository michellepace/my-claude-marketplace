# My Claude Marketplace (A Bag of Plugins)

<div align="center">
  <a href="images/marketplace-plugin-sketch.webp" target="_blank">
    <img src="images/marketplace-plugin-sketch.webp" alt="Hand-drawn sketch showing the plugin-marketplace relationship. A large rounded rectangle labelled I will package it into a marketplace contains three smaller rounded shapes representing individual plugins. The leftmost plugin labelled Plugin Bag shows its contents: Skills, Agents, Commands, MCPs, and Hooks. Two additional plugins are labelled another plugin and another one. Below the diagram are five checkmarks listing marketplace benefits with a bracket labelled Marketplace Benefits: Source Control, One place for all projects, plugins can be switched on or off, easy to share, and easy to get updates." width="500">
  </a>
</div>

## Plugins In This Marketplace

| Plugin | Description |
| :----- | :---------- |
| [nextjs-utils](./plugins/nextjs-utils) | Download and index all Nextjs docs. Shadcn best-practices. |
| [claude-code-utils](./plugins/claude-code-utils) | Show installed plugins. Explain whats new in Claude Code. |
| [find-my-font](./plugins/find-my-font) | Font pairing with the Kupferschmid matrix |
| [repo-utils](./plugins/repo-utils) | Basic repo workflows (commits, CodeRabbit, merge cleanup) |

## Installation - User Scope

First, add the marketplace:

```
/plugin marketplace add michellepace/my-claude-marketplace
```

Then install a plugin:

```
/plugin install {plugin-name}@my-claude-marketplace
```

Or browse available plugins, run `/plugin` > Marketplace > Select "my-claude-marketplace" > Browse Plugins > Install...

## Installation - Project Scope

When you install a plugin at project scope (via `/plugin` > "Install for all collaborators"), Claude Code adds the plugin to [.claude/settings.json](claude/settings.json) under `enabledPlugins` — but it does **not** record where the marketplace comes from. Collaborators who clone the repo won't be able to resolve the marketplace source.

To fix this, register the marketplace at project scope:

```
claude plugin marketplace add michellepace/my-claude-marketplace --scope project
```

This writes an `extraKnownMarketplaces` entry to [.claude/settings.json](claude/settings.json), so collaborators are automatically prompted to install the marketplace when they trust the repo folder:

```json
{
  "enabledPlugins": {
    "repo-utils@my-claude-marketplace": true
  },
  "extraKnownMarketplaces": {
    "my-claude-marketplace": {
      "source": {
        "source": "github",
        "repo": "michellepace/my-claude-marketplace"
      }
    }
  }
}
```

---

## Appendix

### 1. About Plugin Scope

Plugins can be enabled at four scope levels. The override order (highest to lowest) is: managed > local > project > user. Command-line arguments like `--plugin-dir` provide temporary session overrides that sit below managed but above all other scopes.

| Scope | Settings File | Who it affects | Shared with team? |
| :---- | :------------ | :------------- | :---------------- |
| **managed** | `managed-settings.json` (system) | All users on the machine | Yes (deployed by IT) |
| **local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |
| **project** | `.claude/settings.json` | All collaborators on the repo | Yes (committed to git) |
| **user** | `~/.claude/settings.json` | You, across all projects | No |

### 2. Developing Plugins

Test a plugin locally without installing:

```shell
claude --plugin-dir ~/projects/my-claude-marketplace/plugins/claude-code-utils
```

`--plugin-dir` provides a temporary session override that takes precedence over all scopes except managed.

Edit your files, run `/reload-plugins` (or restart Claude Code), test. No install/uninstall needed.
