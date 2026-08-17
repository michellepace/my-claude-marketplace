# Plugin: `my-conventions`

**Personal working conventions, installed everywhere:** the defaults I want in every Claude Code session, whatever the project. Standalone Python scripts with uv, plugin management at project scope, and grilling.

Add marketplace and install this plugin (project scope):

```bash
# 1. Add Marketplace
claude plugin marketplace add michellepace/my-claude-marketplace --scope project

# 2. Install Plugin "my-conventions"
claude plugin install my-conventions@my-claude-marketplace --scope project
```

✅ Tested by hand before merge, see the eval sheet: [`eval-manual.md`](../../xdocs/my-conventions/eval-manual.md).

## What's Inside

| Run Skill | What it does |
| :-------- | :----------- |
| [`/my-manage-plugins`](skills/my-manage-plugins/SKILL.md) | Manage Claude plugins and marketplaces, always at project scope. Auto-triggers |
| [`/my-uv-pep723`](skills/my-uv-pep723/SKILL.md) | uv + PEP 723 conventions for standalone Python scripts |
| [`/my-grilling`](skills/my-grilling/SKILL.md) | Get relentlessly grilled on your plan, decision, or idea |

## Usage Examples

**Plugins:**

- `/my-manage-plugins` install the receipts plugin from the official marketplace
- Or just ask: "which plugins are enabled in this project?" (Claude picks the skill up itself)

**Standalone Python script:**

- `/my-uv-pep723` write a script that dedupes lines in a file
- Or just ask: "make me a throwaway script to plot this CSV" (Claude picks the skill up itself)

**Grilling:**

- `/my-grilling` "stress-test my caching strategy"

## Why This Plugin Exists

`~/.claude/CLAUDE.md` loads into every session, so it has to stay slim. These conventions used to live there. Now they live here, versioned and shareable.

A skill costs nothing until it is invoked. The one exception is a skill Claude may trigger on its own: its one-line description sits in context, and its body loads only when needed. Either way, cheaper than a paragraph in CLAUDE.md.

## Dependencies

**uv (required by my-uv-pep723)**: the skill runs `uv init --script`, `uv add --script` and `uv run`.

**Local uv docs (optional, my-uv-pep723)**: for uv questions the skill cannot answer it reads `~/projects/python/docs-for-ai/collections/uv/INDEX.xml`, a local docs collection. Without it, the skill still works from what it knows.
