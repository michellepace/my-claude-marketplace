# Plugin: `for-nextjs`

Next.js development skills: shadcn/ui component best practices and official documentation management.

## What's Inside - Skills

| Command | What it does |
|---|---|
| `/shadcn-ui` | Best practices for adding, customising, and architecting shadcn/ui components (Radix UI + Tailwind CSS) in Next.js |
| `/get-nextjs-docs` | Downloads and trims official Next.js documentation for Claude Code reference usage |

Both skills are independently invocable.

## Usage Examples

**shadcn/ui:**

- `/shadcn-ui` I need a "soft" button variant with a muted background from my theme
- `/shadcn-ui` How should I structure a settings page with sidebar nav and form sections?
- `/shadcn-ui` Replace the deprecated Toast component — what's the current approach?

**Get Next.js Docs:**

- `/get-nextjs-docs` (generates, consolidates, and trims `.nextjs-docs/` for the current project)

## Reference Files

| File | Used By | Purpose |
|---|---|---|
| [`changelog-summary.md`](skills/shadcn-ui/references/changelog-summary.md) | shadcn-ui | Key shadcn/ui changes from Jun 2025 onwards (beyond Opus 4.6 training data) |
| [`llms-txt.md`](skills/shadcn-ui/references/llms-txt.md) | shadcn-ui | Full component index with docs URLs, extracted from ui.shadcn.com/llms.txt |
| [`strip-nextjs-index.py`](skills/get-nextjs-docs/scripts/strip-nextjs-index.py) | get-nextjs-docs | Python script to remove directory sections from agents-md INDEX.md and verify consistency |
| [`.mcp.json`](.mcp.json) | shadcn-ui | Ref MCP server config for reading shadcn/ui docs |

## Dependencies

**Ref MCP (required by shadcn-ui)** — configured in [`.mcp.json`](.mcp.json). The shadcn-ui skill uses `ref_read_url` and `ref_search_documentation` to check shadcn/ui docs.

**npx (required by get-nextjs-docs)** — the skill runs `npx @next/codemod@latest agents-md` to generate the documentation index.

**uv (required by get-nextjs-docs)** — the strip script runs via `uv run` with inline PEP 723 dependencies (Python >= 3.14).
