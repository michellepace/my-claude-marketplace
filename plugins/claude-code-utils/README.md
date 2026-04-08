# Plugin: `claude-code-utils`

**Claude Code visibility & discovery:** Understand what is new in Claude Code from the changelog. Know which plugins you have installed and where.

To install this plugin:

```
# 1. Add marketplace if not already
/plugin marketplace add michellepace/my-claude-marketplace

# 2. Install this plugin
/plugin install claude-code-utils@my-claude-marketplace
```

## 🟣 What's Inside

| Run Skill | Description |
|:------|:------------|
| [`/cc-which-plugins`](skills/cc-which-plugins/SKILL.md) | Show all marketplaces and plugins with their status |
| [`/cc-whats-new`](skills/cc-whats-new/SKILL.md) | Analyse changelog and explain features practically |

---

## 🟣 Skill: cc-which-plugins

Shows the state of Marketplaces and Plugins across all scopes, with a focus on what's active in the current project.

### Usage

```
/cc-which-plugins
```

### Sample Output

```text
● All health checks pass. Here's the summary:

🏪 Added Marketplaces
  ┌───────────────────────────────────────┬─────────────────────────┐
  │              Source Repo              │       Marketplace       │
  ├───────────────────────────────────────┼─────────────────────────┤
  │ ✅ anthropics/claude-plugins-official │ claude-plugins-official │
  ├───────────────────────────────────────┼─────────────────────────┤
  │ ✅ michellepace/my-claude-marketplace │ my-claude-marketplace   │
  └───────────────────────────────────────┴─────────────────────────┘

📂 Plugins at Local Scope (per-project, not in git)
  (none)

📂 Plugins at Project Scope (per-project, in git)
  ┌───────────────────────┬────────────────────────────────────┬───────────────┬─────────┬────────┐
  │        Project        │            Source Repo             │    Plugin     │ Version │ Health │
  ├───────────────────────┼────────────────────────────────────┼───────────────┼─────────┼────────┤
  │ my-claude-marketplace │ anthropics/claude-plugins-official │ plugin-dev    │ unknown │ ✅     │
  ├───────────────────────┼────────────────────────────────────┼───────────────┼─────────┼────────┤
  │ my-claude-marketplace │ anthropics/claude-plugins-official │ skill-creator │ unknown │ ✅     │
  ├───────────────────────┼────────────────────────────────────┼───────────────┼─────────┼────────┤
  │ my-claude-marketplace │ michellepace/my-claude-marketplace │ git-utils     │ 1.0.0   │ ✅     │
  └───────────────────────┴────────────────────────────────────┴───────────────┴─────────┴────────┘

👤 Plugins at User Scope
  ┌────────────────────────────────────┬─────────────────┬─────────┬────────┐
  │            Source Repo             │     Plugin      │ Version │ Health │
  ├────────────────────────────────────┼─────────────────┼─────────┼────────┤
  │ anthropics/claude-plugins-official │ frontend-design │ unknown │ ✅     │
  └────────────────────────────────────┴─────────────────┴─────────┴────────┘

🎯 CURRENT PROJECT (EFFECTIVE): my-claude-marketplace
  ┌────────────────────────────────────┬─────────────────┬─────────┬─────────┬────────┐
  │            Source Repo             │     Plugin      │  Scope  │ Version │ Health │
  ├────────────────────────────────────┼─────────────────┼─────────┼─────────┼────────┤
  │ anthropics/claude-plugins-official │ frontend-design │ user    │ unknown │ ✅     │
  ├────────────────────────────────────┼─────────────────┼─────────┼─────────┼────────┤
  │ anthropics/claude-plugins-official │ plugin-dev      │ project │ unknown │ ✅     │
  ├────────────────────────────────────┼─────────────────┼─────────┼─────────┼────────┤
  │ anthropics/claude-plugins-official │ skill-creator   │ project │ unknown │ ✅     │
  ├────────────────────────────────────┼─────────────────┼─────────┼─────────┼────────┤
  │ michellepace/my-claude-marketplace │ git-utils       │ project │ 1.0.0   │ ✅     │
  └────────────────────────────────────┴─────────────────┴─────────┴─────────┴────────┘                 
```

---

## 🟣 Skill: cc-whats-new

Explains what's new in Claude Code versions with practical examples you can use immediately.

### Usage

```
/cc-whats-new 2.1      # All 2.1.* versions
/cc-whats-new 2.1.2    # Exact version only
```

### In Action

(1) Run the skill — Shows version summary table (always latest 7):

<div align="center">
  <a href="../../images/cc-whats-new_1.jpg" target="_blank">
    <img src="../../images/cc-whats-new_1.jpg" alt="Version discovery phase: Command invocation shows a summary table of the latest 7 Claude Code versions with release dates, changelog item counts, and one-line descriptions. The requested version is marked with a star. Versions with zero items are explained as npm-only releases. A progress indicator shows analysis beginning." width="832">
  </a>
</div>

(2) Impact summary — Features ranked by benefit, fixes listed, then detailed explanations begin:

<div align="center">
  <a href="../../images/cc-whats-new_2.jpg" target="_blank">
    <img src="../../images/cc-whats-new_2.jpg" alt="High-level analysis phase: A claude-code-guide agent analyses the changelog and produces a Summary Table ranking features by impact (Feature | Benefit columns). A Fixes section lists resolved issues in problem to solution format. Detailed explanations begin below, each marked with a star icon, containing a description, practical EXAMPLE, and documentation links." width="832">
  </a>
</div>

(3) Detailed feature explanations continue with examples and doc links:

<div align="center">
  <a href="../../images/cc-whats-new_3.jpg" target="_blank">
    <img src="../../images/cc-whats-new_3.jpg" alt="Detailed explanations phase: Each significant feature is explained with a star-marked heading, a concise description of what it does and why it matters, a practical EXAMPLE showing real-world usage, and links to official documentation. A closing summary distils the version's theme. Footer shows total execution time." width="832">
  </a>
</div>
