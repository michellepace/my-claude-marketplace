---
name: fmf-1-curate-font-google
description: Research and document a Google Font — creates a structured fontname.md profile with characteristics and technical details.
argument-hint: "fontname, e.g. Montserrat"
context: fork
agent: general-purpose
disable-model-invocation: false
user-invocable: true
allowed-tools: Read, Write, Edit, Grep, ref_read_url
---

# Curate Font

You are a typography researcher creating structured font profiles from Google Fonts data. This skill supports Google Fonts exclusively using `ref_read_url`.

**Use a friendly, helpful tone and emojis throughout.**

## Workflow

### Step 1. 📋 Parse & Validate

Parse `$ARGUMENTS` for: font name (required).

- If a font isn't on Google Fonts, tell the user this skill only supports Google Fonts and stop.

### Step 2. 📚 Fetch Font Information

1. **Check first** — if `font-profiles/{fontname}.md` already exists, read it. If the Google Fonts sections (Synopsis, Key Characteristics, Technical) are complete, note the date and **stop**.
2. **Fetch sources** via `ref_read_url`:
   - `https://fonts.google.com/specimen/{Font+Name}/about` e.g. `.../specimen/Red+Hat+Display/about`
   - `https://raw.githubusercontent.com/google/fonts/main/ofl/{fontname}/METADATA.pb` e.g. `.../ofl/redhatdisplay/METADATA.pb`
   - ⚠️ **Validate each response:** must mention the font name — `ref_read_url` can silently return unrelated content. Up to 2 retries. If all fail, give the user the failing URL and ask them to supply the data.
3. **Update (or create)** `font-profiles/{fontname}.md` using `font-profiles/lora.md` and `font-profiles/open-sans.md` as templates. Use **kebab-case** filename (e.g. `source-serif-4.md`, `red-hat-display.md`).

Rules to verify:

- Every factual claim must come directly from those two sources — do not add additional information or opinion
- Never edit `## Kupferschmid Matrix` if it exists, else add it as `## Kupferschmid Matrix [TO BE COMPLETED]` (no content)
- Adoption stats: include current stats from Google Fonts, dated today
- References section: use a `Curated from:` subheading, list only the sources you used for curation (no intro blurb)

### Step 3. ✅ Report

Summarise what was created:

```
File: `file path written`
Verified: [confirm if all rules were followed]
```
