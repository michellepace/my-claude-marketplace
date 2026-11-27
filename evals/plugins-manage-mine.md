---
title: plugins-manage-mine evals
skill: plugins/alwayson-misc/skills/plugins-manage-mine/SKILL.md
skill-commit: d598ed6
flags: --model claude-opus-5-5 --effort medium --permission-mode auto
result: pass
---

> /plugins-manage-mine What plugins am I using in this project?

- [x] Lists only plugins that apply here, from all three scopes
- [x] Shows enabled and disabled, the winning scope, and overrides

> /plugins-manage-mine What marketplaces and plugins do I have on user scope?

- [x] Answers from `~/.claude/settings.json`, not the machine-wide lists

> /plugins-manage-mine How to add this plugin to my project https://github.com/thedotmack/claude-mem/

- [x] Claude provides the plugins available in this repo, asks to confirm
- [x] Gives `marketplace add` and `install <plugin>@thedotmack`, both `--scope project`

> /plugins-manage-mine Remove the productskills marketplace from this project

Start folder: a fresh scratch folder, set up first with
`claude plugin marketplace add assimovt/productskills --scope project` and
`claude plugin install product-skills@productskills --scope project`.

- [x] Runs `uninstall --scope project` for its plugin, not `marketplace remove`
- [x] Deletes `productskills` from `extraKnownMarketplaces` in `.claude/settings.json`

## Update everything, everywhere

> /plugins-manage-mine Update all my plugins, everything everywhere

- [x] Refreshes all marketplaces without asking first
- [x] Dry run gives correct record, plugin and project counts
- [x] Waits for my go-ahead before updating any record

> Go ahead.

- [x] Every record is updated or already at its latest version; none fail
- [x] Reports the tally and what moved (plugin, project, old → new)
