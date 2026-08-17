---
plugin: my-conventions
branch: feat/my-conventions
tested-at-commit: 178dabf
tested-on: 2026-08-17
model: All evals with Opus 5 xHigh (default 95% of the time)
result: pass
---

# Manual Eval: `my-conventions` Plugin (3 Skills)

Location: [`plugins/my-conventions`](../../plugins/my-conventions)

All three must be opened in a new session, use:

```bash
# Test from the branch before merging
claude --plugin-dir ~/projects/my-claude-marketplace/plugins/my-conventions
```

## my-grilling

> /my-grilling "should I move my blog from WordPress to Next.js?"

Expected (confirm this):
- [x] Autocomplete offers `/my-grilling`
- [x] `/gg-grilling` still shows, from installed git-utils 1.1.2. Gone after merge + `marketplace update`
- [x] Asks one question at a time, each with a recommended answer
- [x] Does not start any work; waits for confirmed shared understanding
- [x] Does not try to use the UserQ&A form (added `e7dfdb9`)

---

## my-uv-pep723

> Write me a throwaway script that lists the 5 largest files under ~/Downloads in a rich table, then run it.

Expected (confirm this):
- [x] Claude invokes the skill itself: a `Skill` call to `my-conventions:my-uv-pep723` appears
- [x] Creates with `uv init --script … --python 3.14`, then `uv add --script … rich`
- [x] File starts with a `# /// script` PEP 723 header listing `rich`
- [x] Runs it with `uv run <file>`; no `pip`, no `uv pip`

---

## my-manage-plugins

> Which plugins are enabled in this project, and how would I add the receipts plugin from the official marketplace?

Expected (confirm this):
- [x] Claude invokes the skill itself: a `Skill` call to `my-conventions:my-manage-plugins` appears
- [x] Runs `claude plugin list` (or reads `.claude/settings.json`) without a permission prompt
- [x] Reports `git-utils` and `pyright-lsp` as enabled for this project
- [x] Proposes `claude plugin install receipts@claude-plugins-official --scope project` and asks before running it
- [x] Does not volunteer `--scope user` or `--scope local` (changed `178dabf`)

> Actually, install it at user scope instead.

Expected (confirm this):
- [x] Complies: uses `--scope user` without arguing for project scope (added `4ea0262`)
- [x] Decline when it offers to run it, or clean up after: `claude plugin uninstall receipts@claude-plugins-official --scope user`
