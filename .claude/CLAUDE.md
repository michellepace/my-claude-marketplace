# CLAUDE.md

A Claude Code **marketplace** — a monorepo of plugins.

## Plugins

| Plugin | Purpose |
| :--- | :--- |
| `claude-code-utils` | Claude Code visibility & plugin management |
| `find-font` | Google Font pairing (orchestrator pattern, MCP) |
| `git-utils` | Git/GitHub workflows + plan grilling |
| `nextjs-utils` | Next.js docs & shadcn guidance (MCP) |

## Plugin Anatomy

Only the manifest is required; the rest is optional:

```text
plugins/<name>/
├── .claude-plugin/plugin.json  # Required manifest
├── commands/*.md               # Slash commands
├── agents/*.md                 # Subagents
├── skills/*/SKILL.md
├── hooks/hooks.json
├── .mcp.json
├── bin/                        # Executables on Bash PATH
├── scripts/                    # Helpers (via ${CLAUDE_PLUGIN_ROOT})
├── README.md
└── ...                         # Freeform dirs, eg references/, examples/
```

## Testing a Plugin Locally

No install cycle — edit, restart, test:

```shell
claude --plugin-dir ~/projects/my-claude-marketplace/plugins/<plugin-name>
```

## Python scripts

Live under `plugins/<name>/**/scripts/` are **standalone PEP 723 scripts**:

```python
# /// script
# requires-python = ">=3.14"
# dependencies = []
# ///
```

Development commands:

```shell
uv run script.py    # run (isolated)
uvx ruff format script.py
uvx ruff check script.py
uvx pyright script.py

uvx pre-commit run         # isolated — never `uv run pre-commit`
uvx pre-commit autoupdate  # bump hook `rev`s to latest
```
