---
name: cc-whats-new-changelog
description: What's new in Claude Code (eg 2.1.3 or 2.1 for all 2.1.*)
argument-hint: [version]
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Agent(claude-code-guide)
  - Bash(awk *)
  - Bash(cat *)
  - Bash(claude --version)
  - Bash(column *)
  - Bash(curl *)
  - Bash(cut *)
  - Bash(echo *)
  - Bash(grep *)
  - Bash(head *)
  - Bash(npm view *)
  - Bash(rm x_cc-changelog-*)
  - Bash(sed *)
  - Bash(tac *)
  - Bash(tail *)
  - Bash(tr *)
  - Bash(wc *)
  - Edit
  - Read
---

**version_provided**: $ARGUMENTS

**user_version**: !`claude --version`

## Step 1: Show Latest Version Summary

Run these commands to gather changelog and npm data, then display summary:

```bash
# Fetch full changelog (v2.1.0+, 2026+)
CHANGELOG_FULL="x_cc-changelog-full.md"
curl -s https://raw.githubusercontent.com/anthropics/claude-code/refs/heads/main/CHANGELOG.md | awk '/^## 2\.0\./{exit} /^## [01]\./{exit} {print}' > "$CHANGELOG_FULL"
CHANGELOG=$(cat "$CHANGELOG_FULL")
echo "✅ Full changelog created (v2.1.0+, 2026+): $CHANGELOG_FULL"

# Build changelog index with item counts (v2.1.0+, 2026+)
CHANGELOG_INDEX="x_cc-changelog-index.csv"
CHANGELOG_COUNTS=$(echo "$CHANGELOG" | awk '/^## /{if(v)print v","c;v=$2;c=0}/^- /{c++}END{print v","c}')
echo "version,npm_release_date,changelog_items (0=npm-only)" > "$CHANGELOG_INDEX"
npm view @anthropic-ai/claude-code time | grep -E "^ *'[0-9]+\.[0-9]+\.[0-9]+" | grep -vE "'([01]\.|2\.0\.)" | tac | sed "s/T.*Z'//" | tr -d "':," | column -t | while read -r ver date; do
  items=$(echo "$CHANGELOG_COUNTS" | grep "^$ver," | cut -d',' -f2)
  echo "$ver,$date,${items:-0}"
done >> "$CHANGELOG_INDEX"
echo "✅ Changelog index created (v2.1.0+, 2026+): $CHANGELOG_INDEX"

# Latest versions (0 changelog items = npm-only)
echo "";
echo "<latest_version_summary>";
echo "";
echo "=== Version Stats ===";
echo "<version_stats>";
echo "total_versions=$(( $(wc -l < "$CHANGELOG_INDEX") - 1 ))";
echo "latest=$(sed -n '2p' "$CHANGELOG_INDEX" | cut -d',' -f1)";
echo "earliest=$(tail -1 "$CHANGELOG_INDEX" | cut -d',' -f1)";
echo "</version_stats>";
echo "";
echo "=== Latest Versions ===";
echo "<latest_versions>";
head -8 "$CHANGELOG_INDEX"
echo "</latest_versions>";

# Latest changelog entries
echo "";
echo "=== Latest Changelog Entries ===";
echo "<latest_changelog_entries>";
echo "$CHANGELOG" | awk '/^## [0-9]/{count++} count<=7';
echo "</latest_changelog_entries>";
echo "";
echo "</latest_version_summary>";
```

Analyse data in `<latest_version_summary>` tags to populate template (use backticks and emoji "🙂"):

<welcome_message_template>

# KNOW WHAT CHANGED IN CLAUDE CODE

Claude Code has `[total_versions]` versions within (`[latest]` → `[earliest]`). Most have a **changelog entry** — one or more **items** describing what changed.

🙂 Latest `[N]` Versions:

| Version | Released | Items | Changes At A Glance |
| ------- | -------- | ----- | ------------------- |
| `x.x.x` | YYYY-MM-DD | nn | Most impactful change (40-50 chars) |
| `x.x.x` | YYYY-MM-DD | 0 | (no changelog entry) |
| ... | ... | ... | ... |

