---
name: cc-what-plugins
description: Show active plugins for this project plus all installed marketplaces and plugins
user-invocable: true
disable-model-invocation: true
allowed-tools: Read(*)
context: fork
---

# Claude Code Marketplaces and Plugins

Show the user the state of Marketplaces and Plugins across all scopes, with a focus on what's active in the current project.

## Step 1: Read these files

Use the Read tool on each file:

1. `~/.claude/plugins/known_marketplaces.json` — added marketplaces
2. `~/.claude/plugins/installed_plugins.json` — installed plugins (scope + project)
3. `~/.claude/settings.json` — user-scope enabledPlugins
4. `.claude/settings.json` — project-scope enabledPlugins
5. `.claude/settings.local.json` — local-scope enabledPlugins

## Step 2: Interpret the data

**Marketplaces** — only "added" (no install/enable states).

**Active plugins for current project:**

Build the merged `enabledPlugins` map by layering: user → project → local (later overrides earlier).

For each plugin in `installed_plugins.json`, determine if it is active in the current project:

- If `scope: "user"` → auto-available in all projects (unless `false` in merged enabledPlugins)
- If `scope: "project"` or `"local"` and `projectPath` matches current project → auto-available (unless `false` in merged enabledPlugins)
- If plugin key appears as `true` in merged `enabledPlugins` → available (regardless of install scope/project)
- If plugin key appears as `false` in merged `enabledPlugins` → NOT available (overrides auto-availability)
- If not mentioned in merged map → available only if scope grants automatic access (per rules above)

For each active plugin, note the "Why Active" reason:

- `user-scope install` — auto-available because scope is "user"
- `project-scope install` / `local-scope install` — auto-available because projectPath matches current project
- `enabled in <file>` — activated via enabledPlugins override (use the highest-precedence file that sets it to `true`)

**All installed plugins:**

- List every entry from `installed_plugins.json` with install scope, projectPath, and version
- Flag stale entries where projectPath directory doesn't exist on disk

Also flag any orphaned `enabledPlugins` entries (keys not matching any plugin in `installed_plugins.json`).

**How plugin activation works:**

- `installed_plugins.json` — registry of all cached plugins (install scope + project)
- `enabledPlugins` in settings — can activate any cached plugin OR disable an auto-available one
- A user-scope plugin is auto-available in all projects
- A project/local-scope plugin is auto-available only in its install project
- Any project can activate any cached plugin by adding `"plugin@marketplace": true` to its enabledPlugins
- Scope precedence for enabledPlugins: local > project > user (highest wins)
- Orphaned enabledPlugins entries (no matching install) are flagged but harmless

## Step 3: Present summary

Use this format (example data shown):

<format>

### 🏪 Added Marketplaces (N)

Sort table by: Source

| Source | Marketplace |
| :----- | :---------- |
| ✅ anthropics/claude-plugins-official | claude-plugins-official |
| ✅ ~/projects/my-claude-marketplace | my-claude-marketplace |

### 📦 All Installed Plugins (N)

Sort table by: Source → Plugin

| Source | Plugin | Install Scope | Install Project | Version |
| :----- | :----- | :------------ | :-------------- | :------ |
| claude-plugins-official | claude-md-management | project | dwell-sp ⚠️ | 1.0.0 |
| my-claude-marketplace | cc-whats-new | user | *(all)* | 0.2.0 |
| my-claude-marketplace | shadcn-ui | project | devflow | 1.0.0 |

⚠️ = install projectPath no longer exists (stale entry)

If there are orphaned enabledPlugins entries, note them here.

### 🔌 Active Plugins (N): `projectname`

Sort table by: Source → Plugin → Why Active

| Source | Plugin | Why Active |
| :----- | :----- | :--------- |
| claude-plugins-official | skill-creator | local-scope install |
| my-claude-marketplace | cc-whats-new | user-scope install |

</format>

Ensure accuracy. If unsure, tell the user.
