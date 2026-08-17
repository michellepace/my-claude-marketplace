# Plugin: `my-conventions`

This is more for me than for you. The Skills contain my preferences and conventions. If you use any of these, read through each top to bottom to modify.

✅ Tested by hand. See the eval sheet: [`eval-manual.md`](../../xdocs/my-conventions/eval-manual.md).

Add and install (user scope):

```bash
claude plugin marketplace add michellepace/my-claude-marketplace --scope user
claude plugin install my-conventions@my-claude-marketplace       --scope user
```

## What's Inside

| Run Skill | What it does | Auto-invokes |
| :-------- | :----------- | :----------- |
| [`/my-manage-plugins`](skills/my-manage-plugins/SKILL.md) | Manage Claude plugins and marketplaces | Yes |
| [`/my-uv-pep723`](skills/my-uv-pep723/SKILL.md) | Make standalone uv Python scripts | Yes |
| [`/my-grilling`](skills/my-grilling/SKILL.md) | Get grilled on an idea to thrash it out | No |

## Usage Examples

[`/my-manage-plugins`](skills/my-manage-plugins/SKILL.md)
- *"for my plugins, update everything, everywhere"*
- *"which plugins are applied to this project?"*
- *"install matt pocock plugin in claude-plugins-official"*

[`/my-uv-pep723`](skills/my-uv-pep723/SKILL.md)
- *"use python + rich to visualise data.tsv (Edward Tufte: show me the numbers!)"*
- *"make me a throwaway script to plot this CSV"*

[`/my-grilling`](skills/my-grilling/SKILL.md)
- *"I'm not sure if I need to build an MCP for this..."*
- (Original first version from Matt Pocock, +formatting)

## Why This Plugin Exists

`~/.claude/CLAUDE.md` loads into every session, so it has to stay slim. These conventions used to live there. Now they live here, versioned and visible. It's one of the two global plugins I have; everything else is at project scope.

I am swimming in plugins, `/my-manage-plugins` is wonderfully liberating.