*Versions with 0 items are npm-only releases (typically hotfixes)*

</welcome_message_template>

## Step 2: Determine Provided Version

Check if `$ARGUMENTS` contains a version in `x_cc-changelog-index.csv`.

**Valid version with changelog_items > 0?** → Proceed to Step 3

**Valid version with changelog_items = 0?** → "🤔 Version `X.X.X` has no changelog entries, so I won't be able to explain what changed. It's likely because [...]. What about `[nearest versions with items]`?"

**Invalid or missing version?** → "🤔 Which version? Did you perhaps mean `[suggest version]` or ...?"

## Step 3: Acknowledge & Proceed

| Input Type | Example | Response |
| ---------- | ------- | -------- |
| Minor series | `2.1` | "🙂 Analysing all `2.1.*` versions..." |
| Exact version | `2.1.2` | "🙂 Analysing version `2.1.2`... (tip: use `2.1` for all 2.1.* versions)" |

Then proceed to Step 4.

## Step 4: Extract Changelog

Extract the changelog section for the determined version:

```bash
VERSION="[VERSION]"  # e.g., "2.1.3" or "2.1"
CHANGELOG_FULL="x_cc-changelog-full.md"
CHANGELOG_SELECTED="x_cc-changelog-selected.md"

if [[ "$VERSION" =~ ^[0-9]+\.[0-9]+$ ]]; then
  # Series (e.g., 2.1) - get all matching versions
  SECTION=$(awk -v ser="$VERSION." '/^## [0-9]/ && index($2, ser) == 1 { p=1 } /^## [0-9]/ && p && index($2, ser) == 0 { exit } p' "$CHANGELOG_FULL")
else
  # Exact version (e.g., 2.1.3)
  SECTION=$(awk -v ver="$VERSION" '/^## [0-9]/ { if ($2 == ver) { p=1 } else if (p) { exit } } p' "$CHANGELOG_FULL")
fi

echo "$SECTION" > "$CHANGELOG_SELECTED"
echo "✅ Selected changelog created: $CHANGELOG_SELECTED"
```

If the user's request implies a time filter (e.g., "this week"), edit the file to include only versions matching that timeframe using dates from `x_cc-changelog-index.csv`.

Proceed to Step 5 where this changelog will be provided to the agent.

## Step 5: Explain Changes Practically

Use the Agent tool to spawn the `claude-code-guide` agent (`subagent_type: "claude-code-guide"`) in **foreground mode** (`run_in_background: false`) with the following prompt:

<agent_prompt>

**GOAL:** Help users leverage new Claude Code features in version `[VERSION]` — what they mean, why they matter, and how to use them.

Steps:

1. Read and analyse changelog: `x_cc-changelog-selected.md`

2. Evaluate which changes most impact Claude Code users.

3. Create a **Summary table:** "Feature | Benefit". Rank by impact (most impactful first). Width <100 chars.

4. List **Fixes:** separately e.g.,

    ```
    **Fixes:**
    - [Problem ➜ Resolution]
    - [eg Plan files after /clear ➜ Fresh plan file now used]
    - [eg Web search model in sub-agents ➜ Uses correct model]
    ```

5. For each significant feature in the table, use WebFetch to consult official Claude Code documentation for the relevant topic.

6. Explain **significant features** using the template below. Enhance explanations and examples with useful information from the documentation where relevant, and include citations.

   <explain_features_template>

   ---

   ## ⭐ **[Feature Name]**

   [Explain what the feature means and WHY it matters (2 sentences max)]

   EXAMPLE: [Practical example helping user see relevance and realise value from this feature.]

   Docs: [Links to official docs if used to enhance content]

   ---

   </explain_features_template>

7. Verify you have honestly completed steps 1-6

</agent_prompt>

Present the agent's output directly to the user.

## Step 6: Cleanup

Ask the user if they would like the written files removed. If yes:

```bash
rm x_cc-changelog-*
```
