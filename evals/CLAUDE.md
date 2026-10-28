# Manual Skill Evals

One eval file per skill, `<skill-name>.md`.

## Eval file format

Each `>` prompt is a case, run in a new session; prompts under one `##` heading share a session. General form:

```markdown
---
title: <skill-name> evals
skill: plugins/<plugin>/skills/<skill-name>/SKILL.md
skill-commit: <skill's latest commit at the time of the run>
model: <model-id> <effort>
result: <pass if every case met all its criteria, else fail>
---

> /<skill-name> "<prompt>"

Criteria:
- [ ] <criterion: concise, direct; checks behaviour, not exact wording>
```

## Running an eval

### By the user

If a user asks how to run an eval themselves:

1. `claude --plugin-dir ~/projects/my-claude-marketplace/plugins/<plugin>`
2. Paste the case's prompts in order.
