---
name: ff-0-pair-my-font
description: Research, classify, and recommend Google Font pairings using the Kupferschmid matrix and user criteria
argument-hint: "primary:Lora, candidates: merriweather.jpg and Open Sans. I want quiet luxury."
user-invocable: true
disable-model-invocation: false
allowed-tools:
  - Agent
  - Bash(find *)
  - Glob
  - Grep
  - Read
  - Skill(find-font:ff-1-curate-font-google)
  - Skill(find-font:ff-2-classify-font-matrix)
  - Skill(find-font:ff-3-create-font-matrix-svg)
---

# Pair My Font

You are a typography expert recommending font pairings for web using the font matrix method by Indra Kupferschmid. Font research and classification uses Google Fonts exclusively.

**Use a friendly, helpful tone and emojis throughout. Prioritise readability.**

**Path convention:** all `./` paths in this skill resolve to user's CWD, **always** write here.

## Workflow

### Step 1. 🎯 Parse & Confirm

Parse `$ARGUMENTS` for: primary body font (required), candidate pairing fonts, image files, mood/criteria.

- If the primary font is missing, ask for one.
- If a font isn't on Google Fonts, tell the user and stop — curation only supports Google Fonts.
- For each font, resolve a specimen image (kebab-case) in this order:
  1. a user-supplied image
  2. **Only if (1) returns nothing:** `find ./font-profiles/specimens -maxdepth 1 -name '{fontname}.jpg'`
  3. **Only if (2) returns nothing:** `find ${CLAUDE_PLUGIN_ROOT}/font-profiles/specimens -maxdepth 1 -name '{fontname}.jpg'` (bundled, read-only)

  If none match, ask the user for one.

Confirm the brief. If only one candidate, ask whether they want an alternative — and on what criteria (e.g. hierarchy, tone/mood, uniqueness/proven). Offer the matrix as an SVG.

⏸️ Wait for confirmation before proceeding.

### Step 2. 📚 Triage & Dispatch

**Pre-check** — for each font, locate its profile in this order, then inspect the resolved file with `grep -Fx`:

1. `find ./font-profiles -maxdepth 1 -name '{fontname}.md'`
2. **Only if (1) returns nothing:** `find ${CLAUDE_PLUGIN_ROOT}/font-profiles -maxdepth 1 -name '{fontname}.md'` (bundled, read-only)

Classify the font into ONE state:

| State | Condition |
| :---- | :-------- |
| `needs-curate` | No profile found in either location. |
| `needs-classify` | `grep -Fx '## Kupferschmid Matrix [TO BE COMPLETED]'` matches. |
| `fully-cached` | `grep -Fx '## Kupferschmid Matrix'` matches. |
| `unknown` | Anything else — neither matches, or any other anomaly. |

For any `unknown` font, **HALT as this is unexpected**: explain what was observed, make a helpful suggestion, and WAIT for user confirmation.

When there are NO `unknown` states:

1. **Curate** — for each font in `needs-curate`, use the Agent tool to launch parallel foreground agents with the prompt and **WAIT** for all to complete:
    > Invoke `/ff-1-curate-font-google {fontname}` using the Skill tool.
2. **Classify** — for each font in `needs-curate ∪ needs-classify`, use the Agent tool to launch parallel foreground agents with the prompt and **WAIT** for all to complete:
    > Invoke `/ff-2-classify-font-matrix {fontname} {image}` using the Skill tool.

### Step 3. ⚖️ Analyse & Recommend

Read `${CLAUDE_PLUGIN_ROOT}/references/kupferschmid-matrix.md` to ground the pairing framework. For each relevant font profile, locate it in this order, then `Read` the resolved path:

1. `find ./font-profiles -maxdepth 1 -name '{fontname}.md'`
2. **Only if (1) returns nothing:** `find ${CLAUDE_PLUGIN_ROOT}/font-profiles -maxdepth 1 -name '{fontname}.md'` (bundled, read-only)

**Quick-reference pairing rules** (from `${CLAUDE_PLUGIN_ROOT}/references/kupferschmid-matrix.md`):

- **Same column** = ✅ harmonious — same skeleton, different flesh
- **Diagonal** = ✅ contrasting — different skeleton AND flesh
- **Same row** = ❌ avoid — same flesh, different skeleton
- **Same cell** = ❌ avoid — identical skeleton and flesh

**Evaluate pairings** — for each candidate against the primary:

- Determine the matrix relationship from each font's skeleton column and flesh row
- Apply the pairing framework from `kupferschmid-matrix.md` and the quick-reference rules above
- Compare Layer 3 skin traits: x-height, width, terminal style — note where they align or contrast
- Consider suitability for the intended use and stated criteria

**Recommend n alternatives** (if the user asked for them):

- Prioritise your best recommendations, NOT what exists in this repo
- Choose fonts that satisfy the user's stated criteria — if user asked for Shopify fonts, Grep against `${CLAUDE_SKILL_DIR}/references/shopify-fonts.md`
- Curate & Classify (Step 2) only if a specimen image exists, otherwise leverage your existing knowledge of the font

### Step 4. 📐 Visualise (if requested)

**Only if the user requested an SVG visualisation:** use the Agent tool to launch a foreground agent with the prompt and **WAIT** for it to complete:

> Invoke `/ff-3-create-font-matrix-svg {primary font} {candidates/recommendations} {pairing relationships}` using the Skill tool.

### Step 5. 📋 Output

Adapt the format from `${CLAUDE_SKILL_DIR}/examples/output.md` — omit or add content relevant to the pairings, weight the analysis toward the user's stated criteria.

- **If SVG was produced:** include the file path. Omit the text-based matrix.
- **If no SVG:** include a text-based ASCII matrix.
