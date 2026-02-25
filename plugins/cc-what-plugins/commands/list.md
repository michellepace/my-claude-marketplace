---
description: Show the state of Marketplaces and Plugins across all scopes
allowed-tools: Read(*)
context: fork
---

# Claude Code Marketplaces and Plugins

Show the user the state of Marketplaces and Plugins across all scopes.

## Step 1: Read these files

Use the Read tool on each file:

1. `~/.claude/plugins/known_marketplaces.json` — added marketplaces
2. `~/.claude/plugins/installed_plugins.json` — installed plugins (scope + project)
3. `~/.claude/settings.json` — user-scope enabledPlugins
4. `.claude/settings.json` — project-scope enabledPlugins
5. `.claude/settings.local.json` — local-scope enabledPlugins

## Step 2: Interpret the data

- **Marketplaces**: only "added" (no install/enable states)
- **Plugins**: must be both installed AND enabled
- If plugin not in `enabledPlugins`, it defaults to **enabled**
- If `enabledPlugins` has `"plugin@marketplace": false`, it's **disabled**

**Source of truth:**

- `installed_plugins.json` — definitive list of installed plugins
- `enabledPlugins` in settings — only controls enabled/disabled toggle
- Orphaned entries may linger in `enabledPlugins` after uninstalling plugins (safe to remove)

**Scope precedence** (highest → lowest):

1. `.claude/settings.local.json` (local) - highest
2. `.claude/settings.json` (project)
3. `~/.claude/settings.json` (user)

## Step 3: Present summary

Use this format (example data shown):

<format>

[Include emojies for readability]

### Added Marketplaces (3)

Sort table by: Source

| Source | Marketplace |
| :----- | :---------- |
| ✅ anthropics/skills | anthropic-agent-skills |
| ✅ anthropics/claude-plugins-official | claude-plugins-official |
| ✅ ~/projects/my-claude-marketplace | my-claude-marketplace |

### Installed Plugins by Project (6)

Sort table by: Project → Source → Plugin → Scope

| Project | Source | Plugin | Scope | Installed | Enabled |
| :------ | :----- | :----- | :---- | :-------- | :------ |
| *(all)* | ~/projects/my-claude-marketplace | cc-whats-new | user | ✅ | ✅ |
| devflow | anthropics/claude-plugins-official | code-review | project | ✅ | ✅ |
| devflow | anthropics/claude-plugins-official | feature-dev | project | ✅ | ✅ |
| devflow | anthropics/claude-plugins-official | pr-review-toolkit | project | ✅ | ✅ |
| devflow | ~/projects/my-claude-marketplace | shadcn-ui | project | ✅ | ❌ |
| docs-for-ai | anthropics/skills | example-skills | user | ✅ | ✅ |

</format>

Ensure accuracy. If unsure, tell the user.
