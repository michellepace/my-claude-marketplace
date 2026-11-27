---
name: gg-commit
description: "Draft commit message for staged changes"
argument-hint: "[additional guidance]"
user-invocable: true
disable-model-invocation: true
---

# Draft Git commit message

Run `<command>` to read the staged changes, then draft the message per `<message>` and `<type>`. Present it in a fenced code block; don't commit. If nothing is staged, say so and stop.

<command>

```shell
echo "===STAGED===" && git diff --staged --compact-summary \
&& echo "===STAGED DETAILED===" && git diff --staged --diff-filter=d \
&& echo "===LAST COMMITS===" && git log --oneline -3
```

</command>

<message>
Write for Claude Code reading `git log` a month from now, trying to understand why this commit was made. Keep it tight and professional.

- Subject: `type: summary` (max. 55 chars). Imperative mood; name what changed, specific enough to stand alone in `git log --oneline`.
- Body: why the change was made, not a narration of the diff. Add only what the diff can't show: a constraint, a rejected alternative, or a deliberate choice a later reader might otherwise undo. Skip the body if the subject says it all.
- Hard-wrap the body at 72, bullets included.

Take the motive from this session and the additional guidance. If it isn't clear, ask before drafting.
</message>

<type>

Pick the commit's dominant purpose. Files Claude reads as instructions (`CLAUDE.md`, skills, agents, hooks) are typed like code, by their effect on Claude's behaviour.

- `docs:` READMEs, docs, code comments; not instructions Claude follows
- `test:` adding or updating tests
- `ci:` CI/CD pipelines
- `build:` build system, packaging
- `perf:` performance improvement
- `style:` formatting and linting; no functional change
- `refactor:` restructures or rewords; behaviour unchanged
- `fix:` corrects wrong behaviour
- `chore:` config (`settings.json`), dependencies, tooling
- `feat:` new capability

</type>

Additional guidance for this commit: $ARGUMENTS
