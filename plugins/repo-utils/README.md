# Plugin: `repo-utils`

**Git & GitHub workflows:** Commit messages, CodeRabbit reviews, and post-merge cleanup.

To install this plugin:

```
# 1. Add marketplace if not already
/plugin marketplace add michellepace/my-claude-marketplace

# 2. Install this plugin
/plugin install repo-utils@my-claude-marketplace
```

## What's Inside

| Run Skill | What it does |
| :-------- | :----------- |
| [`/repo-commit`](skills/repo-commit/SKILL.md) | Create a git commit message following a structured template |
| [`/repo-coderabbit`](skills/repo-coderabbit/SKILL.md) | Evaluate a CodeRabbit comment and recommend whether to action it |
| [`/repo-merge-cleanup`](skills/repo-merge-cleanup/SKILL.md) | Post-merge cleanup: switch to main, pull, delete merged branch, prune |

## Usage Examples

**Commit:**

- `/repo-commit`
- `/repo-commit` "include the migration rationale"

**CodeRabbit:**

- `/repo-coderabbit` "<https://github.com/username/repo/pull/3#discussion_r3019655555>"

**Merge cleanup:**

- `/repo-merge-cleanup`

## Dependencies

**gh CLI (required by repo-coderabbit and repo-merge-cleanup)** — used for GitHub API calls (fetching PR comments, resolving threads, checking remote status).
