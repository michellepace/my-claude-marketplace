# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## What This Is

A Claude Code **marketplace** — a monorepo of plugins.

## Plugins

| Plugin | Type | Purpose |
|:---|:---|:---|
| `claude-code-utils` | 2 skills | Claude Code visibility & discovery |
| `find-my-font` | 4 skills + MCP | Font pairing (orchestrator pattern) |
| `nextjs-utils` | 2 skills + MCP | Next.js docs & dev guidance |
| `repo-utils` | 3 skills | Git & GitHub workflows |

## Plugin Anatomy

Every plugin lives under `plugins/<name>/` and follows this layout:

```
plugins/<name>/
├── .claude-plugin/plugin.json   # Required manifest
├── commands/*.md                # Slash commands (auto-discovered)
├── agents/*.md                  # Subagent definitions (auto-discovered)
├── skills/*/SKILL.md            # Skills (auto-discovered)
├── hooks/hooks.json             # Event handlers (auto-discovered)
├── .mcp.json                    # MCP server definitions (optional)
├── scripts/                     # Helper scripts and utilities
└── README.md
```

Only the manifest is required. Plugins may also include freeform folders like `references/`, `examples/`.

## Testing a Plugin Locally

```shell
claude --plugin-dir ~/projects/my-claude-marketplace/plugins/<plugin-name>
```

No install/uninstall cycle needed — edit files, restart Claude Code, test.
