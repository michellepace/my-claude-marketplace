---
name: gg-land-branch
description: "Explain branch against main, no commit history"
argument-hint: "[don't diff on *.md, just ...]"
user-invocable: true
disable-model-invocation: true
---

# Walk me through where this branch landed

User instruction: `$ARGUMENTS`

Review the full diff of this branch against main and walk me through where it landed. Judge the end state only; ignore commit history.

I want to understand what changed and why it matters.

Write in ASD-STE100 Simplified Technical English. Use tables or lists where they carry the information better.
