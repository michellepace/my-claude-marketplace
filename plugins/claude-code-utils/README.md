# Plugin: `claude-code-utils`

**Claude Code visibility & discovery:** Understand what is new in Claude Code from the changelog. Know which plugins you have installed and where.

Add marketplace and install this plugin (project scope):

```bash
# 1. Add Marketplace
claude plugin marketplace add michellepace/my-claude-marketplace --scope project

# 2. Install Plugin "claude-code-utils"
claude plugin install claude-code-utils@my-claude-marketplace --scope project
```

## 🟣 What's Inside

| Run Skill | Description |
|:------|:------------|
| [`/cc-which-plugins`](skills/cc-which-plugins/SKILL.md) | Show all marketplaces and plugins with their status |
| [`/cc-whats-new-changelog`](skills/cc-whats-new-changelog/SKILL.md) | Analyse changelog and explain features practically |

---

## 🟣 Skill: cc-which-plugins

Shows the state of Marketplaces and Plugins across all scopes, with a focus on what's active in the current project.

Run:

```
/cc-which-plugins
```

### Sample Output

<div align="center">
  <a href="images/cc-which-plugins.jpg" target="_blank">
    <img src="images/cc-which-plugins.jpg" alt="cc-which-plugins skill output: tables showing added marketplaces, plugins installed at local, project, and user scopes with source repo, plugin name, version, and health status, followed by an effective-plugins summary for the current project listing each plugin's scope, version, enabled state, and health.">
  </a>
</div>

---

## 🟣 Skill: cc-whats-new-changelog

Explains what's new in Claude Code changelog with practical examples you can use immediately.

Run:

```
/cc-whats-new-changelog         # Summary table first
/cc-whats-new-changelog 2.1.2   # Exact version only
/cc-whats-new-changelog 2.1     # All 2.1.* versions
```

### Sample Output

Specify any version within in range and have it explained. The skill then launches the  `claude-code-guide` subagent for rich, practical explanations with examples and doc links.

<div align="center">
  <a href="images/cc-whats-new-changelog.jpg" target="_blank">
    <img src="images/cc-whats-new-changelog.jpg" alt="Screenshot of the cc-whats-new-changelog skill running in Claude Code. It displays a summary table of the latest 8 Claude Code versions (2.1.88 to 2.1.97) with columns for Version, Released date, Items count, and Changes at a Glance. The skill reports 87 total versions and prompts the user to pick a version, timeframe, or range to explain in detail.">
  </a>
</div>
