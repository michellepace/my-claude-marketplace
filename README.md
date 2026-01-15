# My Claude Plugins (Collected in a Marketplace)

Personal Claude Code marketplace: plugins and skills curated and packaged for individual install/uninstall control.

## Plugins Included

Self-authored plugins and skills repackaged from other sources, collected here for modular control.

| Plugin | Origin | Status |
| :----- | :----- | :----- |
| [shadcn-ui](./plugins/shadcn-ui) | This repo | ✅ Self-authored (Shadcn best practices) |
| [cc-whats-new](./plugins/cc-whats-new) | This repo | ✅ Self-authored (Claude Code what's new) |
| [cc-marketplaces-plugins](./plugins/cc-marketplaces-plugins) | This repo | ✅ Self-authored (Show what's enabled) |
| [skill-creator](./plugins/skill-creator) | [anthropics/skills](https://github.com/anthropics/skills) | ✅ Duplicated (don't want other skills) |

## Usage

**Add this marketplace to your Claude Code:**

```shell
/plugin marketplace add michellepace/my-claude-marketplace
```

Then run the command `/plugin` to enable, disable, update, or uninstall a specific plugin in this marketplace at your preferred scope (see [Appendix 1: Plugin Scope](#appendix-1-plugin-scope)).

📌 EXAMPLE 1 (assuming `shadcn-ui` plugin is enabled):

```text
Use the shadcn-ui plugin to build this form with proper validation and accessible components.
```

💡 *Claude Code automatically invokes relevant skills when a task matches their description — this follows the principle of progressive disclosure of context. However, I find it more reliable to explicitly mention the skill/plugin.*

📌 EXAMPLE 2 (assuming `cc-whats-new` plugin is enabled):

Instruct Claude Code:

```text
What is new this week in Claude Code, use the cc-whats-new plugin  
```

OR since the plugin just contains a command, run it directly:

```bash
/cc-whats-new:explain this week

/cc-whats-new:explain 2.1.7
```

## About Plugins and Marketplaces

*Full layman's explanation in [this article](https://ailearnlog.com/claude-code-skills-plugins-marketplaces/).*

A marketplace is a collection of plugins. Each plugin is a "bag" containing any combination of skills, agents, commands, hooks, and MCP servers. Marketplaces consolidate components across all projects, provide source control, easy sharing and updates, and let you enable/disable entire plugins.

For this marketplace, the packaged plugins live in [plugins/](plugins/).

<div align="center">
  <a href="images/marketplace-plugin-sketch.webp" target="_blank">
    <img src="images/marketplace-plugin-sketch.webp" alt="Hand-drawn sketch showing the plugin-marketplace relationship. A large rounded rectangle labelled I will package it into a marketplace contains three smaller rounded shapes representing individual plugins. The leftmost plugin labelled Plugin Bag shows its contents: Skills, Agents, Commands, MCPs, and Hooks. Two additional plugins are labelled another plugin and another one. Below the diagram are five checkmarks listing marketplace benefits with a bracket labelled Marketplace Benefits: Source Control, One place for all projects, plugins can be switched on or off, easy to share, and easy to get updates." width="550">
  </a>
</div>

A plugin can contain any number of the following components:

```text
[plugin-name]/
├── .claude-plugin/plugin.json # Manifest (REQUIRED)
├── commands/ # slash commands (.md)
├── agents/   # new context window (.md)
├── skills/   # extends capabilities (.md)
├── hooks/    # reacts to events (.json)
├── scripts/  # custom dir (not auto-discovered, common convention)
└── .mcp.json # external tools to use
```

*Note: hooks and MCP servers can alternatively be defined inline in `plugin.json`.*

## Configuring Plugins at Project Level

To share plugin configuration with your team via source control, add this to `.claude/settings.json`:

- **extraKnownMarketplaces** — prompts team members to add the marketplace when they open the project
- **enabledPlugins** — controls which installed plugins are active (`true`) or disabled (`false`)

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
    "skill-creator@my-claude-marketplace": true,
    "cc-whats-new@my-claude-marketplace": true,
    "cc-marketplaces-plugins@my-claude-marketplace": true
  }
}
```

This registers the marketplace and enables all 4 plugins.

## Appendix 1: Plugin Scope

Plugins can be enabled at four scope levels. Higher scopes override lower ones (managed > local > project > user).

| Scope | Settings File | Who it affects | Shared with team? |
| :---- | :------------ | :------------- | :---------------- |
| **managed** | `managed-settings.json` (system) | All users on the machine | Yes (deployed by IT) |
| **local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |
| **project** | `.claude/settings.json` | All collaborators on the repo | Yes (committed to git) |
| **user** | `~/.claude/settings.json` | You, across all projects | No |

*Command line flags like `--plugin-dir` provide temporary session overrides that take precedence over all scopes except managed.*

## Appendix 2: Developing Plugins

To test a plugin you're working on, run Claude Code with `--plugin-dir`:

```shell
# Example: testing the cc-whats-new plugin
claude --plugin-dir ~/projects/my-claude-marketplace/plugins/cc-whats-new
```

This loads the plugin directly from your local directory without installing it, so you can test changes immediately without publishing to your marketplace first. Edit your files, restart Claude Code, test. No install/uninstall needed.
