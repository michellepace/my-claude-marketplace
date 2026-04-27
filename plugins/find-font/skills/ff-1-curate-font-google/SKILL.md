---
name: ff-1-curate-font-google
description: Research and document a Google Font — creates a structured fontname.md profile with characteristics and technical details.
argument-hint: "fontname, e.g. Montserrat"
context: fork
agent: general-purpose
user-invocable: true
disable-model-invocation: false
allowed-tools:
  - Bash(mkdir *)
  - Edit
  - Grep
  - Read
  - Write
  - mcp__Ref__ref_read_url
---

# Curate Font

You are a typography researcher creating structured font profiles from Google Fonts data. This skill supports Google Fonts exclusively using `ref_read_url`.

**Use a friendly, helpful tone and emojis throughout.**

**Path convention:** all `./` paths in this skill resolve to user's CWD, **always** write here.

## Workflow

### Step 1. 📋 Parse & Validate

Parse `$ARGUMENTS` for: font name (required).

- If a font isn't on Google Fonts, tell the user this skill only supports Google Fonts and stop.

### Step 2. 📚 Fetch Font Information

1. **Check first** — look up an existing profile in this order, and if the Google Fonts sections (Synopsis, Key Characteristics, Technical) are complete, note the date and **stop** (write nothing):
   1. `./font-profiles/{fontname}.md`
   2. `${CLAUDE_PLUGIN_ROOT}/font-profiles/{fontname}.md` (bundled, read-only)
2. **Fetch sources** via `ref_read_url`:
   - `https://fonts.google.com/specimen/{Font+Name}/about` e.g. `.../specimen/Red+Hat+Display/about`
   - `https://raw.githubusercontent.com/google/fonts/main/ofl/{fontname}/METADATA.pb` e.g. `.../ofl/redhatdisplay/METADATA.pb`
   - ⚠️ **Validate each response:** must mention the font name — `ref_read_url` can silently return unrelated content. Up to 2 retries. If all fail, give the user the failing URL and ask them to supply the data.
3. **Write profile** to `./font-profiles/{fontname}.md` (kebab-case, e.g. `source-serif-4.md`) using `${CLAUDE_PLUGIN_ROOT}/font-profiles/lora.md` and `${CLAUDE_PLUGIN_ROOT}/font-profiles/open-sans.md` as templates.

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
