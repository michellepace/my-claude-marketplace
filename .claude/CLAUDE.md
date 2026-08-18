# CLAUDE.md

A Claude Code **marketplace** — a monorepo of Plugins.

Plugins are described in this manifest: `.claude-plugin/marketplace.json`

## Plugin Anatomy

Everything is optional — these paths are auto-discovered:

```text
plugins/<name>/
├── .claude-plugin/plugin.json  # Manifest — nothing else goes in here
├── skills/<skill>/SKILL.md     # → /<plugin>:<skill>
├── agents/<agent>.md           # → @<plugin>:<agent>
├── hooks/hooks.json            # Exact filename
├── .mcp.json                   # MCP servers
├── bin/                        # Executables on Bash PATH
├── scripts/                    # Helpers (via ${CLAUDE_PLUGIN_ROOT})
├── README.md
└── ...                         # Freeform, eg references/, examples/
```

Unused here, see README appendix: `workflows/`, `output-styles/`, `themes/`, `monitors/monitors.json`, `.lsp.json`, `settings.json`

Rules that bite:

- `${CLAUDE_PLUGIN_ROOT}` = absolute path to the plugin dir. Use it for every path to a bundled file in the plugin as relative paths break.
- **No `../` escapes.** Installed plugins are copied to `~/.claude/plugins/cache`, so paths outside the plugin root break.
- A `CLAUDE.md` at a plugin root is **not** loaded as context. Ship instructions as a skill.
- A single-skill plugin can put `SKILL.md` at the plugin root; set frontmatter `name`.

## Testing Plugins

Before committing, check the plugin (manifest, then skills/agents/commands):

```shell
claude plugin validate ./plugins/git-utils   # see --help for flags
```

Test a plugin whilst developing without installing it:

```shell
claude --plugin-dir ~/projects/my-claude-marketplace/plugins/git-utils
```

`--plugin-dir` is a session-only override that beats every scope except managed.

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
