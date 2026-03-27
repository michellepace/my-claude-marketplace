---
name: create-svg-matrix
description: Create an SVG visualization of the Kupferschmid font matrix showing font positions and pairing relationships with arrow connectors.
argument-hint: "primary:Lora, candidates: Jost, Source Sans 3 — include matrix positions and relationships"
context: fork
agent: general-purpose
disable-model-invocation: false
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Bash(rsvg-convert *), Bash(cp *)
---

# Create SVG Matrix

You create SVG visualizations of the Kupferschmid font matrix showing font positions and pairing relationships.

## Workflow

### Step 1. 📋 Parse Arguments

Parse `$ARGUMENTS` for:

- Font names with their matrix positions (skeleton column: Dynamic/Rational/Geometric + flesh row: Contrast Sans/Contrast Serif/Linear Sans/Linear Serif)
- Which font is the primary
- Pairing relationships: ✅ harmonious (same column), ✅ contrasting (diagonal), ❌ avoid (same row or cell)

### Step 2. 🎨 Build SVG

1. `Glob` for `kupferschmid-matrix-template.svg`, then `cp` it to `matrix.svg` — then read and edit `matrix.svg` only (avoid reading duplication).

2. Retain `matrix.svg` styling, labels, and legend — edit only the essential:
   - Font cards: reuse existing card elements, remove redundant ones, and add new cards for each font at its correct matrix position
   - Draw solid arrow connectors from the primary font to each candidate, edge-to-edge: vertical for same-column, horizontal for same-row, diagonal for cross-column

3. Visually verify the SVG is well-formed, then render: `rsvg-convert -w 1000 matrix.svg -o matrix.png`

### Step 3. ✅ Report

Confirm the files were created. Report file paths for both `matrix.svg` and `matrix.png`.
