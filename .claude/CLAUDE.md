# Claude Code Marketplace — a monorepo of Plugins

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

Other components exist but are unused here (see README § Appendix 1).

Rules that bite:

- `${CLAUDE_PLUGIN_ROOT}` = absolute path to the plugin dir. Use it for every path to a bundled file in the plugin as relative paths break.
- **No `../` escapes.** Installed plugins are copied to `~/.claude/plugins/cache`, so paths outside the plugin root break.
- A single-skill plugin can put `SKILL.md` at the plugin root; set frontmatter `name`.

## Testing Plugins

Validate with this, not `claude plugin validate`:

```shell
uvx pre-commit run validate-plugins --all-files  # incl. untracked
```

Test the working copy (beats an installed copy, for that session):

```shell
claude --plugin-dir ~/projects/my-claude-marketplace/plugins/git-utils
```

## Python

Scripts are standalone (uv PEP 723). The root `pyproject.toml` is ruff/pyright config only, not a project.

Development commands:

```shell
uv run script.py                      # run (isolated)
uvx pre-commit run --files script.py  # ruff + pyright
```

Always `uvx pre-commit`, never `uv run pre-commit`.
