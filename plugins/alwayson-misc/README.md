# Plugin: `alwayson-misc`

A Plugin of miscellaneous Skills that I always keep on. They hardcode my own preferences and machine.

Add and install (user scope):

```bash
claude plugin marketplace add michellepace/my-claude-marketplace --scope user
claude plugin install alwayson-misc@my-claude-marketplace        --scope user
```

Context-preserving to install at user scope (global). No skill auto-invokes, so none loads into Claude's context window until run. Better as a versioned Plugin that keeps `CLAUDE.md` slim.

The auto-invoking uv skill lives in its own plugin, [`uv-pep723`](../uv-pep723), to install only where wanted.

## What's Inside

| Run Skill | What it does |
| :-------- | :----------- |
| [`/grill-me`](skills/grill-me/SKILL.md) | Get grilled on an idea to thrash it out |
| [`/manage-plugins`](skills/manage-plugins/SKILL.md) | Manage Claude plugins and marketplaces |
| [`/vscode-config`](skills/vscode-config/SKILL.md) | Answer VS Code config questions |

## Usage Examples

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
