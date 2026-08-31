# Plugin: `alwayson-misc`

A Plugin with miscellaneous Skills but of which I always have on. They hardcode my own preferences.

✅ Tested by hand, see eval sheet: [`eval-manual.md`](../../xdocs/alwayson-misc/eval-manual.md).

Add and install (user scope):

```bash
claude plugin marketplace add michellepace/my-claude-marketplace --scope user
claude plugin install alwayson-misc@my-claude-marketplace        --scope user
```

## What's Inside

| Run Skill | What it does | Auto-invokes |
| :-------- | :----------- | :----------- |
| [`/manage-plugins`](skills/manage-plugins/SKILL.md) | Manage Claude plugins and marketplaces | Yes |
| [`/uv-pep723`](skills/uv-pep723/SKILL.md) | Make standalone uv Python scripts | Yes |
| [`/grill-me`](skills/grill-me/SKILL.md) | Get grilled on an idea to thrash it out | No |
| [`/vscode-profile`](skills/vscode-profiles/SKILL.md) | Answer VS Code profile questions — my machine only | No |

## Usage Examples

[`/manage-plugins`](skills/manage-plugins/SKILL.md)
- *"for my plugins, update everything, everywhere"*
- *"which plugins are applied to this project?"*
- *"install matt pocock plugin in claude-plugins-official"*

[`/uv-pep723`](skills/uv-pep723/SKILL.md)
- *"use python + rich to visualise data.tsv (Edward Tufte: show me the numbers!)"*
- *"make me a throwaway script to plot this CSV"*

[`/grill-me`](skills/grill-me/SKILL.md)
- *"I'm not sure if I need to build an MCP for this..."*
- (Original first version from Matt Pocock, +formatting)

[`/vscode-profile`](skills/vscode-profiles/SKILL.md)
- *"what are in my custom profiles?"*
- *"which profile is this project in?"*
- (Hardcodes my Windows/WSL paths and profile hashes — useless on any other machine)

## Why This Plugin Exists

`~/.claude/CLAUDE.md` loads into every session, so it has to stay slim. Most of this used to live there; now it lives here, versioned and visible. It is one of my two always-on plugins — everything else is project scope.

I am swimming in plugins; `/manage-plugins` is wonderfully liberating.
