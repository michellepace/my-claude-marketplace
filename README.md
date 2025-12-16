# My Claude Plugins (Collected in a Marketplace)

Personal Claude Code marketplace: plugins and skills curated and packaged for individual install/uninstall control.

## Usage

Add this marketplace to your Claude Code:

```shell
/plugin marketplace add michellepace/my-claude-plugins
```

Then run the command `/plugin` to enable, disable, update, or uninstall a specific plugin in this marketplace. Now **restart** Claude Code for changes to take effect.

Enabled plugins will become available to ALL projects. They sometimes trigger automatically depending on your instruction, but I prefer to be explicit:

```text
Use the tailwindcss skill to style this component with dark mode support and responsive breakpoints.
```

## Plugins Included

Plugins and skills curated from other sources, repackaged into `my-claude-plugins` marketplace for modular control.

| My Plugin | Source Repo | Source Asset | 🔥 TO DO (write better) |
| --- | --- | --- | --- |
| [playwright-skill](https://github.com/lackeyjb/playwright-skill) | [lackeyjb/playwright-skill](https://github.com/lackeyjb/playwright-skill) | [SKILL.md](https://github.com/lackeyjb/playwright-skill/blob/main/skills/playwright/SKILL.md) | Remove: MCP tools more direct; stated API patterns aren't for automated testing. |
| [frontend-design](./plugins/frontend-design) | [anthropics/skills](https://github.com/anthropics/skills) | [SKILL.md](https://github.com/anthropics/skills/blob/main/skills/frontend-design/SKILL.md) | Remove: Will break theming, brand new projects only. |
| [shadcn-ui](./plugins/shadcn-ui) | [michellepace/my-claude-plugins](https://github.com/michellepace/my-claude-plugins) | Michelle | ✅ Complete |
| [tailwindcss](./plugins/tailwindcss) | [einverne/dotfiles](https://github.com/einverne/dotfiles) | [SKILL.md](https://github.com/einverne/dotfiles/blob/master/claude/skills/tailwindcss/SKILL.md) | Remove: basic knowledge and uses TW v3 |
| [skill-creator](./plugins/skill-creator) | [anthropics/skills](https://github.com/anthropics/skills) | [SKILL.md](https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md) | Keep: official Anthropic skill for creating new skills |

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

**WHY COLLECT OTHER PEOPLE'S SKILLS / PLUGINS IN MY OWN MARKETPLACE?**

You can't switch skills on and off, only plugins. I find selected skills that I want in marketplaces that are otherwise bloated with skills I will never need. I like to have only those skills I want, and so I package them into my own marketplace. Also, it means I can build on these plugins and have my own source control around it. The downside is that when the author publishes an update, I have to update the plugins manually in this marketplace.

Sometimes the plugin will contain exactly what I want, like this [Playwright skill](https://github.com/lackeyjb/playwright-skill). In this case, I just install it as another marketplace.

## Configuring Plugins at Project Level

I like my configuration to be in source control.

Manually adding "extraKnownMarketplaces" will mean when anyone opens Claude Code in this project, the marketplaces will automatically be available.

Running `/plugin` and opting to install marketplaces at project level will modify your project `.claude/settings.json` as "EnabledPlugins".  If you want to disable plugins, you can set them to false directly or disable via `/plugin` that will remove the line.

In my Next.js project file `.claude/settings.json` I have this configured and checked into source control:

```json
{
  "extraKnownMarketplaces": {
    "playwright-skill": {
      "source": {
        "source": "github",
        "repo": "lackeyjb/playwright-skill"
      }
    },
    "my-claude-plugins": {
      "source": {
        "source": "github",
        "repo": "michellepace/my-claude-plugins"
      }
    }
  },

  "enabledPlugins": {
    "playwright-skill@playwright-skill": true,

    "frontend-design@my-claude-plugins": false,
    "shadcn-ui@my-claude-plugins": true,
    "tailwindcss@my-claude-plugins": false,
    "skill-creator@my-claude-plugins": true
  }
}
```

This configures two marketplaces: [playwright-skill](https://github.com/lackeyjb/playwright-skill) (1 plugin enabled) and [my-claude-plugins](https://github.com/michellepace/my-claude-plugins) (2 plugins enabled, 2 disabled).
