# claude-code-utils

Claude Code meta-utilities: release notes and plugin status.

## 🟣 What's Inside

| Skill | Description |
|:------|:------------|
| `/cc-what-plugins` | Show all marketplaces and plugins with their status |
| `/cc-whats-new` | Analyse changelog and explain features practically |

---

## 🟣 Skill: cc-what-plugins

Shows the state of Marketplaces and Plugins across all scopes, with a focus on what's active in the current project.

### Usage

```
/cc-what-plugins
```

### Sample Output

**🏪 Added Marketplaces (3)**

| Source | Marketplace |
| :----- | :---------- |
| ✅ anthropics/claude-plugins-official | claude-plugins-official |
| ✅ anthropics/skills | anthropic-agent-skills |
| ✅ ~/projects/my-claude-marketplace | my-claude-marketplace |

**📦 All Installed Plugins (5)**

| Source | Plugin | Install Scope | Install Project | Version |
| :----- | :----- | :------------ | :-------------- | :------ |
| claude-plugins-official | claude-md-management | project | my-app ⚠️ | unknown |
| claude-plugins-official | plugin-dev | project | my-claude-marketplace | unknown |
| my-claude-marketplace | claude-code-utils | user | *(all)* | 1.0.0 |
| my-claude-marketplace | find-my-font | user | *(all)* | 2.0.3 |
| my-claude-marketplace | nextjs-utils | project | devflow | 1.0.4 |

⚠️ `claude-md-management` — install path no longer exists (stale entry).

1 plugin disabled via `.claude/settings.json`:
- `find-my-font@my-claude-marketplace` → false

No orphaned `enabledPlugins` entries found.

**🔌 Active Plugins (2): `my-claude-marketplace`**

| Source | Plugin | Why Active |
| :----- | :----- | :--------- |
| claude-plugins-official | plugin-dev | enabled in `.claude/settings.json` |
| my-claude-marketplace | claude-code-utils | user-scope install |

---

*Output will vary based on your installed marketplaces, plugins, and model.*

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
