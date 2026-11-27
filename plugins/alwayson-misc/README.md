# Plugin: `alwayson-misc`

A Plugin of miscellaneous Skills that I always keep on. They hardcode my own preferences and machine.

Add marketplace and install (user scope):

```bash
# 1. Add Marketplace
claude plugin marketplace add michellepace/my-claude-marketplace --scope user

# 2. Install Plugin "alwayson-misc"
claude plugin install alwayson-misc@my-claude-marketplace --scope user
```

The auto-invoking uv skill lives in its own plugin, [`uv-pep723`](../uv-pep723), to install only where wanted.

## What's Inside

| Run Skill | What it does |
| :-------- | :----------- |
| [`/anthropics-plugins`](skills/anthropics-plugins/SKILL.md) | Browse Anthropic's GitHub marketplaces and plugins |
| [`/grill-me`](skills/grill-me/SKILL.md) | Get grilled on an idea to thrash it out |
| [`/manage-plugins`](skills/manage-plugins/SKILL.md) | Manage Claude plugins and marketplaces |
| [`/vscode-config`](skills/vscode-config/SKILL.md) | Answer VS Code config questions |

## Usage Examples

[`/anthropics-plugins`](skills/anthropics-plugins/SKILL.md)
- *"What marketplaces are there?"*
- *"are there plugins that can help me design/create/test mcps?"*
- *"what's inside the skill-creator plugin?"*
- (Fetches each marketplace.json once, then answers follow-ups from local files)

[`/manage-plugins`](skills/manage-plugins/SKILL.md)
- *"for my plugins, update everything, everywhere"*
- *"which plugins are applied to this project?"*
- *"install matt pocock plugin in claude-plugins-official"*
- (I am swimming in plugins. This skill is a relief. 👈)

[`/grill-me`](skills/grill-me/SKILL.md)
- *"I'm not sure if I need to build an MCP for this..."*
- (Original first version from Matt Pocock, +formatting)

[`/vscode-config`](skills/vscode-config/SKILL.md)
- *"What is in my custom profiles?"*
- *"which profile is this project in?"*
- *"where are my keybindings?"*
- (Hardcodes my Windows/WSL paths — useless on any other machine)
