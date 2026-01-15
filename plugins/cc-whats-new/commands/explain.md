---
description: What's new in Claude Code (eg 2.1.3 or 2.1 for all 2.1.*)
argument-hint: [version]
allowed-tools: Task, Read, Edit, Bash(claude:*), Bash(curl:*), Bash(awk:*), Bash(echo:*), Bash(npm view:*), Bash(grep:*), Bash(head:*), Bash(tail:*), Bash(tac:*), Bash(sed:*), Bash(tr:*), Bash(cat:*), Bash(paste:*), Bash(column:*)
---

**version_provided**: $ARGUMENTS

**user_version**: !`claude --version`

## Step 1: Show Latest Version Summary

Run these commands to gather changelog and npm data, then display summary:

```bash
# Write changelog to temp file (v2.0.0+ only)
CHANGELOG_FILE="/tmp/cc-whats-new-changelog.md"
curl -s https://raw.githubusercontent.com/anthropics/claude-code/refs/heads/main/CHANGELOG.md | awk '/^## [01]\./{exit} {print}' > "$CHANGELOG_FILE"
CHANGELOG=$(cat "$CHANGELOG_FILE")
echo "✅ Changelog file created (v2.0.0+): $CHANGELOG_FILE"

# Write versions CSV with changelog item counts (v2.0.0+ only)
VERSIONS_FILE="/tmp/cc-whats-new-versions.csv"
CHANGELOG_COUNTS=$(echo "$CHANGELOG" | awk '/^## /{if(v)print v","c;v=$2;c=0}/^- /{c++}END{print v","c}')
echo "version,npm_release_date,changelog_items (0=npm-only)" > "$VERSIONS_FILE"
npm view @anthropic-ai/claude-code time | grep -E "^ +'[2-9]\." | tac | sed "s/T.*Z'//" | tr -d "':," | column -t | while read -r ver date; do
  items=$(echo "$CHANGELOG_COUNTS" | grep "^$ver," | cut -d',' -f2)
  echo "$ver,$date,${items:-0}"
done >> "$VERSIONS_FILE"
echo "✅ Versions file created (v2.0.0+): $VERSIONS_FILE"

# Latest versions (0 changelog items = npm-only)
echo "";
echo "<latest_version_summary>";
echo "";
echo "=== Version Stats ===";
echo "<version_stats>";
echo "total_versions=$(( $(wc -l < "$VERSIONS_FILE") - 1 ))";
echo "latest=$(sed -n '2p' "$VERSIONS_FILE" | cut -d',' -f1)";
echo "earliest=$(tail -1 "$VERSIONS_FILE" | cut -d',' -f1)";
echo "</version_stats>";
echo "";
echo "=== Latest Versions ===";
echo "<latest_versions>";
head -8 "$VERSIONS_FILE"
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

*[Short note why version may have zero items (if applicable)]*

</welcome_message_template>

## Step 2: Determine Provided Version

Check if `$ARGUMENTS` contains a version in `/tmp/cc-whats-new-versions.csv`.

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
CHANGELOG_FILE="/tmp/cc-whats-new-changelog.md"
VERSION_CHANGELOG_FILE="/tmp/cc-whats-new-version-changelog.md"

if [[ "$VERSION" =~ ^[0-9]+\.[0-9]+$ ]]; then
  # Series (e.g., 2.1) - get all matching versions
  SECTION=$(awk -v ser="$VERSION." '/^## [0-9]/ && index($2, ser) == 1 { p=1 } /^## [0-9]/ && p && index($2, ser) == 0 { exit } p' "$CHANGELOG_FILE")
else
  # Exact version (e.g., 2.1.3)
  SECTION=$(awk -v ver="$VERSION" '/^## [0-9]/ { if ($2 == ver) { p=1 } else if (p) { exit } } p' "$CHANGELOG_FILE")
fi

echo "$SECTION" > "$VERSION_CHANGELOG_FILE"
echo "✅ Version changelog created: $VERSION_CHANGELOG_FILE"
```

If the user's request implies a time filter (e.g., "this week"), edit the file to include only versions matching that timeframe using dates from `/tmp/cc-whats-new-versions.csv`.

Proceed to Step 5 where this changelog will be provided to the agent.

## Step 5: Explain Changes Practically

Use the Task tool to spawn `claude-code-guide` agent in **foreground mode** (`run_in_background: false`) with the following prompt:

<agent_prompt>

**GOAL:** Help users leverage new Claude Code features in version `[VERSION]` — what they mean, why they matter, and how to use them.

Steps:

1. Read and analyse changelog: `/tmp/cc-whats-new-version-changelog.md`

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
