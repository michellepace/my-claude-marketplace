# My Claude Marketplace (A Bag of Plugins)

<div align="center">
  <a href="images/marketplace-plugin-sketch.webp" target="_blank">
    <img src="images/marketplace-plugin-sketch.webp" alt="Hand-drawn sketch showing the plugin-marketplace relationship. A large rounded rectangle labelled I will package it into a marketplace contains three smaller rounded shapes representing individual plugins. The leftmost plugin labelled Plugin Bag shows its contents: Skills, Agents, Commands, MCPs, and Hooks. Two additional plugins are labelled another plugin and another one. Below the diagram are five checkmarks listing marketplace benefits with a bracket labelled Marketplace Benefits: Source Control, One place for all projects, plugins can be switched on or off, easy to share, and easy to get updates." width="500">
  </a>
</div>

## Plugins

- [shadcn-ui](./plugins/shadcn-ui) — Shadcn best practices
- [cc-whats-new](./plugins/cc-whats-new) — Claude Code what's new
- [cc-what-plugins](./plugins/cc-what-plugins) — Show what's enabled

## Usage

**Add this marketplace:**

```shell
/plugin marketplace add michellepace/my-claude-marketplace
```

Then use `/plugin` to enable, disable, update, or uninstall plugins at your preferred [scope](#appendix-1-plugin-scope).

Mention the plugin by name in your prompt, or run its slash command directly:

```bash
/cc-whats-new:explain this week
```

*Tip: Claude Code can auto-invoke matching skills, but explicitly naming the plugin is more reliable.*

## Configuring Plugins at Project Level

*Learn more: [Plugins and Marketplaces explained](https://ailearnlog.com/claude-code-skills-plugins-marketplaces/).*

Add this to `.claude/settings.json` to share plugin configuration with your team:

```json
{
  "extraKnownMarketplaces": {
    "my-claude-marketplace": {
      "source": {
        "source": "github",
        "repo": "michellepace/my-claude-marketplace"
      }
    }
  },

  "enabledPlugins": {
    "shadcn-ui@my-claude-marketplace": true,
    "cc-whats-new@my-claude-marketplace": true,
    "cc-what-plugins@my-claude-marketplace": true
  }
}
```

## Appendix 1: Plugin Scope

Plugins can be enabled at four scope levels. Higher scopes override lower ones (managed > local > project > user).

| Scope | Settings File | Who it affects | Shared with team? |
| :---- | :------------ | :------------- | :---------------- |
| **managed** | `managed-settings.json` (system) | All users on the machine | Yes (deployed by IT) |
| **local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |
| **project** | `.claude/settings.json` | All collaborators on the repo | Yes (committed to git) |
| **user** | `~/.claude/settings.json` | You, across all projects | No |

*`--plugin-dir` provides a temporary session override that takes precedence over all scopes except managed.*

## Appendix 2: Developing Plugins

Test a plugin locally without installing:

```shell
claude --plugin-dir ~/projects/my-claude-marketplace/plugins/cc-whats-new
```

Edit your files, restart Claude Code, test. No install/uninstall needed.
