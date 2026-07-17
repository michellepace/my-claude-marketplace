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

Run `<command>` to analyse the staged changes. Choose a `<prefix>`, draft
the message per `<format>`, and present it in a fenced code block — do not
commit. If nothing is staged, say so and stop.

---

<command>

```shell
echo "===STAGED===" && git diff --staged --compact-summary \
&& echo "===STAGED DETAILED===" && git diff --staged --diff-filter=d \
&& echo "===LAST COMMITS===" && git log --oneline -3
```
</command>

<format>
Wrap at 72 characters; for a trivial commit, prefix and subject only.
Write concisely and plainly.

```text
<prefix> <subject — imperative mood>

<body — why over what: if a reader of the diff would learn nothing
new from a line, it doesn't belong. Short prose paragraph(s),
bullets when it helps clarity.>
```
</format>

<prefix>
Pick the prefix matching the commit's dominant purpose.

In `.claude/` or a plugin, files under `skills/`, `agents/`,
`commands/`, `rules/`, or `hooks/` take that directory as prefix:
`<dir>(<name>):` for one item, `<dir>:` for several — e.g.
`skills(gg-commit):`, `agents:`. Otherwise:

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
