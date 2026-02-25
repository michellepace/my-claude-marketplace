# cc-what-plugins

Shows the state of Marketplaces and Plugins across all scopes.

## What's Inside

| Command | Description |
| :------ | :---------- |
| `/cc-what-plugins:list` | Display all marketplaces and plugins with their status |

## Usage

```
/cc-what-plugins:list
```

## Sample Output

**● Added Marketplaces (5 added)**

| Source | Marketplace Name |
| :----- | :---------- |
| ✅ anthropics/claude-plugins-official | claude-plugins-official |
| ✅ anthropics/knowledge-work-plugins | knowledge-work-plugins |
| ✅ anthropics/skills | anthropic-agent-skills |
| ✅ kepano/obsidian-skills | obsidian-skills |
| ✅ ~/projects/my-claude-marketplace | my-claude-marketplace |

**● Installed Plugins by Project (6)**

| Project | Source | Plugin | Scope | Installed | Enabled |
| :------ | :----- | :----- | :---- | :-------- | :------ |
| *(all)* | ~/projects/my-claude-marketplace | cc-marketplaces-plugins | user | ✅ | ✅ |
| *(all)* | ~/projects/my-claude-marketplace | cc-whats-new | user | ✅ | ✅ |
| craft-me-private | ~/projects/my-claude-marketplace | skill-creator | project | ✅ | ✅ |
| devflow | ~/projects/my-claude-marketplace | shadcn-ui | project | ✅ | ✅ |
| dwell-sp | anthropics/claude-plugins-official | claude-md-management | project | ✅ | ✅ |
| ideas-vault | kepano/obsidian-skills | obsidian | project | ✅ | ✅ |

---

*Output will vary based on your installed marketplaces and plugins.*
