---
name: gg-commit
description: "Create git commit message in git-project style"
argument-hint: "[additional instructions]"
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(git branch *)
  - Bash(git diff *)
  - Bash(git log *)
  - Bash(git status)
  - Read
---

# Write Git commit message

Additional user instructions: $ARGUMENTS

1. Analyse staged changes with commands in `<commit_context>` tags
2. Write per `<style>`, with a subject prefix from `<main_prefix>`,
   following `<rules>`
3. Present to user and always await confirmation to commit

<commit_context>
- Branch context: `git branch --show-current`
- Change volume: `git diff --cached --compact-summary`
- Detailed changes: `git diff --cached --diff-filter=d`
- Recent subjects (prefix consistency): `git log --oneline -4`
</commit_context>

<style>
Git-project convention (git.git's own history): a prefixed subject plus one or
two short prose paragraphs of what-and-why — no sections, no bullets.

[main_prefix]: [brief main summary in imperative mood]

[1-3 sentences: what changed at intent level and why — the problem with the
code before, or what this enables]

[Optional 1-2 sentences: contrast with previous behaviour, a non-obvious
consequence, or what was deliberately kept when removal might be assumed]

[5-20 words: concise value/benefit clinch]

The reader has the diff; the message exists so they can decide whether to open
it. Name the decision, not the edits that implement it.

Exception: a commit bundling genuinely independent concerns (ones a reader
would care about separately) gets one short paragraph per concern, or a terse
bullet list per concern if prose turns awkward.
</style>

<main_prefix>

- `rules:` claude behaviour rules e.g. `CLAUDE.md`, `.claude/settings.json`
- `test:` adding or updating tests e.g. `tests/**/*`
- `ci:` CI/CD pipeline changes, automated workflows, deployment automation
- `build:` build system changes, compilation process, how code gets packaged
- `perf:` performance improvements
- `fix:` bug fixes (fixes broken functionality)
- `refactor:` code changes that neither fix bugs nor add features
- `style:` formatting and linting fixes; no functional change
- `chore:` dev workflow, workspace config, dependency updates, dev tools
- `docs:` documentation changes only e.g. `README.md`, `.xdocs/**`, `docs/**`
- `feat:` new feature for users (adds functionality)

Add `(<name>)` scope when a commit targets a single skill, plugin, or rule.
Omit when changes span multiple.
</main_prefix>

<rules>
- Use British spelling
- Use factual tone - no hyperbole or marketing adjectives
- Wrap text at 80 characters (NOT the git convention of 60-65)
</rules>
