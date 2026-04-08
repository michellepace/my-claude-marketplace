---
name: cc-what-plugins
description: Show all installed marketplaces and plugins by scope from the central registry
context: fork
agent: general-purpose
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(jq *)
  - Bash(test *)
  - Glob
  - Grep
  - Read
---

# Claude Code Marketplaces and Plugins

The central registry (`~/.claude/plugins/`) is the single source of truth for all marketplace and plugin data across all scopes.

Scope precedence (highest wins):

| Precedence | Scope | Settings File |
| :--------- | :---- | :------------ |
| 1 | local | Repo file: `.claude/settings.local.json` |
| 2 | project | Repo file: `.claude/settings.json` |
| 3 | user | System file: `~/.claude/settings.json` |

## Step 1: Read central registry

Read these files with the Read tool:

1. `~/.claude/plugins/known_marketplaces.json` → all added marketplaces. Use the `source.repo` field to resolve marketplace names to repo paths (e.g. `claude-plugins-official` → `anthropics/claude-plugins-official`)

   ```json
   {
     "claude-plugins-official": {
       "source": { "source": "github", "repo": "anthropics/claude-plugins-official" },
       "installLocation": "/home/.../.claude/plugins/marketplaces/claude-plugins-official",
       "lastUpdated": "2026-04-07T09:54:04.843Z"
     },
     "knowledge-work-plugins": {
       "source": { "source": "github", "repo": "anthropics/knowledge-work-plugins" },
       "installLocation": "/home/.../.claude/plugins/marketplaces/knowledge-work-plugins",
       "lastUpdated": "2026-04-07T13:01:00.459Z"
     }
   }
   ```

2. `~/.claude/plugins/installed_plugins.json` → all installed plugins. Each entry has `scope` (`"user"`, `"project"`, or `"local"`). `projectPath` is only present for project/local scopes.

   ```json
   {
     "version": 2,
     "plugins": {
       "frontend-design@claude-plugins-official": [
         { "scope": "user",
           "version": "unknown", "installPath": "/home/.../.claude/plugins/cache/..." },
         { "scope": "project", "projectPath": "/home/.../projects/my-app",
           "version": "unknown", "installPath": "/home/.../.claude/plugins/cache/..." }
       ],
       "brand-voice@knowledge-work-plugins": [
         { "scope": "project", "projectPath": "/home/.../projects/nextjs/devflow",
           "version": "1.0.0", "installPath": "/home/.../.claude/plugins/cache/..." }
       ]
     }
   }
   ```

## Step 2: Health checks

Collect all `projectPath` and `installPath` values from `installed_plugins.json`, then run a single bash `for` loop to check them all at once (use emojis):

```bash
echo "🔍 Checking projectPath and installPath directories exist..."
for d in <path1> <path2> ...; do
  test -d "$d" && echo "EXISTS $d" || echo "MISSING $d"
done
```

Health key per path:
- `projectPath` missing → ⚠️ project gone
- `installPath` missing → 🔗 cache missing
- Both present (or only `installPath` and it exists) → ✅

## Step 3: Present summary

Rules:
- Ensure accuracy - if unsure, tell the user.
- Table sort: all tables a-z by leftmost columns, left to right
- Health key: ✅ = ok, ⚠️ = projectPath missing, 🔗 = installPath missing
- Empty sections: show the heading, then "(none)" on the next line

<format>

## 🏪 Added Marketplaces

| Source Repo | Marketplace |
| :---------- | :---------- |
| ✅ anthropics/claude-plugins-official | claude-plugins-official |
| ✅ anthropics/knowledge-work-plugins | knowledge-work-plugins |

## 📂 Plugins at Local Scope (per-project, not in git)

Plugins from `installed_plugins.json` where `scope` = `"local"`.

| Project | Source Repo | Plugin | Version | Health |
| :------ | :---------- | :----- | :------ | :----- |
| devflow | anthropics/knowledge-work-plugins | design | unknown | ✅ |

## 📂 Plugins at Project Scope (per-project, in git)

Plugins from `installed_plugins.json` where `scope` = `"project"`.

| Project | Source Repo | Plugin | Version | Health |
| :------ | :---------- | :----- | :------ | :----- |
| my-claude-marketplace | anthropics/claude-plugins-official | skill-creator | unknown | ✅ |
| devflow | anthropics/knowledge-work-plugins | brand-voice | 1.0.0 | ✅ |

## 👤 Plugins at User Scope

Plugins from `installed_plugins.json` where `scope` = `"user"`.

| Source Repo | Plugin | Version | Health |
| :---------- | :----- | :------ | :----- |
| anthropics/claude-plugins-official | frontend-design | unknown | ✅ |

## 🎯 CURRENT PROJECT (EFFECTIVE): `projectname`

Derive the resolved set of plugins that apply to the current project. Scope shows the highest-precedence entry for each plugin:

1. Collect all entries where `projectPath` matches the current project (local + project scope) and all user-scope entries (apply everywhere)
2. If the same plugin appears at multiple scopes, keep only the highest-precedence entry (local > project > user)
3. Show one row per effective plugin

| Source Repo | Plugin | Scope | Version | Health |
| :---------- | :----- | :---- | :------ | :----- |
| anthropics/knowledge-work-plugins | brand-voice | project | 1.0.0 | ✅ |
| anthropics/knowledge-work-plugins | design | local | unknown | ✅ |
| anthropics/claude-plugins-official | frontend-design | user | unknown | ✅ |

</format>

Ensure all rules have been applied.
