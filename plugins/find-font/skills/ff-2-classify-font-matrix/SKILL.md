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
  - Bash(find *)
  - Bash(grep *)
  - Bash(mkdir *)
  - Edit
  - Glob
  - Grep
  - Read
  - Write
---

# Classify Font Matrix

You are a typography expert classifying fonts using the Kupferschmid matrix system. This skill owns the `## Kupferschmid Matrix` section of font profile files:

- Read example 1: `${CLAUDE_PLUGIN_ROOT}/font-profiles/lora.md`
- Read example 2: `${CLAUDE_PLUGIN_ROOT}/font-profiles/open-sans.md`

**Use a friendly, helpful tone and emojis throughout.**

**Path convention:** all `./` paths in this skill resolve to user's CWD, **always** write here.

## Step 1. 📋 Parse & Check

Parse `$ARGUMENTS` for: font name (required), specimen image path (optional).

Check if already classified:

1. `grep -Fx '## Kupferschmid Matrix' ./font-profiles/{fontname}.md`
2. `grep -Fx '## Kupferschmid Matrix' "${CLAUDE_PLUGIN_ROOT}/font-profiles/{fontname}.md"`

If either matches → already classified: report it, ask whether to reclassify, and stop unless the user confirms. Otherwise continue.

## Step 2. 🖼️ Resolve Specimen

Locate the specimen (kebab-case):

1. `find ./font-profiles/specimens -maxdepth 1 -name '{fontname}.jpg'`
2. **Only if (1) returns nothing:** `find ${CLAUDE_PLUGIN_ROOT}/font-profiles/specimens -maxdepth 1 -name '{fontname}.jpg'` (bundled, read-only)

- **Existing image + user supplied a new one:** ask to confirm before replacing.
- **Existing image, no new one supplied:** use it.
- **No existing image + user supplied one:** `mkdir -p ./font-profiles/specimens && cp <supplied> ./font-profiles/specimens/{fontname}.jpg` (kebab-case).
- **No image at all:** ask the user for one and stop — classification requires visual examination.

## Step 3. 🔬 Classify

Read `${CLAUDE_PLUGIN_ROOT}/references/kupferschmid-matrix.md` once to ground layer boundaries and calibrate against example fonts in the matrix.

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

If `./font-profiles/{fontname}.md` does not exist:
- If a bundled profile exists, run `mkdir -p ./font-profiles && cp "${CLAUDE_PLUGIN_ROOT}/font-profiles/{fontname}.md" ./font-profiles/{fontname}.md`
- Otherwise, create `./font-profiles/{fontname}.md` with sections `# Synopsis: {fontname}`, `## Kupferschmid Matrix`, and `## References` only.

Write profile to `./font-profiles/{fontname}.md`:
- Insert or replace the `## Kupferschmid Matrix` section.
- Ensure References contains `kupferschmid-matrix.md` under a `Classified using:` subheading.
- Leave all other sections unchanged.

Verify (output summary in report only)

1. [ ] Visually analysed font image specimen to classify matrix
2. [ ] `## Kupferschmid Matrix` section has 3 classified layers
3. [ ] `## References` contains `kupferschmid-matrix.md`

## Step 5. Report

Report with this summary format:

```
font name: classification (Layer 1 + 2 + 3 descriptor)
- Font profile: `./font-profiles/{fontname}.md`
- Font image: `./font-profiles/specimens/{fontname}.jpg`
- Verifications: [n/N] verifications passed
```
