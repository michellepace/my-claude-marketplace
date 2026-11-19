# Manual Skill Evals

An eval tests a skill with one prompt and its criteria (`- [ ]` checkboxes). A skill's evals live in one eval file, `<skill-name>.md`.

```shell
# Skills with eval files and their last run
grep -H -E '^(skill|skill-commit|flags|result):' --exclude=CLAUDE.md evals/*.md
```

## Eval file format

Each eval runs in a new session, except evals under one `##` heading, which share one session in order. General form:

```markdown
---
title: <skill-name> evals
skill: plugins/<plugin>/skills/<skill-name>/SKILL.md  # single-skill plugin: plugins/<plugin>/SKILL.md
skill-commit: <skill's latest commit at the time of the run>
flags: --model <model-id> --effort <effort> --permission-mode auto  # auto: evals test behaviour, not permissions
result: <pass if every eval met all its criteria, else fail>
---

> <prompt>

- [ ] <criterion: concise, direct; checks behaviour, not exact wording>
```

Write each `>` exactly as it will be sent. A skill:
- with `disable-model-invocation: true` is invoked as `/<skill-name> <args>` in a session's first prompt.
- without it can be tested with a plain request (no `/<skill-name>`); whether Claude picks it up depends on the skill's `description:`, and can be a criterion.

Later prompts in a session can be plain, but they don't get the skill's `allowed-tools`, so in `manual` mode they may be denied.

## Running an eval

### By the user

If a user asks how to run an eval themselves:

1. `claude --plugin-dir ~/projects/my-claude-marketplace/plugins/<plugin> <flags>`
2. Paste each eval's prompt, starting a new session unless the evals share a `##`.

### By Claude

If asked to run an eval yourself, run each eval non-interactively (`-p`).

1. **Start directory:** a fresh directory in your scratchpad, one per session, unless the eval file names one.
2. **Run the first prompt,** copied verbatim from its `>` line:

   ```shell
   cd <start-dir> && claude -p "<prompt>" \
     --plugin-dir ~/projects/my-claude-marketplace/plugins/<plugin> \
     <flags> --allowedTools "Skill" \
     --output-format stream-json --verbose \
     < /dev/null > transcript.jsonl 2> stderr.txt
   ```

   | Flag | Why | When to deviate |
   | :--- | :--- | :--- |
   | `--plugin-dir` | Loads the plugin from this working copy, not the installed cache | Never |
   | `<flags>` | The eval file's `flags:`, exactly; if empty, ask | When asked |
   | `--allowedTools "Skill"` | Required for plain requests, harmless for `/name` | Never |
   | `--output-format stream-json --verbose` | Tool calls land in the transcript, for step 3 | Never |
   | `< /dev/null` | Skips the 3s wait for stdin | Never |

   More flags: `claude -p --help`.

3. **Check the run is valid** before judging criteria:

   ```shell
   jq -c 'select(.type=="system" and .subtype=="init") | {model, permissionMode}' transcript.jsonl
   jq -r 'select(.type=="assistant") | .message.content[] | select(.type=="tool_use") | "\(.name): \(.input.skill // .input.command // .input.file_path)"' transcript.jsonl
   jq -c 'select(.type=="result") | {session_id, permission_denials, result}' transcript.jsonl
   ```

   Claude can recover from `permission_denials`, sometimes it's better to fix the skill.

4. **Follow-up prompts** in the same `##` session: rerun step 2's command with `--resume <session_id>` (from the `result` line) and the next prompt, using `>>` and `2>>` so the new turn is added to the transcript instead of replacing it.
5. **Report** pass or fail per criterion, with evidence from the transcript, ending with `🧪 Ran with: <flags>`. Ask before ticking criteria or updating the frontmatter: `skill-commit` is `git log -1 --format=%h -- <skill dir>`.

References:
- [Non-interactive mode](https://code.claude.com/docs/en/headless.md) — fetch with `curl`
