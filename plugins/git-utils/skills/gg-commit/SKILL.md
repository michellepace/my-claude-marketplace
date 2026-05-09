---
name: gg-commit
description: "Create git commit message following template"
argument-hint: "[additional instructions]"
user-invocable: true
disable-model-invocation: true
model: sonnet
allowed-tools:
  - Bash(git branch *)
  - Bash(git diff *)
  - Bash(git log *)
  - Bash(git status)
  - Read
---

# Create a clear Git commit message for **staged** changes

Additional user instructions: $ARGUMENTS

1. Analyse staged changes with commands in `<commit_context>` tags
2. Read and adhere to these rules in `<rules>` tags
3. Apply commit template `<template>` with appropriate `<main_prefix>`

<commit_context>
- Branch context: `git branch --show-current`
- Change volume: `git diff --cached --stat`
- Detailed changes: `git diff --cached --diff-filter=d`
- Recent commits (style anchor): `git log --oneline -8`

</commit_context>

<template>
[main_prefix]: [brief main summary in imperative mood]

[Section heading]:
- [Significant changes and impact over minor details]
- [Write for someone reading this git log in 6 months]

[Additional section (for multi-concern commits)]:
- [etc.]

[2-3 terse sentences of why / benefit / impact]

</template>

<main_prefix>

- `skill(<name>):` Skill changes e.g. `.claude/skills/<name>/**`, `plugins/<plugin>/skills/<name>/**`
- `plugin(<name>):` Plugin changes outside any single skill e.g. `plugins/<name>/**`, `.claude/plugins/<name>/**`
- `rule(<name>):` claude rule changes e.g. `.claude/rules/<name>/`
- `rules:` claude behavior rules e.g. `.claude/CLAUDE.md`, `.claude/settings.json`
- `test:` adding or updating tests e.g. `tests/**/*`
- `ci:` CI/CD pipeline changes, automated workflows, deployment automation
- `build:` build system changes, compilation process, how code gets packaged
- `perf:` performance improvements
- `fix:` bug fixes (fixes broken functionality)
- `refactor:` code changes that neither fix bugs nor add features
- `style:` code formatting, visual consistency, linting fixes; no functional change
- `chore:` dev workflow, workspace config, dependency updates, dev tools e.g. `.vscode/**`, `pyproject.toml`, `.gitignore`
- `docs:` documentation changes only e.g. `README.md`, `.xdocs/**`, `docs/**`
- `feat:` new feature for users (adds functionality)

Add `(<name>)` scope when a commit targets a single skill, plugin, or rule (e.g. `feat(find-font):`, `fix(gg-commit):`). Omit when changes span multiple.

</main_prefix>

<rules>
- Use British spelling
- Use factual tone - no hyperbole or marketing adjectives
- Scale detail to commit scope (sections not needed for small changes)
- Wrap text at 80-90 characters (NOT the git convention of 60-65)

</rules>
