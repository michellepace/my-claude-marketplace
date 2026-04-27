# Plugin: `find-font`

**Font pairing (orchestrator pattern):** Recommend Google Font pairings using the [Kupferschmid font matrix](https://fonts.google.com/knowledge/choosing_type/pairing_typefaces_based_on_their_construction_using_the_font_matrix) — a three-layer classification system (skeleton, flesh, skin) for choosing typefaces that work together.

Give it a primary body font, optional candidates, and a mood or criteria. It classifies each font on the matrix, evaluates pairings, and recommends fonts that match your brief.

Add marketplace and install this plugin (project scope):

```bash
# 1. Add Marketplace
claude plugin marketplace add michellepace/my-claude-marketplace --scope project

# 2. Install Plugin "find-font"
claude plugin install find-font@my-claude-marketplace --scope project
```

<div align="center">
  <a href="skills/ff-3-create-font-matrix-svg/templates/kupferschmid-template.svg" target="_blank">
    <img src="skills/ff-3-create-font-matrix-svg/templates/kupferschmid-template.svg" alt="Kupferschmid font matrix showing Lora as primary with Alegreya Sans and Open Sans as harmonious same-column pairings, Raleway as a contrasting diagonal pairing, and Cormorant Garamond marked as avoid." width="700">
  </a>
  <p><em>Example: Lora (primary) with four candidates classified by matrix relationship — green for harmonious (same column), purple for contrasting (diagonal), red for avoid (same row/cell).</em></p>
</div>

## What's Inside

| Run Skill | What it does |
| :-------- | :----------- |
| [`/ff-0-pair-my-font`](skills/ff-0-pair-my-font/SKILL.md) | Orchestrator — parses brief, launches workers, evaluates pairings, outputs recommendations |
| [`/ff-1-curate-font-google`](skills/ff-1-curate-font-google/SKILL.md) | Fetches font data from Google Fonts and writes a structured font profile |
| [`/ff-2-classify-font-matrix`](skills/ff-2-classify-font-matrix/SKILL.md) | Examines a specimen image and classifies the font on the Kupferschmid matrix |
| [`/ff-3-create-font-matrix-svg`](skills/ff-3-create-font-matrix-svg/SKILL.md) | Creates an SVG visualisation with font cards and pairing arrows |

All four skills are independently invocable.

## Usage

**Orchestrator:**

- `/ff-0-pair-my-font` primary: Lora, candidates: Jost, Open Sans. I want quiet luxury.
- `/ff-0-pair-my-font` primary: Merriweather Sans @merriweather-sans.jpg, constrain to Shopify fonts
- `/ff-0-pair-my-font` primary: Newsreader (recommend alternatives for editorial blog)
- `/ff-0-pair-my-font` primary: Lora, candidates: Cormorant Garamond, Jost. Clean luxury. Make an SVG.

**Individual skills:**

- `/ff-1-curate-font-google` Lora
- `/ff-2-classify-font-matrix` Raleway
- `/ff-3-create-font-matrix-svg` primary: Lora (Dynamic, Contrast Serif). Candidates: Jost (Geometric, Linear Sans) — diagonal contrasting pair; Source Sans 3 (Dynamic, Linear Sans) — same column harmonious pair.

## Reference Files

| File | Purpose / Explanation |
|---|---|
| [`kupferschmid-matrix.md`](references/kupferschmid-matrix.md) | ***Foundation.*** Kupferschmid matrix framework for classifying and pairing fonts |
| [`font-profiles/`](font-profiles/) | ***Core Data (read-only seed/fallback).*** Per-font research (synopsis, characteristics, technical specs) and matrix classification, shipped with the plugin. Includes font specimen images used for visual matrix classification. New profiles and user-supplied specimens always land in `./font-profiles/` in your CWD — never in the bundle. |
| [`shopify-fonts.md`](skills/ff-0-pair-my-font/references/shopify-fonts.md) | ***Optional Constraint.*** Enables Claude to constrain recommendations to Shopify fonts (subset of Google Fonts). |
| [`output.md`](skills/ff-0-pair-my-font/examples/output.md) | ***Example Formatting.*** Claude adapts content to the fonts and stated criteria |
| [`kupferschmid-template.svg`](skills/ff-3-create-font-matrix-svg/templates/kupferschmid-template.svg) | ***Output Visualisation.*** Clean SVG template Claude copies and modifies. |

## Matrix Visualisation

Ask for an SVG and you get the image shown above. Otherwise, a terminal text equivalent — see [`output.md`](skills/ff-0-pair-my-font/examples/output.md).

## Dependencies

**Ref MCP (required)** — configured in [`.mcp.json`](.mcp.json). Used to fetch font data from Google Fonts specimen pages and GitHub METADATA.pb files — Claude's built-in `WebFetch` can't read the Google Fonts SPA.

**Google Fonts only** — curation depends on two structured sources only Google Fonts provides (specimen page + METADATA.pb). Other catalogues would need web search — slower and less reliable.

So Claude can render the SVG matrix to PNG, install `rsvg-convert`:

```bash
sudo apt install librsvg2-bin
```

## Future Improvements

- **Tighten recommendation output** — it's very verbose, adjust [`output.md`](skills/ff-0-pair-my-font/examples/output.md)
- **Python SVG generator** — a script that takes font card data and plots them onto the SVG template (cards and connectors), replacing manual SVG editing by Claude
