---
plugin: alwayson-misc
result: pass
---

# Manual Eval: `alwayson-misc` Plugin

Location: [`plugins/alwayson-misc`](../../plugins/alwayson-misc)

Test each in a new session:

```bash
# Test from the branch before merging
claude --plugin-dir ~/projects/my-claude-marketplace/plugins/alwayson-misc
```

## grill-me

*Tested 2026-08-17 · commit `178dabf` · Opus 5 xHigh*

> /grill-me "should I move my blog from WordPress to Next.js?"

Expected (confirm this):
- [x] Autocomplete offers `/grill-me`
- [x] `/gg-grilling` still shows, from installed git-utils 1.1.2 — gone after merge + `marketplace update`
- [x] Asks one question at a time, each with a recommended answer
- [x] Does not start any work; waits for confirmed shared understanding
- [x] Does not use the UserQ&A form (added `e7dfdb9`)

---

## uv-pep723

*Tested 2026-08-17 · commit `178dabf` · Opus 5 xHigh*

> Write me a throwaway script that lists the 5 largest files under ~/Downloads in a rich table, then run it.

Expected (confirm this):
- [x] Claude invokes the skill itself: a `Skill` call to `alwayson-misc:uv-pep723` appears
- [x] Creates with `uv init --script … --python 3.14`, then `uv add --script … rich`
- [x] File starts with a `# /// script` PEP 723 header listing `rich`
- [x] Runs it with `uv run <file>`; no `pip`, no `uv pip`

---

## manage-plugins

*Tested 2026-08-17 · commit `178dabf` · Opus 5 xHigh*

> Which plugins are enabled in this project, and how would I add the receipts plugin from the official marketplace?

Expected (confirm this):
- [x] Claude invokes the skill itself: a `Skill` call to `alwayson-misc:manage-plugins` appears
- [x] Runs `claude plugin list` (or reads `.claude/settings.json`) without a permission prompt
- [x] Reports `git-utils` and `pyright-lsp` as enabled for this project
- [x] Proposes `claude plugin install receipts@claude-plugins-official --scope project` and asks before running it
- [x] Does not volunteer `--scope user` or `--scope local` (changed `178dabf`)

> Actually, install it at user scope instead.

Expected (confirm this):
- [x] Complies: uses `--scope user` without arguing for project (added `4ea0262`)
- [x] Decline when it offers to run it, or clean up after with `claude plugin uninstall receipts@claude-plugins-official --scope user`

---

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
