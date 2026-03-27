# Plugin: Find My Font

Research, classify, and recommend Google Font pairings using the [Kupferschmid font matrix](https://fonts.google.com/knowledge/choosing_type/pairing_typefaces_based_on_their_construction_using_the_font_matrix) — a three-layer classification system (skeleton, flesh, skin) for choosing typefaces that work together.

Give it a primary body font, optional candidates, and a mood or criteria. It fetches font data, classifies each font on the matrix, evaluates pairings, and recommends fonts that match your brief.

## What's Inside - Skills

| Command | What it does |
|---|---|
| `/find-my-font` | Orchestrator — parses brief, launches workers, evaluates pairings, outputs recommendations |
| `/find-my-font:curate-font` | Fetches font data from Google Fonts and writes a structured font profile |
| `/find-my-font:classify-font-matrix` | Examines a specimen image and classifies the font on the Kupferschmid matrix |
| `/find-my-font:create-svg-matrix` | Creates an SVG visualisation with font cards and pairing arrows |

All four skills are independently invocable.

## Usage

**Orchestrator:**

- `/find-my-font` primary: Lora, candidates: Jost, Open Sans. I want quiet luxury.
- `/find-my-font` primary: Merriweather Sans @merriweather-sans.jpg, constrain to Shopify fonts
- `/find-my-font` primary: Newsreader (recommend alternatives for editorial blog)
- `/find-my-font` primary: Lora, candidates: Cormorant Garamond, Jost. Clean luxury. Make an SVG.

**Individual skills:**

- `/find-my-font:curate-font` Lora
- `/find-my-font:classify-font-matrix` Raleway
- `/find-my-font:create-svg-matrix` primary: Lora (Dynamic, Contrast Serif). Candidates: Jost (Geometric, Linear Sans) — diagonal contrasting pair; Source Sans 3 (Dynamic, Linear Sans) — same column harmonious pair.

## Reference Files

| File | Used by | Purpose |
|---|---|---|
| [`kupferschmid-matrix.md`](references/kupferschmid-matrix.md) | orchestrator, classify | Three-layer classification framework and pairing rules |
| [`example-output.md`](references/example-output.md) | orchestrator | Output format template |
| [`kupferschmid-matrix-template.svg`](references/kupferschmid-matrix-template.svg) | create-svg-matrix | Base SVG with grid, styling, and legend |
| [`shopify-fonts.md`](references/shopify-fonts.md) | orchestrator | Shopify font catalogue — grepped when user constrains to Shopify |
| [`fonts/*.md`](references/fonts/) | curate, classify, orchestrator | Font profiles — created by curate, updated by classify, read by orchestrator |
| [`fonts/images/*.jpg`](references/fonts/images/) | classify | Specimen images for visual classification |

## Matrix Visualisation

When requested, the skill copies the SVG template and edits it to place the analysed fonts on the matrix with colour-coded cards and directional arrows showing each pairing relationship.

<div align="center">
  <a href="references/kupferschmid-matrix-template.svg" target="_blank">
    <img src="references/kupferschmid-matrix-template.svg" alt="Kupferschmid font matrix showing Lora as primary with Alegreya Sans and Open Sans as harmonious same-column pairings, Raleway as a contrasting diagonal pairing, and Cormorant Garamond marked as avoid." width="700">
  </a>
  <p><em>Example: Lora (primary) with four candidates classified by matrix relationship — green for harmonious (same column), purple for contrasting (diagonal), red for avoid (same row/cell).</em></p>
</div>

## Dependencies

**Ref MCP (required)** — configured in [`.mcp.json`](.mcp.json). The skill fetches font data from Google Fonts specimen pages and GitHub METADATA.pb files via `ref_read_url`. This is not optional — Google Fonts is a JavaScript-heavy SPA that Claude's built-in `WebFetch` cannot read. Without Ref MCP, font curation will fail.

**Google Fonts only** — font research and classification relies on two dependable, structured sources (specimen page + METADATA.pb) that only exist for Google Fonts. This keeps curation fast and consistent. Supporting other catalogues would require web searching for equivalent data, which is slower and less reliable — but the skills could be extended for this if needed.

So Claude can render the SVG matrix to PNG, install `rsvg-convert`:

```bash
sudo apt install librsvg2-bin
```

## Future Improvements

- **Python SVG generator** — a script that takes font card data and plots them onto the SVG template (cards and connectors), replacing manual SVG editing by Claude
