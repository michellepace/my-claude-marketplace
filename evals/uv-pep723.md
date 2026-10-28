---
skill: plugins/alwayson-misc/skills/uv-pep723/SKILL.md
result: pass
---

# Manual Evals: `uv-pep723`

Test each in a new session.

## uv-pep723

*Tested 2026-08-17 · commit `178dabf` · Opus 5 xHigh*

> Write me a throwaway script that lists the 5 largest files under ~/Downloads in a rich table, then run it.

Expected (confirm this):
- [x] Claude invokes the skill itself: a `Skill` call to `alwayson-misc:uv-pep723` appears
- [x] Creates with `uv init --script … --python 3.14`, then `uv add --script … rich`
- [x] File starts with a `# /// script` PEP 723 header listing `rich`
- [x] Runs it with `uv run <file>`; no `pip`, no `uv pip`
