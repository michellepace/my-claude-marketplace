---
name: gg-commit
description: "Draft a plain, readable commit message"
argument-hint: "[additional instructions]"
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(echo *)
  - Bash(git diff *)
  - Bash(git log *)
  - Bash(git status *)
---

# Draft Git commit message

User instructions: $ARGUMENTS

Run `<command>` to read the staged changes, then draft the message per `<message>` and `<prefix>`. Present it in a fenced code block; don't commit. If nothing is staged, say so and stop.

<command>

```shell
echo "===STAGED===" && git diff --staged --compact-summary \
&& echo "===STAGED DETAILED===" && git diff --staged --diff-filter=d \
&& echo "===LAST COMMITS===" && git log --oneline -3
```
</command>

<message>
Write for a future reader of `git log`, often Claude, who will have the diff. The diff shows what changed; the message records why.

- Subject: `<prefix> <summary>`, imperative mood. Aim for ~50 characters, prefix included.
- Body: the motive, usually a sentence or two. Add a detail only when the diff can't show it, such as a constraint or a rejected alternative.
- Hard-wrap the body at 72 characters, bullets included.
- Crisp and professional; no filler.

Take the motive from this session and the user instructions. If it isn't clear, ask the user before drafting rather than guess.
</message>

<prefix>
Pick the prefix matching the commit's dominant purpose.

In `.claude/` or a plugin, files under `skills/`, `agents/`, `commands/`, `rules/`, or `hooks/` take that directory as prefix: `<dir>(<name>):` for one item, `<dir>:` for several — e.g. `skills(gg-commit):`, `agents:`. Otherwise:

- `rules:` sets Claude's behaviour: `CLAUDE.md` (anywhere)
- `docs:` `README.md`, any `*docs*/` (docs in code → `docs(code):`)
- `test:` adding or updating tests, e.g. `tests/**`
- `ci:` CI/CD pipelines, automated workflows
- `build:` build system, compilation, packaging
- `perf:` performance improvement
- `style:` formatting and linting; no functional change
- `refactor:` restructuring; neither fixes a bug nor adds a feature
- `fix:` bug fix
- `chore:` dev workflow, config (`settings.json`), dependencies, tooling
- `feat:` new user-facing functionality
</prefix>
