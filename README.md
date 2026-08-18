# My Claude Marketplace (A Bag of Plugins)

A Marketplace is a bag of plugins — easy to share, easy to keep updated. Very commonly these plugins contain skills, which are in essence "repeatable prompts". This repo is a marketplace of plugins I made for me.

<figure align="left">
  <a href="images/marketplace-plugin-sketch.jpeg" target="_blank">
    <img src="images/marketplace-plugin-sketch.jpeg" alt="Hand-drawn sketch of a marketplace as one container holding several plugins, with one plugin opened to show what it can contain: skills, agents, commands, MCPs and hooks. Marketplace benefits listed below: source control, one place for all projects, plugins can be switched on or off, easy to share, easy to get updates." width="425">
  </a>
  <figcaption><em>Marketplace → has Plugins → which can contain Skills (and other things)</em></figcaption>
</figure>

<br>

## What's Inside?

Well yes you guessed it, plugins.

| Plugin | Contains | Purpose |
| :----- | :------- | :------ |
| [`alwayson-misc`](./plugins/alwayson-misc) | 3 skills | uv scripts, plugin management, grill-me |
| [`claude-code-utils`](./plugins/claude-code-utils) | 3 skills | Claude Code know-how + session analysis |
| [`find-font`](./plugins/find-font) | 4 skills + MCP | Font pairing (orchestrator pattern) |
| [`git-utils`](./plugins/git-utils) | 5 skills | Git & GitHub workflows |
| [`nextjs-utils`](./plugins/nextjs-utils) | 2 skills + MCP | Next.js docs & dev guidance |

For the anatomy of a plugin see the Appendix below.

## Usage

The commands below use `project` scope, which is my default preference. The table further down explains the four scopes available.

```bash
# add the marketplace
claude plugin marketplace add michellepace/my-claude-marketplace --scope project

# install whichever plugins you want, find-font plugin:
claude plugin install find-font@my-claude-marketplace --scope project
```

<br>

📚 **About that `--scope`:**

Plugins enabled across scopes are merged (meaning they "accumulate"). Where the same plugin is set in two scopes, the highest wins: managed > local > project > user.

| Scope | Settings File | Who it affects | Shared with team? |
| :---- | :------------ | :------------- | :---------------- |
| **managed** | `managed-settings.json` (system) | All users on the machine | Yes (deployed by IT) |
| **local** | `.claude/settings.local.json` | You, in this repo only | No (gitignored) |
| **project** | `.claude/settings.json` | All collaborators on the repo | Yes (committed to git) |
| **user** | `~/.claude/settings.json` | You, across all projects | No |

Installing at project scope has the benefit of being visible in source control. I like to know which plugins I used in a project. Although, I will commit them as disabled and enable only when I know I need them. This is in an effort to keep my context window clean.

## Appendix: Anatomy of A Plugin As An Example

This is the full picture of what's automatically recognised in a plugin, and all optional. You can also add more files. But when referring to them from a skill or agent, ask Claude why you need to use `${CLAUDE_PLUGIN_ROOT}`.

The plugins in this repo are far simpler, but here is the full picture:

```text
enterprise-plugin/
├── .claude-plugin/           # Metadata directory (optional)
│   └── plugin.json             # plugin manifest 🟢
├── skills/                   # Skills
│   ├── code-reviewer/
│   │   └── SKILL.md
│   └── pdf-processor/
│       ├── SKILL.md
│       └── scripts/
├── commands/                 # Skills as flat .md files
│   ├── status.md
│   └── logs.md
├── agents/                   # Subagent definitions
│   ├── security-reviewer.md
│   ├── performance-tester.md
│   └── compliance-checker.md
├── workflows/                # Dynamic workflow scripts "subagents at scale"
│   └── release-audit.js
├── output-styles/            # Output style definitions
│   └── terse.md
├── themes/                   # Color theme definitions
│   └── dracula.json
├── monitors/                 # Background monitor configurations
│   └── monitors.json
├── hooks/                    # Hook configurations
│   ├── hooks.json            # Main hook config
│   └── security-hooks.json   # Additional hooks
├── bin/                      # Plugin executables added to PATH
│   └── my-tool               # Invokable as bare command in Bash tool
├── settings.json             # Default plugin settings
├── .mcp.json                 # MCP server definitions
├── .lsp.json                 # LSP server configurations
├── scripts/                  # Hook and utility scripts
│   ├── security-scan.sh
│   ├── format-code.py
│   └── deploy.js
├── LICENSE                   # License file
└── CHANGELOG.md              # Version history
```

## Appendix: Good Refs

> *Plugins can provide specialized [subagents](https://code.claude.com/docs/en/sub-agents) for specific tasks that Claude can invoke automatically when appropriate. See [anthropic doc](https://code.claude.com/docs/en/plugins-reference#agents).*

> *Plugins can declare background monitors that Claude Code starts automatically when the plugin is active. Each monitor runs a shell command for the lifetime of the session and delivers every stdout line to Claude as a notification, so Claude can react to log entries, status changes, or polled events without being asked to start the watch itself. See [anthropic doc](https://code.claude.com/docs/en/plugins-reference#monitors)*

> *Dynamic workflows orchestrate many subagents from a script Claude writes and you can rerun. Use them for codebase audits, large migrations, and cross-checked research.* See [anthropic doc](https://code.claude.com/docs/en/workflows)

Reading
- https://code.claude.com/docs/en/plugins
- https://code.claude.com/docs/en/plugins-reference
- https://code.claude.com/docs/en/workflows *"Orchestrate subagents at scale"*

Plugins
- [Plugin Developer Toolkit](https://claude.com/plugins/plugin-dev) (`plugin-dev@claude-plugins-official`)
- [Skill Creator](https://claude.com/plugins/skill-creator) (`skill-creator@claude-plugins-official`) includes creating evals
