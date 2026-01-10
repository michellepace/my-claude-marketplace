# My Claude Plugins (Collected in a Marketplace)

Personal Claude Code marketplace: plugins and skills curated and packaged for individual install/uninstall control.

## Usage

Add this marketplace to your Claude Code:

```shell
/plugin marketplace add michellepace/my-claude-marketplace
```

Then run the command `/plugin` to enable, disable, update, or uninstall a specific plugin in this marketplace.

Enabled plugins will become available to ALL projects. They sometimes trigger automatically depending on your instruction, but I prefer to be explicit:

```text
Use the shadcn-ui skill to build this form with proper validation and accessible components.
```

## Plugins Included

Self-authored plugins and skills repackaged from other sources, collected here for modular control.

| Plugin | Origin | Status |
| --- | --- | --- |
| [shadcn-ui](./plugins/shadcn-ui) | This repo | ✅ Self-authored |
| [skill-creator](./plugins/skill-creator) | [anthropics/skills](https://github.com/anthropics/skills) | ✅ Duplicated (don't want other skills) |
| [tailwindcss](./plugins/tailwindcss) | [einverne/dotfiles](https://github.com/einverne/dotfiles) | Remove (uses TW v3) |

## About Plugins and Marketplaces

*Full layman's explanation in [this article](https://ailearnlog.com/claude-code-skills-plugins-marketplaces/).*

A marketplace is a collection of plugins. Each plugin is a "bag" containing any combination of skills, agents, commands, hooks, and MCP servers. Marketplaces consolidate components across all projects, provide source control, easy sharing and updates, and let you enable/disable entire plugins.

For this marketplace, the packaged plugins live in [plugins/](plugins/).

<div align="center">
  <a href="marketplace-plugin-sketch.webp" target="_blank">
    <img src="marketplace-plugin-sketch.webp" alt="Hand-drawn sketch showing the plugin-marketplace relationship. A large rounded rectangle labelled I will package it into a marketplace contains three smaller rounded shapes representing individual plugins. The leftmost plugin labelled Plugin Bag shows its contents: Skills, Agents, Commands, MCPs, and Hooks. Two additional plugins are labelled another plugin and another one. Below the diagram are five checkmarks listing marketplace benefits with a bracket labelled Marketplace Benefits: Source Control, One place for all projects, plugins can be switched on or off, easy to share, and easy to get updates." width="550">
  </a>
</div>

A plugin can contain any number of the following components:

```text
[plugin-name]/
├── .claude-plugin/plugin.json # Manifest (REQUIRED)
├── commands/ # slash commands .md
├── agents/ # new context window (.md)
├── skills/ # extends capabilities (.md)
├── hooks/ # reacts to events
├── scripts/ # eg. for hooks to run
└── .mcp.json # external tools to use
```

**WHY REPACKAGE SKILLS INTO MY OWN MARKETPLACE?**

You can enable or disable *plugins*, but not individual skills within them. If a plugin bundles 5 skills and I only want 1, I'm stuck with all 5 or none.

My solution: extract the skills I want and repackage them as separate, single-skill plugins in my own marketplace. This gives me:

- Granular control over exactly which skills are active
- My own source control and ability to customize
- (Downside: I manually update when authors publish changes)

Sometimes a plugin is exactly what I need as-is—like those in [claude-plugins-official](https://github.com/anthropics/claude-plugins-official). Each skill is its own plugin, so I can enable/disable exactly what I want. No repackaging needed.

## Configuring Plugins at Project Level

I keep my configuration in source control.

**Step 1: Register marketplaces** — Adding `extraKnownMarketplaces` makes the marketplace *available* to anyone who opens Claude Code in this project. Think of it as adding an app store.

**Step 2: Enable plugins** — The `enabledPlugins` section controls which plugins from those marketplaces are actually *active*. You can set them to `false` to disable, or use `/plugin` to manage them interactively.

In my Next.js project `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "playwright-skill": {
      "source": {
        "source": "github",
        "repo": "lackeyjb/playwright-skill"
      }
    },
    "my-claude-marketplace": {
      "source": {
        "source": "github",
        "repo": "michellepace/my-claude-marketplace"
      }
    }
  },

  "enabledPlugins": {
    "playwright-skill@playwright-skill": true,

    "shadcn-ui@my-claude-marketplace": true,
    "skill-creator@my-claude-marketplace": true,
    "tailwindcss@my-claude-marketplace": false
  }
}
```

This configures two marketplaces: [playwright-skill](https://github.com/lackeyjb/playwright-skill) (1 plugin enabled) and [my-claude-marketplace](https://github.com/michellepace/my-claude-marketplace) (2 enabled, 1 disabled).
