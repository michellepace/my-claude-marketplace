---
title: vscode-profiles evals
skill: plugins/alwayson-misc/skills/vscode-profiles/SKILL.md
skill-commit: 14c98c8
model: claude-opus-5 xhigh
result: pass
---

**Start directory:** this repo's root, not a fresh one, run from its VS Code terminal. The repo's own profile, extensions and settings are the test data.

> /vscode-profiles which profile is this project in, and which extensions are in it?

Criteria:
- [x] Reports the profile `storage.json` records for this repo's directory, as an exact match
- [x] Lists the same extensions as `code --list-extensions`
- [x] Flags `anthropic.claude-code` as app-scoped (active in every profile)

> /vscode-profiles what is my effective setting for window.commandCenter?

Criteria:
- [x] Answers from both the Windows user `settings.json` and this repo's `.vscode/settings.json`, with workspace winning
