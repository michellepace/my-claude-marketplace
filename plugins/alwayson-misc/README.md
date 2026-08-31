# Plugin: `alwayson-misc`

A Plugin of miscellaneous Skills that I always keep on. They hardcode my own preferences and machine. Tested, see eval sheet: [`eval-manual.md`](../../xdocs/alwayson-misc/eval-manual.md).

Add and install (user scope):

```bash
claude plugin marketplace add michellepace/my-claude-marketplace --scope user
claude plugin install alwayson-misc@my-claude-marketplace        --scope user
```

Context-preserving to install at user scope (global). Only `/uv-pep723` auto-invokes and loads into Claude's context window. Better as a versioned Plugin that keeps `CLAUDE.md` slim.

## What's Inside

| Run Skill | What it does | Auto-invokes |
| :-------- | :----------- | :----------- |
| [`/grill-me`](skills/grill-me/SKILL.md) | Get grilled on an idea to thrash it out | No |
| [`/manage-plugins`](skills/manage-plugins/SKILL.md) | Manage Claude plugins and marketplaces | No |
| [`/uv-pep723`](skills/uv-pep723/SKILL.md) | Make standalone uv Python scripts | **YES** |
| [`/vscode-profile`](skills/vscode-profiles/SKILL.md) | Answer VS Code profile questions | No |

## Usage Examples

[`/manage-plugins`](skills/manage-plugins/SKILL.md)
- *"for my plugins, update everything, everywhere"*
- *"which plugins are applied to this project?"*
- *"install matt pocock plugin in claude-plugins-official"*
- (I am swimming in plugins. This skill is a relief. 👈)

[`/uv-pep723`](skills/uv-pep723/SKILL.md)
- *"use python + rich to visualise data.tsv (Edward Tufte: show me the numbers!)"*
- *"make me a throwaway script to plot this CSV"*

[`/grill-me`](skills/grill-me/SKILL.md)
- *"I'm not sure if I need to build an MCP for this..."*
- (Original first version from Matt Pocock, +formatting)

[`/vscode-profile`](skills/vscode-profiles/SKILL.md)
- *"What is in my custom profiles?"*
- *"which profile is this project in?"*
- (Hardcodes my Windows/WSL paths and profile hashes — useless on any other machine)
