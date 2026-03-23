# About find-my-font

Research, classify, and recommend Google Font pairings using the [Kupferschmid font matrix](https://fonts.google.com/knowledge/choosing_type/pairing_typefaces_based_on_their_construction_using_the_font_matrix) — a three-layer classification system (skeleton, flesh, skin) for choosing typefaces that work together.

Give it a primary body font, optional candidates, specimen images, and a mood or criteria. The skill fetches font data from Google Fonts, classifies each font on the matrix, evaluates pairings, and recommends fonts that match your brief.

## Usage

```markdown
/find-my-font primary: Lora, candidates: Jost, Open Sans. I want quiet luxury.
/find-my-font primary: Merriweather Sans @merriweather-sans.jpg, constrain to Shopify fonts
/find-my-font primary: Newsreader (recommend alternatives for editorial blog)
```

## What's Inside

| File | Purpose |
|---|---|
| [find-my-font SKILL.md](skills/find-my-font/SKILL.md) | The skill prompt that drives everything |
| [references/example-output.md](references/example-output.md) | Example output format for the skill to follow |
| [references/fonts/](references/fonts/) | Curated font reference files, built up over time |
| [references/kupferschmid-matrix.md](references/kupferschmid-matrix.md) | Matrix classification reference |
| [references/kupferschmid-matrix-template.svg](references/kupferschmid-matrix-template.svg) | Editable SVG template for matrix visualisations (see below) |
| [references/shopify-fonts.md](references/shopify-fonts.md) | Shopify font catalogue for constrained recommendations |

## Matrix Visualisation

When requested, the skill copies the SVG template and edits it to place the analysed fonts on the matrix with colour-coded cards and directional arrows showing each pairing relationship.

<div align="center">
  <a href="references/kupferschmid-matrix-template.svg" target="_blank">
    <img src="references/kupferschmid-matrix-template.svg" alt="Kupferschmid font matrix showing Lora as primary with Alegreya Sans and Open Sans as harmonious same-column pairings, Raleway as a contrasting diagonal pairing, and Cormorant Garamond marked as avoid." width="700">
  </a>
  <p><em>Example: Lora (primary) with four candidates classified by matrix relationship — green for harmonious (same column), purple for contrasting (diagonal), red for avoid (same row/cell).</em></p>
</div>

## Dependencies

The skill uses Ref MCP server (configured in [`.mcp.json`](.mcp.json)) to read Google Fonts pages for font research. If Ref isn't available, it will fall back to Claude's `WebFetch`.

So Claude can check itself when making the SVG matrix image, install `rsvg-convert`:

```bash
sudo apt install librsvg2-bin
```

## Future Improvements

- **Python SVG generator** — a script that takes font card data and plots them onto the static SVG template (cards and connectors), replacing manual SVG editing
- **Agent orchestrator** — re-architect with an `agents/AGENT.md` that orchestrates multiple skills for better context management across the workflow steps
