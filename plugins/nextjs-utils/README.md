# Plugin: `nextjs-utils`

**shadcn/ui best practices for Next.js.**

Add marketplace and install this plugin (project scope):

```bash
# 1. Add Marketplace
claude plugin marketplace add michellepace/my-claude-marketplace --scope project

# 2. Install Plugin "nextjs-utils"
claude plugin install nextjs-utils@my-claude-marketplace --scope project
```

## What's Inside

| Run Skill | What it does |
| :-------- | :----------- |
| [`/nextjs-shadcn-ui`](skills/nextjs-shadcn-ui/SKILL.md) | Best practices for adding, customising, and architecting shadcn/ui components (Radix UI + Tailwind CSS) in Next.js |

## Usage Examples

- `/nextjs-shadcn-ui` I need a "soft" button variant with a muted background from my theme
- `/nextjs-shadcn-ui` How should I structure a settings page with sidebar nav and form sections?
- `/nextjs-shadcn-ui` Replace the deprecated Toast component — what's the current approach?

## Reference Files

| File | Purpose |
| :--- | :--- |
| [`changelog-summary.md`](skills/nextjs-shadcn-ui/references/changelog-summary.md) | Key shadcn/ui changes from Jun 2025 onwards (beyond Opus 4.6 training data) |
| [`llms-txt.md`](skills/nextjs-shadcn-ui/references/llms-txt.md) | Full component index with docs URLs, extracted from ui.shadcn.com/llms.txt |
| [`.mcp.json`](.mcp.json) | Ref MCP server config for reading shadcn/ui docs |

## Dependencies

**Ref MCP (required)** — configured in [`.mcp.json`](.mcp.json). The skill uses `ref_read_url` and `ref_search_documentation` to check shadcn/ui docs.
