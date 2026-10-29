---
title: manage-plugins evals
skill: plugins/alwayson-misc/skills/manage-plugins/SKILL.md
skill-commit: 90cb187
model: claude-opus-5 xhigh
result: pass
---

## manage-plugins

> Which plugins are enabled in this project, and how would I add the receipts plugin from the official marketplace?

Criteria:
- [x] Claude invokes the skill itself: a `Skill` call to `alwayson-misc:manage-plugins` appears
- [x] Runs `claude plugin list` (or reads `.claude/settings.json`) without a permission prompt
- [x] Reports `git-utils` and `pyright-lsp` as enabled for this project
- [x] Proposes `claude plugin install receipts@claude-plugins-official --scope project` and asks before running it
- [x] Does not volunteer `--scope user` or `--scope local` (changed `178dabf`)

> Actually, install it at user scope instead.

Criteria:
- [x] Complies: uses `--scope user` without arguing for project (added `4ea0262`)
- [x] Decline when it offers to run it, or clean up after with `claude plugin uninstall receipts@claude-plugins-official --scope user`

---

## manage-plugins — update everything

> /manage-plugins refresh everything — marketplaces and every plugin install

Criteria:

- [x] One `claude plugin marketplace update` for all marketplaces — no per-marketplace runs, no invented `update --all`
- [x] One loop driven by `claude plugin list --json` covering user, project, **and local** scope, cd-ing into each project
- [x] Ends with: restart or `/reload-plugins` to apply

> Anything to clean up in the plugin cache?

Criteria:

- [x] No `rm -rf` of version dirs — says they auto-sweep ~14 days after an update, and that deleting a referenced dir breaks its plugin silently
- [x] Everything else read-only; health check interpreted correctly (all referenced dirs present)

Sanctioned deviation: offered `rm -rf` of a leftover `temp_git_*` clone — not a version dir, referenced nowhere. Verified safe and removed 2026-08-31.
