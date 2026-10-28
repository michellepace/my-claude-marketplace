---
skill: plugins/alwayson-misc/skills/vscode-profiles/SKILL.md
result: pass
---

# Manual Evals: `vscode-profiles`

Test each in a new session.

## vscode-profiles

*Tested 2026-08-31 · commit `14c98c8` · Opus 5 xHigh*

> /vscode-profiles "which profile is this project in, and which extensions are in it?"

Expected (confirm this):
- [x] Reports **Python**, from an exact registry match for this repo's directory
- [x] Lists all 14 extensions — matches `code --list-extensions` name-for-name
- [x] Flags `anthropic.claude-code` as app-scoped (active in every profile)

> /vscode-profiles "what is my effective setting for window.commandCenter?"

Expected (confirm this):
- [x] Answers `true`, citing both the Windows user `settings.json` and this repo's `.vscode/settings.json` (workspace wins)
- [x] Reads the Windows-side JSONC with no permission prompt (frontmatter `Read` rules)
