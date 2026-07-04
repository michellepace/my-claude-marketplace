---
name: gg-commit
description: "Create a plain, readable git commit message"
argument-hint: "optional instructions"
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(echo *)
  - Bash(git diff *)
  - Bash(git log *)
  - Bash(git status *)
---

# Write Git commit message

User instructions: $ARGUMENTS

Run the `<command>` to analyse files for commit. Craft a commit message; adjust `<style>` to fit the commit and choose a `<prefix>`. Do not commit.

---

<command>

```shell
echo "===STAGED===" && git diff --cached --compact-summary \
&& echo "===STAGED DETAILED===" && git diff --cached --diff-filter=d \
&& echo "===LAST COMMITS===" && git log --oneline -3
```
</command>

<style>
[prefix]: [imperative summary of the change]

[Body: explaining what and why rather than how. Default to short prose paragraphs; bullets / sections only when the commit bundles independent concerns. I can always read the diff — name the decision, not the edits that implement it]

[1 line for impact/benefit (skip if trivial)]
</style>

<prefix>

For files under `skills/`, `agents/`, `commands/`, `rules/`, or `hooks/` (in `.claude/` or a plugin), prefix with that directory: `<dir>(<name>):` for one, `<dir>:` for several. E.g. `skills(gg-commit):`, `agents:`. Otherwise:

- `rules:` sets Claude's behaviour: `CLAUDE.md` (anywhere)
- `test:` adding or updating tests e.g. `tests/**`
- `ci:` CI/CD pipeline changes, automated workflows, deployment automation
- `build:` build system changes, compilation process, how code gets packaged
- `perf:` performance improvements
- `fix:` bug fixes (fixes broken functionality)
- `refactor:` code changes that neither fix bugs nor add features
- `style:` formatting and linting fixes; no functional change
- `chore:` dev workflow, config (`settings.json`), dependency updates, dev tools
- `docs:` e.g. `README.md`, `docs/**`, `xdocs/**` (in code → `docs(code):`)
- `feat:` new feature for users (adds functionality)
</prefix>
