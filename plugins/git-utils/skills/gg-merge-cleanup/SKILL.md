---
name: gg-merge-cleanup
description: Post-merge cleanup: switch to main, pull, delete merged branch, prune
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(gh pr status)
  - Bash(gh pr view *)
  - Bash(gh repo view *)
  - Bash(git branch *)
  - Bash(git branch)
  - Bash(git checkout *)
  - Bash(git fetch *)
  - Bash(git pull)
  - Bash(git status)
---

## Context

- Current branch: !`git branch --show-current`
- All local branches: !`git branch`
- Remote branches: !`git branch -r`

## Task

The PR has been merged on GitHub, you need to clean up:

1. Switch to main branch
2. Pull latest changes
3. Delete the previous branch (the one shown above that is not main)
4. Prune stale remote-tracking references: `git fetch --prune`
5. Check both Git and GitHub to ensure clean status
6. Create narrow summary table with emojies to show everything is clean

If already on main with no other branches, just confirm everything is clean.
