---
name: cc-which-plugins
description: Show installed marketplaces and plugins by scope
context: fork
agent: general-purpose
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(claude plugin *)
  - Bash(test *)
  - Bash(echo *)
---

# Claude Code Marketplaces and Plugins

Scope precedence (highest wins):

| Precedence | Scope | Settings File |
| :--------- | :---- | :------------ |
| 1 | local | Repo file: `.claude/settings.local.json` |
| 2 | project | Repo file: `.claude/settings.json` |
| 3 | user | System file: `~/.claude/settings.json` |

## Step 1: Query CLI

Run both commands:

1. `claude plugin marketplace list --json` → all marketplaces

2. `claude plugin list --json` → all installed plugins (global, all projects)

   Split each `id` on `@` → plugin name + marketplace name. Use the marketplace list to resolve marketplace name → `repo`.

   ```json
   [
     { "id": "plugin-name@marketplace-name", "version": "1.0.0",
       "scope": "user", "enabled": true,
       "installPath": "/home/.../.claude/plugins/cache/...",
       "projectPath": "/home/.../projects/..." }
   ]
   ```

   `projectPath` is only present for project/local scopes.

## Step 2: Health checks

Collect all `projectPath` and `installPath` values from the plugin list, then run a single bash `for` loop to check them all at once (use emojis):

```bash
echo "🔍 Checking projectPath and installPath directories exist..."
for d in <path1> <path2> ...; do
  test -d "$d" && echo "EXISTS $d" || echo "MISSING $d"
done
```

Health key per plugin:
- `projectPath` missing → ⚠️ project gone
- `installPath` missing → 🔗 cache missing
- Both present (or only `installPath` and it exists) → ✅

## Step 3: Present summary

Rules:
- Ensure accuracy — if unsure, tell the user.
- Table sort: all tables a-z by leftmost columns, left to right
- Health key: ✅ = ok, ⚠️ = projectPath missing, 🔗 = installPath missing
- Empty sections: show the heading, then "(none)" on the next line

<format>

## About

Marketplaces are global — added once, available to all projects.

Plugins are installed at a scope. Precedence: `local` > `project` > `user` (left wins).

## 🏪 Added Marketplaces

| Source Repo | Marketplace |
| :---------- | :---------- |
| ✅ anthropics/claude-plugins-official | claude-plugins-official |
| ✅ anthropics/knowledge-work-plugins | knowledge-work-plugins |

## 📂 1. Local Scope (per-project, not in git)

Plugins where `scope` = `"local"`.

| Project | Source Repo | Plugin | Version | Health |
| :------ | :---------- | :----- | :------ | :----- |
| devflow | anthropics/knowledge-work-plugins | design | unknown | ✅ |

## 📂 2. Project Scope (per-project, in git)

Plugins where `scope` = `"project"`.

| Project | Source Repo | Plugin | Version | Health |
| :------ | :---------- | :----- | :------ | :----- |
| my-claude-marketplace | anthropics/claude-plugins-official | skill-creator | unknown | ✅ |
| devflow | anthropics/knowledge-work-plugins | brand-voice | 1.0.0 | ✅ |

## 👤 3. User Scope

Plugins where `scope` = `"user"`.

| Source Repo | Plugin | Version | Health |
| :---------- | :----- | :------ | :----- |
| anthropics/claude-plugins-official | frontend-design | unknown | ✅ |

## 🎯 CURRENT PROJECT (EFFECTIVE): `projectname`

Derive the resolved set of plugins that apply to the current project. Scope shows the highest-precedence entry for each plugin:

1. Collect all entries where `projectPath` matches the current project (local + project scope) and all user-scope entries (apply everywhere)
2. If the same plugin appears at multiple scopes, keep only the highest-precedence entry (local > project > user)
3. Show one row per effective plugin

| Source Repo | Plugin | Scope | Version | Enabled | Health |
| :---------- | :----- | :---- | :------ | :------ | :----- |
| anthropics/knowledge-work-plugins | brand-voice | project | 1.0.0 | 🟣 true | ✅ |
| anthropics/knowledge-work-plugins | design | local | unknown | 🟤 false | ✅ |
| anthropics/claude-plugins-official | frontend-design | user | unknown | 🟣 true | ✅ |

</format>

Ensure all rules have been applied.
