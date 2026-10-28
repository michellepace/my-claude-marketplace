---
title: uv-pep723 evals
skill: plugins/alwayson-misc/skills/uv-pep723/SKILL.md
skill-commit: b4b14c8
model: claude-opus-5 xhigh
result: pass
---

> Write me a throwaway script that lists the 5 largest files under ~/Downloads in a rich table, then run it.

Criteria:
- [x] Claude invokes the skill itself: a `Skill` call to `alwayson-misc:uv-pep723` appears
- [x] Creates with `uv init --script … --python 3.14`, then `uv add --script … rich`
- [x] File starts with a `# /// script` PEP 723 header listing `rich`
- [x] Runs it with `uv run <file>`; no `pip`, no `uv pip`
