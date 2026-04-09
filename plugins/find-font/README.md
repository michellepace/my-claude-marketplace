# Plugin: `find-font`

**Font pairing (orchestrator pattern):** Research, classify, and recommend Google Font pairings using the [Kupferschmid font matrix](https://fonts.google.com/knowledge/choosing_type/pairing_typefaces_based_on_their_construction_using_the_font_matrix) — a three-layer classification system (skeleton, flesh, skin) for choosing typefaces that work together.

Give it a primary body font, optional candidates, and a mood or criteria. It fetches font data, classifies each font on the matrix, evaluates pairings, and recommends fonts that match your brief.

Add marketplace and install this plugin (project scope):

```bash
# 1. Add Marketplace
claude plugin marketplace add michellepace/my-claude-marketplace --scope project

# 2. Install Plugin "find-font"
claude plugin install find-font@my-claude-marketplace --scope project
```

<div align="center">
  <a href="skills/ff-3-create-font-matrix-svg/references/kupferschmid-template.svg" target="_blank">
    <img src="skills/ff-3-create-font-matrix-svg/references/kupferschmid-template.svg" alt="Kupferschmid font matrix showing Lora as primary with Alegreya Sans and Open Sans as harmonious same-column pairings, Raleway as a contrasting diagonal pairing, and Cormorant Garamond marked as avoid." width="700">
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

| File | Used By Skill(s) | Purpose / Explanation |
|---|---|---|
| [`kupferschmid-matrix.md`](references/kupferschmid-matrix.md) | [ff-0-pair-my-font](skills/ff-0-pair-my-font/SKILL.md), [ff-2-classify-font-matrix](skills/ff-2-classify-font-matrix/SKILL.md) | ***Foundation.*** Kupferschmid matrix framework for classifying and pairing fonts |
| [`font-profiles/*.md`](font-profiles/) | [ff-0-pair-my-font](skills/ff-0-pair-my-font/SKILL.md), [ff-1-curate-font-google](skills/ff-1-curate-font-google/SKILL.md), [ff-2-classify-font-matrix](skills/ff-2-classify-font-matrix/SKILL.md) | ***Core Data.*** Per-font research (synopsis, characteristics, technical specs) and matrix classification, created by plugin usage |
| [`specimens/*.jpg`](font-profiles/specimens) | [ff-0-pair-my-font](skills/ff-0-pair-my-font/SKILL.md), [ff-2-classify-font-matrix](skills/ff-2-classify-font-matrix/SKILL.md) | ***Core Data (input to classify).*** User-provided font specimens are copied here, needed for matrix classification |
| [`shopify-fonts.md`](skills/ff-0-pair-my-font/references/shopify-fonts.md) | [ff-0-pair-my-font](skills/ff-0-pair-my-font/SKILL.md) | ***Optional Constraint.*** Enables Claude to constrain recommendations to Shopify fonts (subset of Google Fonts). |
| [`example-output.md`](skills/ff-0-pair-my-font/references/example-output.md) | [ff-0-pair-my-font](skills/ff-0-pair-my-font/SKILL.md) | ***Output Formatting.*** Sample recommendation (pairing cards, matrix, comparison table), Claude adapts content to the fonts and stated criteria |
| [`kupferschmid-template.svg`](skills/ff-3-create-font-matrix-svg/references/kupferschmid-template.svg) | [ff-3-create-font-matrix-svg](skills/ff-3-create-font-matrix-svg/SKILL.md) | ***Output Visualisation.*** Clean SVG template Claude copies and modifies to visualise font matrix positions |

## Matrix Visualisation

When requested, the skill copies the SVG template and edits it to place the analysed fonts on the matrix with colour-coded cards and directional arrows showing each pairing relationship. This is the image shown above. If it is not requested, then a terminal text equivalent is presented, as shown in [`example-output.md`](skills/ff-0-pair-my-font/references/example-output.md)

## Dependencies

**Ref MCP (required)** — configured in [`.mcp.json`](.mcp.json). The skill fetches font data from Google Fonts specimen pages and GitHub METADATA.pb files via `ref_read_url`. This is not optional — Google Fonts is a JavaScript-heavy SPA that Claude's built-in `WebFetch` cannot read. Without Ref MCP, font curation will fail.

**Google Fonts only** — font research and classification relies on two dependable, structured sources (specimen page + METADATA.pb) that only exist for Google Fonts. This keeps curation fast and consistent. Supporting other catalogues would require web searching for equivalent data, which is slower and less reliable — but the skills could be extended for this if needed.

So Claude can render the SVG matrix to PNG, install `rsvg-convert`:

```bash
sudo apt install librsvg2-bin
```

## Future Improvements

- **Tighten recommendation output** — it's very verbose, adjust [`example-output.md`](skills/ff-0-pair-my-font/references/example-output.md)
- **Python SVG generator** — a script that takes font card data and plots them onto the SVG template (cards and connectors), replacing manual SVG editing by Claude
