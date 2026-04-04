# Plugin: `nextjs-utils`

Next.js development skills: shadcn/ui component best practices and official documentation management.

## What's Inside - Skills

| Command | What it does |
|---|---|
| `/nextjs-shadcn-ui` | Best practices for adding, customising, and architecting shadcn/ui components (Radix UI + Tailwind CSS) in Next.js |
| `/nextjs-docs-get` | Downloads and trims official Next.js documentation for Claude Code reference usage |

Both skills are independently invocable.

## Usage Examples

**shadcn/ui:**

- `/nextjs-shadcn-ui` I need a "soft" button variant with a muted background from my theme
- `/nextjs-shadcn-ui` How should I structure a settings page with sidebar nav and form sections?
- `/nextjs-shadcn-ui` Replace the deprecated Toast component — what's the current approach?

**Get Next.js Docs:**

- `/nextjs-docs-get` (generates, consolidates, and trims `.nextjs-docs/` for the current project)

## Reference Files

| File | Used By | Purpose |
|---|---|---|
| [`changelog-summary.md`](skills/nextjs-shadcn-ui/references/changelog-summary.md) | nextjs-shadcn-ui | Key shadcn/ui changes from Jun 2025 onwards (beyond Opus 4.6 training data) |
| [`llms-txt.md`](skills/nextjs-shadcn-ui/references/llms-txt.md) | nextjs-shadcn-ui | Full component index with docs URLs, extracted from ui.shadcn.com/llms.txt |
| [`strip-nextjs-index.py`](skills/nextjs-docs-get/scripts/strip-nextjs-index.py) | nextjs-docs-get | Python script to remove directory sections from agents-md INDEX.md and verify consistency |
| [`.mcp.json`](.mcp.json) | nextjs-shadcn-ui | Ref MCP server config for reading shadcn/ui docs |

## Dependencies

**Ref MCP (required by nextjs-shadcn-ui)** — configured in [`.mcp.json`](.mcp.json). The nextjs-shadcn-ui skill uses `ref_read_url` and `ref_search_documentation` to check shadcn/ui docs.

**npx (required by nextjs-docs-get)** — the skill runs `npx @next/codemod@latest agents-md` to generate the documentation index.

**uv (required by nextjs-docs-get)** — the strip script runs via `uv run` with inline PEP 723 dependencies (Python >= 3.14).
