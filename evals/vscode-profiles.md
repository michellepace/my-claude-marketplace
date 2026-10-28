---
title: vscode-profiles evals
skill: plugins/alwayson-misc/skills/vscode-profiles/SKILL.md
skill-commit: 14c98c8
model: claude-opus-5 xhigh
result: pass
---

> /vscode-profiles "which profile is this project in, and which extensions are in it?"

Criteria:
- [x] Reports **Python**, from an exact registry match for this repo's directory
- [x] Lists all 14 extensions — matches `code --list-extensions` name-for-name
- [x] Flags `anthropic.claude-code` as app-scoped (active in every profile)

> /vscode-profiles "what is my effective setting for window.commandCenter?"

Criteria:
- [x] Answers `true`, citing both the Windows user `settings.json` and this repo's `.vscode/settings.json` (workspace wins)
- [x] Reads the Windows-side JSONC with no permission prompt (frontmatter `Read` rules)
