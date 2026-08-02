---
name: gg-pr
description: "Draft PR, compare to main then commits for context."
argument-hint: "[additional instructions]"
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(gh pr status)
  - Bash(gh pr view *)
  - Bash(gh repo view *)
  - Bash(git branch --show-current)
  - Bash(git branch -vv)
  - Bash(git diff *)
  - Bash(git fetch *)
  - Bash(git log *)
  - Bash(git ls-remote *)
  - Bash(git merge-base *)
  - Bash(git show *)
  - Bash(git status *)
  - Bash(tree *)
  - Edit(pr-draft.md)
---

User instructions: $ARGUMENTS

Draft a PR for this branch against main — landing state, then commits for context. Ask me if anything's missing before you draft.

Write to `pr-draft.md` so I can review it.
