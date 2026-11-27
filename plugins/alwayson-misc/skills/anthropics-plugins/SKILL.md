---
name: anthropics-plugins
description: Browse `anthropics` GitHub marketplaces and plugins
argument-hint: '"What marketplaces are there?"'
user-invocable: true
disable-model-invocation: true
---

# Anthropic Marketplaces

Map the plugin landscape in https://github.com/anthropics. A marketplace is a repo with `.claude-plugin/marketplace.json` on its default branch. For a broad question, give the landscape; for a specific one, answer just that.

- **Known:** `claude-plugins-official`, `claude-plugins-community`, `skills`, `knowledge-work-plugins`, `financial-services`, `claude-for-financial-advisors`, `claude-for-legal`, `healthcare`, `life-sciences`, `k12-teacher-skills`, `commerce-agents`, `claude-tag-plugins`, `oncall-kit`
- **Skip:** `claude-code` (legacy, duplicated in `claude-plugins-official`), `claude-code-playground` (demo)

## Gather

Work in a fresh scratch directory, so follow-ups query local files instead of refetching. Run scripts with `bash -c`, so `$var` word-splits.

1. **Fetch** each Known file to `<repo>.json`: `gh api -H "Accept: application/vnd.github.raw" repos/anthropics/<repo>/contents/.claude-plugin/marketplace.json`
2. **New ones:** `gh repo list anthropics --source --no-archived --limit 1000 --json name -q '.[].name'`, minus Known and Skip. Fetch each in parallel; most will 404. Propose any hit for Known, or Skip if it mostly duplicates another marketplace.
3. **Updated** (landscape only): `gh api 'repos/anthropics/<repo>/commits?path=.claude-plugin/marketplace.json&per_page=1' --jq '.[0].commit.committer.date[:10]'`

## Landscape

Group marketplaces into categories you choose, one section each. Sort rows newest first, and backtick dates 120+ days old. For example:

```markdown
{10–30 words: answer the user's question, plus anything notable}

## 🌿 GARDENING

| Marketplace | Plugins | Updated | For |
| :-- | --: | :-- | :-- |
| `garden-planner` | 12 | 2026-11-15 | Planting calendars and bed layouts |
| `pest-patrol` | 3 | `2025-09-02` | Identifying and treating garden pests |
```

- **Plugins:** count with jq, excluding descriptions that start with "Deprecated".
- **For:** `.metadata.description // .description`. If blank, vague or long, write one short line from its plugins.

## Specific questions

Answer what's asked, no landscape tables. Speak coherently. State it more simply and concisely, like one human talking to another.

Query the local files with jq; never read one whole. Check `keys` first, as plugin fields vary by marketplace.

### What a plugin contains

When the description isn't enough, look inside:

1. **Locate** it from `.source`: a path in the marketplace repo, or another repo (optional `path`, `sha`).
2. **List** the repo once with `gh api 'repos/<owner>/<repo>/git/trees/<sha or HEAD>?recursive=1'` and filter to the plugin's path. The entry or `plugin.json` may override the default layout (e.g. `skills`, `mcpServers`).
3. **Describe** each relevant skill or agent from its frontmatter `description`.
4. **Read** the files when descriptions can't answer the question: shallow-clone the repo (`git clone --depth 1`) into the scratch directory.

Searching inside every plugin is fine for in-repo plugins (one tree call per marketplace); look into externally hosted ones only when asked, one at a time.
