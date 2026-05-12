---
name: cc-shortcuts
description: Recommend Claude Code (VSCode) shortcut keys.
argument-hint: "Is there a shortcut key to...?"
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(grep *)
  - Bash(head *)
  - Bash(tail *)
  - Bash(wc *)
  - Glob
  - Grep
  - Read
---

# Recommend Claude Code Shortcut keys

From `$ARGUMENTS` ascertain what I am trying to achieve with a shortcut key. Determine if for Claude Code terminal window itself or VSCode etc. Confirm if unsure.

As a first reference, use my personal shortcut key notes: `${CLAUDE_SKILL_DIR}/references/shortcuts.md`

As a comprehensive fallback, Anthropic official docs: `${CLAUDE_SKILL_DIR}/references/interactive-mode.md`
