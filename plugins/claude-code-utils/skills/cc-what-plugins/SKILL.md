---
name: cc-what-plugins
description: Show active plugins for this project plus all installed marketplaces and plugins
context: fork
agent: general-purpose
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(jq *)
  - Bash(ls *)
  - Bash(test -d *)
  - Glob
  - Grep
  - Read
---

# Claude Code Marketplaces and Plugins

## Architecture

Two layers work together:

- **Central registry** (`~/.claude/plugins/`): stores all marketplace and plugin records regardless of scope. Scope is tracked per-entry via `scope` and `projectPath` fields.
- **Scope settings** (settings.json files): control which plugins are **enabled** at each scope level.

Scope precedence (highest wins):

| Precedence | Scope | Settings File |
| :--------- | :---- | :------------ |
| 1 | managed | `managed-settings.json` (system) |
| 2 | local | `.claude/settings.local.json` |
| 3 | project | `.claude/settings.json` |
| 4 | user | `~/.claude/settings.json` |

When `enabledPlugins` entries conflict, the higher-precedence scope wins. Managed scope is excluded from this skill — its settings file location varies by system.

## Step 1: Read files and extract data

Read these files with the Read tool:

**Central registry** (stored in `~/.claude/plugins/`, covers all scopes):

1. `~/.claude/plugins/known_marketplaces.json` → central registry of all added marketplaces (all scopes)

   ```json
   {
     "marketplace-name": {
       "source": { "source": "github", "repo": "owner/repo" }
     }
   }
   ```

2. `~/.claude/plugins/installed_plugins.json` → central registry of all installed plugins (all scopes). `projectPath` is only present for project/local scopes.

   ```json
   {
     "version": 2,
     "plugins": {
       "name@marketplace": [
         { "scope": "project", "projectPath": "/path/to/project",
           "version": "1.0.0", "installPath": "/home/.../.claude/plugins/cache/..." }
       ]
     }
   }
   ```

**Scope-level settings** (control which plugins are enabled):

1. `~/.claude/settings.json` → `enabledPlugins` (user scope)
2. `.claude/settings.json` → `enabledPlugins` and `extraKnownMarketplaces` (project scope)

   ```json
   {
     "extraKnownMarketplaces": {
       "marketplace-name": {
         "source": { "source": "github", "repo": "owner/repo" }
       }
     },
     "enabledPlugins": {
       "name@marketplace": true
     }
   }
   ```

3. `.claude/settings.local.json` → `enabledPlugins` (local scope)

## Step 2: Determine active plugins

Merge `enabledPlugins` from user → project → local (higher precedence overrides lower). A plugin is active only if it resolves to `true`. No entry = not active.

For each active plugin, cite the highest-precedence file that sets it to `true`.

## Step 3: Present summary

<format>

### 🏪 Added Marketplaces (N)

Sort by: Source

| Source | Marketplace |
| :----- | :---------- |
| ✅ acme-org/acme-plugins | acme-plugins |
| ✅ jdoe/my-marketplace | my-marketplace |

Flag any `extraKnownMarketplaces` entry (from `.claude/settings.json`) not present in `known_marketplaces.json`:

> ⚠️ Declared but not added: `marketplace-id`

### 📦 All Installed Plugins (N)

Sort by: Source → Plugin

| Source | Plugin | Scope | Project | Version | Health |
| :----- | :----- | :---- | :------ | :------ | :----- |
| acme-plugins | lint-fix | project | my-project | 1.2.0 | ✅ |
| my-marketplace | deploy-utils | project | old-app | 3.0.1 | ⚠️ project gone |
| acme-plugins | api-docs | project | my-project | unknown | 🔗 cache missing |

Health: ✅ = ok, ⚠️ = projectPath doesn't exist, 🔗 = installPath doesn't exist.

### 🔌 Active Plugins (N): `projectname`

Sort by: Source → Plugin

| Source | Plugin | Why Active |
| :----- | :----- | :--------- |
| acme-plugins | lint-fix | enabled in .claude/settings.json |

</format>

Ensure accuracy. If unsure, tell the user.
