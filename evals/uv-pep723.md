---
title: uv-pep723 evals
skill: plugins/uv-pep723/SKILL.md
skill-commit: fb7d927
model: claude-opus-5-5 medium
result: pass
---

> Write me a throwaway script that lists the 5 largest files under ~/Downloads in a rich table, then run it.

Criteria:
- [x] Claude invokes the skill itself: a `Skill` call to `uv-pep723:uv-pep723` appears
- [x] Creates with `uv init --script`, then `uv add --script … rich`
- [x] The saved script has a PEP 723 header listing `rich`
- [x] Runs it with `uv run <file>`; no `pip`, no `uv pip`
