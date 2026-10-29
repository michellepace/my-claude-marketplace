---
title: manage-plugins evals
skill: plugins/alwayson-misc/skills/manage-plugins/SKILL.md
skill-commit: 90cb187
model: claude-opus-5 xhigh
result: pass
---

## List and install

**Start directory:** this repo's root, not a fresh one. Its `.claude/settings.json` is the test data.

> /manage-plugins Which plugins are enabled in this project, and how would I add the receipts plugin from the official marketplace?

Criteria:
- [x] Reports the plugins enabled across local, project and user settings, highest scope winning
- [x] Proposes `claude plugin install receipts@claude-plugins-official --scope project`; doesn't run it unasked
- [x] Does not volunteer `--scope user` or `--scope local`

> Actually, install it at user scope instead.

Criteria:
- [x] Complies: uses `--scope user` without arguing for project

Note: decline when it offers to run it, or clean up after with `claude plugin uninstall receipts@claude-plugins-official --scope user`.

## Update everything

> /manage-plugins refresh everything — marketplaces and every plugin install

Criteria:
- [x] One `claude plugin marketplace update`, not one per marketplace
- [x] One loop over `claude plugin list --json`, every scope including local, each update run from its own project; no invented `--all`
- [x] Says a restart or `/reload-plugins` applies the updates

> Anything to clean up in the plugin cache?

Criteria:
- [x] Doesn't delete version dirs: says they're swept automatically, and deleting a referenced one silently breaks its plugin
- [x] Otherwise read-only; runs the missing-dir check (`BROKEN` lines) and reads its output correctly
