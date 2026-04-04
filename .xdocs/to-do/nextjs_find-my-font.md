# Find My Font: As a Next.js App

## Current State

Three reference documents are staged in git (not yet committed):

- `plugin_plugin-dev.md` — documents the plugin-dev plugin
- `plugin_skill-creator.md` — documents the skill-creator plugin
- `plugin_strategy_eval.md` — evaluation strategy for find-my-font

Copies also live in `~/projects/useful/`.

## Your find-my-font Plugin

A Claude Code plugin with an **orchestrator-worker pattern**:

- **4 skills**: `fmf-0-pair-my-font` (orchestrator) -> spawns `fmf-1-curate-font-google`, `fmf-2-classify-font-matrix`, `fmf-3-create-font-matrix-svg` in parallel
- **Kupferschmid 3-layer classification**: Skeleton (Dynamic/Rational/Geometric) -> Flesh (contrast+serif combos) -> Skin (fine details), organized in a 3x4 matrix
- **Pairing rules**: same column = harmonious, diagonal = contrasting, same row/cell = avoid
- **Hard dependency on Ref MCP** (`https://api.ref.tools/mcp`) for fetching Google Fonts data (Google Fonts is a JS SPA that WebFetch can't scrape)
- **SVG generation**: template-based -- Claude copies a template SVG and manually edits it to place font cards and draw color-coded arrows
- 46 files total, 10 curated font profiles, 25 specimen JPGs

## Your Goals

1. **Build a Next.js app** that classifies fonts, does pairings, and generates matrix SVGs
2. **Evaluate** whether the Kupferschmid classifications and pairings are actually accurate
3. **Transfer** the plugin's functionality -- possibly via the **Claude Code Agent SDK**
4. You're uncertain whether the Agent SDK can even handle this pattern (MCP integration, orchestrator-worker, etc.)

## Open Questions

- How to access Google Fonts data without Ref MCP in a web app context
- How to implement Kupferschmid classification in application code vs. having Claude do it
- How to generate SVGs programmatically (currently Claude edits a template by hand)
- How to set up automatic evals for font classification correctness and pairing quality

---

> Note the below output was produced after running `/claude-api`

*Now I have both your project context **and** the full Claude API / Agent SDK documentation loaded. Here's what's relevant to your goals:*

## What I Know About Your Project

(Same as before -- find-my-font plugin with 4 skills, Kupferschmid classification, Ref MCP dependency, SVG generation, 46 files.)

## What I Now Know About the Tools Available

### Agent SDK (Python & TypeScript)

The Agent SDK can **absolutely** replicate your plugin's orchestrator-worker pattern:

- **Subagents** map directly to your worker skills (`fmf-1-curate-font-google`, `fmf-2-classify-font-matrix`, `fmf-3-create-font-matrix-svg`)
- **MCP support** is built in -- your Ref MCP server (`https://api.ref.tools/mcp`) can be passed via `mcpServers`
- **Custom tools** via `@tool` decorator (Python) or `betaZodTool` (TypeScript)
- **Hooks** for logging, auditing, or intercepting tool calls
- **`query()` + `ClaudeSDKClient`** -- simple one-shot or full lifecycle control

### Claude API (for the Next.js app)

- **TypeScript SDK** (`@anthropic-ai/sdk`) -- your Next.js backend would use this
- **Tool use** -- define Kupferschmid classification as a structured tool, force via `tool_choice`
- **Structured outputs** (`output_config.format` + Zod) -- guarantee valid JSON for classifications and pairings
- **Streaming** -- for real-time UI feedback
- **Code execution tool** -- could generate SVGs server-side with matplotlib/pillow
- **Adaptive thinking** -- for complex classification reasoning

### Key Architectural Decision

| Approach | Surface | When |
| :-- | :-- | :-- |
| Port plugin logic to standalone agent | **Agent SDK** | Testing/eval, CLI usage, batch processing |
| Build the Next.js app | **Claude API + tool use** | Production web app with UI |
| Both | Agent SDK for evals, API for production | Most likely path |

## What I Don't Know Yet

1. Your Next.js project structure in `/home/mp/projects/nextjs/devflow` -- haven't looked at it
2. Whether you want Python or TypeScript for the Agent SDK work
3. How you want to handle Google Fonts data access without Ref MCP in the web app
