---
name: cc-peak-ctx-analyse
description: Analyse peak context-window usage across recent Claude Code sessions to spot interesting patterns.
argument-hint: "[today | last N days | all]. [questions / analysis focus]"
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(peak-ctx.sh *)
  - Bash(awk *)
  - Bash(column *)
  - Bash(cp *)
  - Bash(cut *)
  - Bash(echo *)
  - Bash(grep *)
  - Bash(head *)
  - Bash(jq *)
  - Bash(rm peak-ctx.tsv)
  - Bash(sort *)
  - Bash(tail *)
  - Bash(uniq *)
  - Bash(uv run *)
  - Bash(wc *)
  - Edit
  - Glob
  - Grep
  - Read
  - Write
---

Help the user understand their Claude Code sessions — peak context usage by default, or whatever focus they request. Deliver an analysis report with pragmatic key insights.

## Step 1: Orient

Run and read: `peak-ctx.sh --help`

From `$ARGUMENTS` derive a `<window-flag>` (today / last-N-days / all) and optional analysis focus. If unsure, confirm the brief with the user 🙂.

Run:

```bash
# 1. Create data file
peak-ctx.sh <window-flag>

# 2. Shape and size
head -5 peak-ctx.tsv && echo && wc -l peak-ctx.tsv && echo

# 3. Baseline numerical overview
uv run ${CLAUDE_SKILL_DIR}/templates/report-template.py
```

## Step 2: Analyse

If `$ARGUMENTS` includes a focus, prioritise it.

Explore the data to spot patterns worth reporting on. For session-level deep-dives, see "## Appendix: Inspect a Session".

## Step 3: Build the Report

The Step 1 baseline oriented you. Now fork the template and tailor it to the patterns you uncovered.

```bash
cp ${CLAUDE_SKILL_DIR}/templates/report-template.py peak-ctx-report.py
```

Extend this template creatively inline with uncovered patterns and user focus. Iteratively refine and validate, use `uv run peak-ctx-report.py`. If a new key pattern emerges, feel free to iterate again.

## Step 4: Distil & Discuss

Run `uv run peak-ctx-report.py` one final time. Then distil the key insights below the output and invite conversation:

<format_guide>

## 📊 Re-run
To re-run the analysis report, run: `uv run peak-ctx-report.py`

---

## 🎯 Key Insights
[Distilled insights]

---

## 🤔 Follow-up Questions?
[suggest 3 useful / relevant questions for the user to ask]

---

</format_guide>

Rules:
- Don't overwhelm: leverage report and distill key insights
- Use emojis for readability, 1-2 narrow tables only if they add clarity in addition to report output.

## Appendix: Inspect a Session

Query `session_file` with `jq` (JSONL, dispatched on `.type`). Common fields:

<subset_session_fields>

- `user.message.content` — string (prompt or synthetic) OR array of `tool_result`/`text` blocks
- `assistant.message.content[]` — `text`, `thinking`, or `tool_use` (tool_use has `.name`)
- `assistant.message.usage` — `input_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens`, `output_tokens` per turn
- `last-prompt.lastPrompt` — most-recent user prompt (not guaranteed)
- top-level on user/assistant/system lines: `cwd`, `gitBranch`, `timestamp`

⚠️ User strings often wrap synthetic content — filter these out for real prompts:
`<command-name>`, `<command-args>`, `<command-message>`, `<local-command-caveat>`, `<local-command-stdout>`.

If a key seems missing: `jq -c 'select(.type=="<T>") | keys' <session_file> | head -1`

Use `grep` etc. as beneficial.

</subset_session_fields>
