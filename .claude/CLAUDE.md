# CLAUDE.md

A Claude Code **marketplace** — a monorepo of Plugins.

Plugins are described in this manifest: `.claude-plugin/marketplace.json`

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

## Testing Plugins

Test a plugin without installing it:

```shell
claude --plugin-dir ~/projects/my-claude-marketplace/plugins/git-utils
```

`--plugin-dir` is a session-only override that beats every scope except managed.

Edit, run `/reload-plugins` (or restart Claude Code), test.

## Python scripts

Live under `plugins/<name>/**/*.py` (uv PEP 723).

Development commands:

```shell
uv run script.py    # run (isolated)
uvx ruff format script.py
uvx ruff check script.py
uvx pyright script.py

uvx pre-commit run         # isolated — never `uv run pre-commit`
uvx pre-commit autoupdate  # bump hook `rev`s to latest
```
