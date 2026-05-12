# Plugin: `claude-code-utils`

**Claude Code visibility & discovery:** what's new in the changelog, which plugins you have installed, peak context-window usage across recent sessions, and shortcut keys.

Add marketplace and install (project scope):

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
| [`/cc-peak-ctx-analyse`](skills/cc-peak-ctx-analyse/SKILL.md) | Analyse peak context-window usage across recent sessions |
| [`/cc-shortcuts`](skills/cc-shortcuts/SKILL.md) | Recommend Claude Code (and VSCode) shortcut keys |

---

## 🟣 Skill: cc-which-plugins

Shows marketplaces and plugins across all scopes, focused on what's active in the current project.

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

Explains what's new in the Claude Code changelog with practical examples you can use immediately. Launches the `claude-code-guide` subagent for rich explanations with doc links.

Run:

```
/cc-whats-new-changelog         # Summary table first
/cc-whats-new-changelog 2.1.2   # Exact version only
/cc-whats-new-changelog 2.1     # All 2.1.* versions
```

### Sample Output

<div align="center">
  <a href="images/cc-whats-new-changelog.jpg" target="_blank">
    <img src="images/cc-whats-new-changelog.jpg" alt="Screenshot of the cc-whats-new-changelog skill running in Claude Code. It displays a summary table of the latest 8 Claude Code versions (2.1.88 to 2.1.97) with columns for Version, Released date, Items count, and Changes at a Glance. The skill reports 87 total versions and prompts the user to pick a version, timeframe, or range to explain in detail.">
  </a>
</div>

---

## 🟣 Skill: cc-peak-ctx-analyse

Scans your local session files (`~/.claude/projects/*/*.jsonl`) and computes the peak context-window size per session — the same value `/context` shows — then surfaces patterns across recent work.

Run:

```text
/cc-peak-ctx-analyse

/cc-peak-ctx-analyse what were my three biggest sessions
about this week?

/cc-peak-ctx-analyse today. In which session did I spend the
most time, and is duration correlated with context window size?

/cc-peak-ctx-analyse last 14 days. Am I getting better at
shorter context windows; any patterns between projects? I have
been trying very hard these last 3 days to get better at
managing my context. What are the trends?
```

---

## 🟣 Skill: cc-shortcuts

Ask in plain English — delete a word, rewind the conversation, toggle thinking mode, dodge a VSCode chord conflict — and get the right key. Checks personal notes first (with VSCode collision flags), then falls back to Anthropic's interactive-mode reference.

Run:

```text
/cc-shortcuts how do I insert a newline without submitting?
/cc-shortcuts shortcut to rewind the conversation
/cc-shortcuts switch model without losing my prompt
```
