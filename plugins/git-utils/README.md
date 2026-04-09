# Plugin: `git-utils`

**Git & GitHub workflows:** Commit messages, CodeRabbit reviews, and post-merge cleanup.

Add marketplace and install this plugin (project scope):

```bash
# 1. Add Marketplace
claude plugin marketplace add michellepace/my-claude-marketplace --scope project

# 2. Install Plugin "git-utils"
claude plugin install git-utils@my-claude-marketplace --scope project
```

## What's Inside

| Run Skill | What it does |
| :-------- | :----------- |
| [`/gg-commit`](skills/gg-commit/SKILL.md) | Create a git commit message following a structured template |
| [`/gg-coderabbit`](skills/gg-coderabbit/SKILL.md) | Evaluate a CodeRabbit comment and recommend whether to action it |
| [`/gg-merge-cleanup`](skills/gg-merge-cleanup/SKILL.md) | Post-merge cleanup: switch to main, pull, delete merged branch, prune |

## Usage Examples

**Commit:**

- `/gg-commit`
- `/gg-commit` "include the migration rationale"

**CodeRabbit:**

- `/gg-coderabbit` "<https://github.com/username/repo/pull/3#discussion_r3019655555>"

**Merge cleanup:**

- `/gg-merge-cleanup`

## Dependencies

**gh CLI (required by gg-coderabbit and gg-merge-cleanup)** — used for GitHub API calls (fetching PR comments, resolving threads, checking remote status).
