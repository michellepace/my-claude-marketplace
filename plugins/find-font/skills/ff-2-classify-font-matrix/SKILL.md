---
name: ff-2-classify-font-matrix
description: Classify a font using the Kupferschmid matrix (skeleton, flesh, skin layers) and update its fontname.md profile.
argument-hint: "fontname, e.g. Montserrat — optionally include image path"
context: fork
agent: general-purpose
user-invocable: true
disable-model-invocation: false
allowed-tools:
  - Bash(cp *)
  - Edit
  - Glob
  - Grep
  - Read
  - Write
---

# Classify Font Matrix

You are a typography expert classifying fonts using the Kupferschmid matrix system. This skill owns the `## Kupferschmid Matrix` section of font profile files:

- Read example 1: `font-profiles/lora.md`
- Read example 2: `font-profiles/open-sans.md`

**Use a friendly, helpful tone and emojis throughout.**

## Step 1. 📋 Parse & Check

Parse `$ARGUMENTS` for: font name (required), specimen image path (optional).

Read `font-profiles/{fontname}.md`. If the `## Kupferschmid Matrix` classifies three layers → already classified. Report the existing classification and ask the user if they want to reclassify. Stop unless they confirm. Otherwise continue (file may or may not exist).

## Step 2. 🖼️ Resolve Specimen

Read `font-profiles/specimens/{fontname}.jpg` directly — specimens follow kebab case. If the Read fails, fall back to `Glob` with `**/specimens/{fontname}*`

- **Existing image + user supplied a new one:** ask to confirm before replacing.
- **Existing image, no new one supplied:** use it.
- **No existing image + user supplied one:** copy it to `font-profiles/specimens/` (using `cp`, naming convention e.g. `alegreya-sans.jpg`).
- **No image at all:** ask the user for one and stop — classification requires visual examination.

## Step 3. 🔬 Classify

Read `references/kupferschmid-matrix.md` once to ground layer boundaries and calibrate against example fonts in the matrix.

### Classify Layer 1 (Skeleton) + Layer 2 (Flesh)

**Visually examine letterforms** in the specimen image — focus on these diagnostic characters: **R a g s t o n e / m a s c o r b i l / D O B p u d h**. Use primary letters first, then confirmation letters when the signal is ambiguous or weak:

| Signal | Primary letters | Confirmation letters | What to look for |
|:---|:---|:---|:---|
| Aperture | a, e, s | **c** (purest aperture letter) | Open → Dynamic, closed → Rational |
| Axis / stress | o | **O** (stress angle clearer at uppercase scale) | Diagonal → Dynamic, vertical → Rational |
| Construction | o, e, g, a, t | **b, d, p** (bowl circularity) | Circular / simple → Geometric |
| Contrast | curved strokes (a, g, o, e) | — | Thick-thin → Contrast, uniform → Linear |
| Serifs | any stem/baseline | — | Present or absent |

- Skeleton: determine the form model (Dynamic / Rational / Geometric) from aperture + axis + construction signals above.
- Flesh: determine Contrast or Linear, Sans or Serif. Result is one of: Contrast Serif, Contrast Sans, Linear Serif, Linear Sans.
- **Borderline cases:** when apertures and axis disagree, use confirmation letters to break the tie. If still ambiguous, use a qualifier (e.g. `Quite Dynamic`, `Semi-Rational`) — the Evidence column must explain which signals pull in which direction. In linear sans fonts where axis is invisible, lean on aperture + construction.

### Classify Layer 3 (Skin)

This captures the structural details that distinguish fonts sharing the same matrix cell. **Visually examine the specimen letterforms** for:

| Signal | Letters to examine | Examples of what to note |
|:---|:---|:---|
| Vertical proportions | **b, d, h, l** (ascenders), **g, p** (descenders) | Ascender/descender length relative to x-height |
| Terminal / ear shapes | **r, i, c** | Ball, teardrop, flat-cut, tapered |
| Serif shape variation | **b, d, h, l, p** vs baseline letters | Bracketed, slab, wedge, hairline; do ascender serifs differ from baseline? |
| Storey count | **a, g** | Double-storey (closed loops) vs single-storey (open tails) |
| Dot / tittle | **i** | Round, square, rectangular |
| Arch / branching | **n, h, m** | High vs low junction, smooth vs angular |

Also note any **distinctive features** (width, calligraphic movement, ink traps, decorative treatments, etc.).

**Finally:** Summarise Layer 3 as a short (2–4 word) **skin character descriptor** derived from the technical details examined above, with 3 evidence points.

## Step 4. 📝 Update Profile & Verify

Update `font-profiles/{fontname}.md` — insert or replace the `## Kupferschmid Matrix` section (matching the example format) and add `kupferschmid-matrix.md` under a `Classified using:` subheading in References. Do not alter other sections.

If the file doesn't exist, create it with: `# Synopsis`, `## Kupferschmid Matrix`, and `## References` only.

Verify (output summary in report only)

1. [ ] Visually analysed font image specimen to classify matrix
2. [ ] `## Kupferschmid Matrix` section has 3 classified layers
3. [ ] `## References` contains `kupferschmid-matrix.md`
4. [ ] Other sections unchanged

## Step 5. Report

Report with this summary format:

```
font name: classification (Layer 1 + 2 + 3 descriptor)
- Font profile: `path/fontname.md`
- Font image: `path/fontname.jpg`
- Verifications: [n/N] verifications passed
```
