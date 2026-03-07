# cc-what-plugins

Shows the state of Marketplaces and Plugins across all scopes, with a focus on what's active in the current project.

## What's Inside

| Command | Description |
| :------ | :---------- |
| `/cc-what-plugins:list` | Display all marketplaces and plugins with their status |

## Usage

```
/cc-what-plugins:list
```

## Sample Output

**🏪 Added Marketplaces (5)**

| Source | Marketplace |
| :----- | :---------- |
| ✅ anthropics/claude-plugins-official | claude-plugins-official |
| ✅ anthropics/knowledge-work-plugins | knowledge-work-plugins |
| ✅ anthropics/skills | anthropic-agent-skills |
| ✅ kepano/obsidian-skills | obsidian-skills |
| ✅ ~/projects/my-claude-marketplace | my-claude-marketplace |

**🔌 Active Plugins in This Project (2)**

| Source | Plugin | Why Active |
| :----- | :----- | :--------- |
| my-claude-marketplace | cc-what-plugins | user-scope install |
| my-claude-marketplace | cc-whats-new | user-scope install |

3 plugins installed for this project are disabled via `.claude/settings.json`:

- `claude-md-management@claude-plugins-official` → false
- `frontend-design@claude-plugins-official` → false
- `skill-creator@claude-plugins-official` → false

**📦 All Installed Plugins (7)**

| Source | Plugin | Install Scope | Install Project | Version |
| :----- | :----- | :------------ | :-------------- | :------ |
| claude-plugins-official | claude-md-management | project | dwell-sparkle | 1.0.0 |
| claude-plugins-official | frontend-design | project | dwell-sparkle | 205b6e0b3036 |
| claude-plugins-official | skill-creator | project | dwell-sparkle | 205b6e0b3036 |
| my-claude-marketplace | cc-what-plugins | user | (all) | 1.2.1 |
| my-claude-marketplace | cc-whats-new | user | (all) | 0.2.0 |
| my-claude-marketplace | shadcn-ui | project | devflow | 1.0.0 |
| obsidian-skills | obsidian | project | ideas-vault ⚠️ | 1.0.0 |

⚠️ `obsidian@obsidian-skills` — install path is `/mnt/c/Users/mp/Documents/ideas-vault` (Windows path via WSL; may be stale if the vault has moved).

No orphaned `enabledPlugins` entries found.

---

*Output will vary based on your installed marketplaces, plugins, model, and effort level. The above was generated with Opus 4.6 at high effort.*
