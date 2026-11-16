# My Claude Marketplace (A Bag of Plugins)

A marketplace is a bag of plugins — easy to share, easy to keep updated. Plugins most often contain skills, which are in essence "repeatable prompts". This repo is a marketplace of plugins I made for me.

<p>
  <a href="images/marketplace-plugin-sketch.jpeg"><img src="images/marketplace-plugin-sketch.jpeg" alt="Sketch: a marketplace holds plugins; a plugin holds skills, agents, commands, MCPs and hooks. Benefits: source control, one place for all projects, plugins on/off, easy to share and update." width="425"></a>
  <br>
  <sub><em>Marketplace → has Plugins → which can contain Skills (and other things)</em></sub>
</p>

## What's Inside?

Well yes you guessed it, plugins.

| Plugin | Contains | Purpose |
| :----- | :------- | :------ |
| [`alwayson-misc`](./plugins/alwayson-misc) | 3 skills | Plugin management, grill-me, my VS Code config |
| [`cc-utils`](./plugins/cc-utils) | 3 skills | Claude Code know-how + session analysis |
| [`find-font`](./plugins/find-font) | 4 skills + MCP | Font pairing (orchestrator pattern) |
| [`git-utils`](./plugins/git-utils) | 5 skills | Git & GitHub workflows |
| [`nextjs-utils`](./plugins/nextjs-utils) | 1 skill + MCP | shadcn/ui best practices for Next.js |
| [`uv-pep723`](./plugins/uv-pep723) | 1 skill | Standalone uv Python scripts |

For what a plugin can contain, see [Anatomy of a Plugin](#appendix-1-anatomy-of-a-plugin). Skills I've tested by hand have evals in [`evals/`](./evals/).

## Usage

These commands use `project` scope, my default. The four scopes are explained below.

```bash
# add the marketplace
claude plugin marketplace add michellepace/my-claude-marketplace --scope project

# install any plugin, e.g. find-font
claude plugin install find-font@my-claude-marketplace --scope project
```

<br>

📚 **About that `--scope`:**

Plugins enabled in different scopes add up. If two scopes set the same plugin, the higher one wins: managed > local > project > user.

| Scope | Settings file | Who it affects | Shared with team? |
| :---- | :------------ | :------------- | :---------------- |
| **managed** | `managed-settings.json` (system) | All users on the machine | Yes (deployed by IT) |
| **local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |
| **project** | `.claude/settings.json` | All collaborators on the repo | Yes (committed to git) |
| **user** | `~/.claude/settings.json` | You, across all projects | No |

I install at project scope so source control shows which plugins a project uses. I commit them disabled and enable them only when needed, to keep my context window clean.

<br>

## Appendix 1: Anatomy of a Plugin

Where a plugin fits, then what each of its files gives you once it loads:

<p>
  <img src="images/plugins-model-dark.svg" alt="Diagram: a marketplace (catalog) lists a plugin (one directory of skills, agents, hooks, MCP servers) → you install it → Claude Code loads its components." width="700">
  <br><br>
  <img src="images/plugin-directory-dark.svg" alt="Diagram: plugin files → what each gives your session. plugin.json → name; skills/review/SKILL.md → /my-plugin:review; agents/reviewer.md → subagent; hooks/hooks.json → lifecycle hooks; .mcp.json → MCP tools." width="700">
  <br>
  <sub><em>From the <a href="https://code.claude.com/docs/en/plugins/overview">Plugins overview</a> doc</em></sub>
</p>

Every component is optional and auto-discovered from its default location. Other files, such as `scripts/`, aren't loaded automatically; refer to them with `${CLAUDE_PLUGIN_ROOT}` (ask Claude why). The plugins in this repo are far simpler, but here is one of every kind of component, plus the files that support them:

```text
my-plugin/
├── .claude-plugin/
│   └── plugin.json           # Manifest (optional; only `name` is required)
├── skills/                   # Skills → /my-plugin:<skill>
│   └── review/
│       ├── SKILL.md
│       └── scripts/          # Supporting files for the skill
├── agents/                   # Subagents → @agent-my-plugin:<agent>
│   └── security-reviewer.md
├── hooks/
│   └── hooks.json            # Hooks that run on lifecycle events (exact filename)
├── .mcp.json                 # MCP servers that give Claude tools
├── .lsp.json                 # Language servers → diagnostics and code navigation
├── bin/                      # Executables on the Bash tool's PATH
│   └── hello-plugin
├── monitors/
│   └── monitors.json         # Background commands whose output reaches Claude
├── workflows/                # Dynamic workflows → /my-plugin:<workflow>
│   └── audit-routes.js
├── output-styles/            # Output styles → /output-style
│   └── terse.md
├── themes/                   # Color themes → /theme
│   └── dracula.json
├── settings.json             # Defaults; only `agent` and `subagentStatusLine` apply
└── scripts/                  # Not auto-loaded: helpers for hooks, via ${CLAUDE_PLUGIN_ROOT}
    └── format.sh
```

## Appendix 2: Good References

Append `.md` to all non-GitHub URLs below to fetch them as clean Markdown.

Docs
- [Plugins overview](https://code.claude.com/docs/en/plugins/overview)
- [Add components to a plugin](https://code.claude.com/docs/en/plugins/components)
- [Plugin manifest reference](https://code.claude.com/docs/en/plugins/manifest-reference)

Resources for building plugins
- [Automating eval design and hillclimbing with Claude](https://claude.dev/blog/automating-eval-design-and-hillclimbing)
- [Plugin Developer Toolkit](https://github.com/anthropics/claude-plugins-official/blob/main/plugins/plugin-dev/README.md) (`plugin-dev@claude-plugins-official`)
- [Skill Creator](https://github.com/anthropics/claude-plugins-official/blob/main/plugins/skill-creator/README.md) (`skill-creator@claude-plugins-official`) — also creates and runs evals

Three plugin components worth a closer look:

- A [subagent](https://code.claude.com/docs/en/sub-agents) is a separate assistant, with its own instructions and context window, that Claude can delegate a task to. See [Add components to a plugin](https://code.claude.com/docs/en/plugins/components#agents).
- A monitor is a shell command that runs in the background for the whole session. What it prints reaches Claude as notifications, so Claude can react to a log or a status change without being asked to watch it. See [Add components to a plugin](https://code.claude.com/docs/en/plugins/components#monitors).
- A [dynamic workflow](https://code.claude.com/docs/en/workflows) is a script that orchestrates many subagents at once, for jobs like codebase audits, large migrations, and cross-checked research. Claude writes it, and you can save and rerun it. See [Distribute a workflow in a plugin](https://code.claude.com/docs/en/workflows#distribute-a-workflow-in-a-plugin).
