---
title: manage-plugins evals
skill: plugins/alwayson-misc/skills/manage-plugins/SKILL.md
skill-commit:
flags:
result:
---

> /manage-plugins What plugins am I using in this project?

Criteria:
- [ ] Lists only plugins that apply here, from all three scopes
- [ ] Shows enabled and disabled, the winning scope, and overrides

> /manage-plugins What marketplaces and plugins do I have on user scope?

Criteria:
- [ ] Answers from `~/.claude/settings.json`, not the machine-wide lists

> /manage-plugins How to add this plugin to my project https://github.com/thedotmack/claude-mem/

Criteria:
- [ ] Claude provides the plugins available in this repo, asks to confirm
- [ ] Gives `marketplace add` and `install <plugin>@thedotmack`, both `--scope project`

> /manage-plugins Remove the productskills marketplace from this project

Start folder: a fresh scratch folder, set up first with
`claude plugin marketplace add assimovt/productskills --scope project` and
`claude plugin install product-skills@productskills --scope project`.

Criteria:
- [ ] Runs `uninstall --scope project` for its plugin, not `marketplace remove`
- [ ] Deletes `productskills` from `extraKnownMarketplaces` in `.claude/settings.json`

## Update everything, everywhere

> /manage-plugins Update all my plugins, everything everywhere

Criteria:
- [ ] Refreshes all marketplaces without asking first
- [ ] Dry run gives correct record, plugin and project counts
- [ ] Waits for my go-ahead before updating any record

> Go ahead.

Criteria:
- [ ] Every record is updated or already at its latest version; none fail
- [ ] Reports the tally and what moved (plugin, project, old → new)
