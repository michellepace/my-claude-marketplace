# Plugin: `git-utils`

**Git & GitHub workflows:** Commit messages, branch walkthroughs, PR drafts, CodeRabbit reviews, and post-merge cleanup — plus Grilling (not git).

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
| [`/gg-land-branch`](skills/gg-land-branch/SKILL.md) | Walk through where this branch landed against main, ignoring commit history |
| [`/gg-pr`](skills/gg-pr/SKILL.md) | Draft a PR against main into `pr-draft.md` for review |
| [`/gg-coderabbit`](skills/gg-coderabbit/SKILL.md) | Evaluate a CodeRabbit comment and recommend whether to action it |
| [`/gg-merge-cleanup`](skills/gg-merge-cleanup/SKILL.md) | Post-merge cleanup: switch to main, pull, delete merged branch, prune |
| [`/gg-grilling`](skills/gg-grilling/SKILL.md) | Get relentlessly grilled on your plan, decision, or idea |

## Usage Examples

**Commit:**

- `/gg-commit`
- `/gg-commit` "include the migration rationale"

**Branch walkthrough:**

- `/gg-land-branch`
- `/gg-land-branch` "don't diff on `*.md`, just the scripts"

**PR draft:**

- `/gg-pr`
- `/gg-pr` "flag the breaking config change in the summary"

**CodeRabbit:**

- `/gg-coderabbit` "<https://github.com/username/repo/pull/3#discussion_r3019655555>"

**Merge cleanup:**

- `/gg-merge-cleanup`

**Grilling:**

- `/gg-grilling` "stress-test my caching strategy"

## Dependencies

**gh CLI (required by gg-pr, gg-coderabbit and gg-merge-cleanup)** — used for GitHub API calls (fetching PR comments, resolving threads, checking remote status).
