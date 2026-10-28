---
name: gg-commit
description: "Draft commit message for staged changes"
argument-hint: "[additional guidance]"
user-invocable: true
disable-model-invocation: true
---

# Draft Git commit message

Run `<command>` to read the staged changes, then draft the message per `<message>` and `<prefix>`. Present it in a fenced code block; don't commit. If nothing is staged, say so and stop.

<command>

```shell
echo "===STAGED===" && git diff --staged --compact-summary \
&& echo "===STAGED DETAILED===" && git diff --staged --diff-filter=d \
&& echo "===LAST COMMITS===" && git log --oneline -3
```

</command>

<message>
Write for Claude Code, which later reads `git log` to learn why a change was made. The diff shows what changed; the message records why, in just enough words.

- Subject: `<prefix> <summary>`, imperative mood. Aim for ~50 characters, prefix included; go a few over rather than drop a word that carries meaning.
- Body: the motive, usually a sentence or two. Don't restate what the diff shows; record what it can't: a constraint, a rejected alternative, or a deliberate choice a later reader might otherwise undo.
- Hard-wrap the body at 72 characters, bullets included.

Take the motive from this session and the additional guidance. If it isn't clear, ask me before drafting rather than guess.
</message>

<prefix>
Use Conventional Commits. The type is the commit's dominant purpose; the scope is the most specific name covering the whole change (e.g. a skill, plugin or module), omitted when nothing narrower fits.

Skills, agents, commands, hooks and `CLAUDE.md` are instructions Claude follows: type them like code, by their effect on Claude's behaviour.

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
</prefix>

Additional guidance for this commit: $ARGUMENTS
