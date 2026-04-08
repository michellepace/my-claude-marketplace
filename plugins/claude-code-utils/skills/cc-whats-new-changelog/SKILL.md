---
name: cc-whats-new-changelog
description: Explain what's new in Claude Code
argument-hint: [Optional version "2.1.90", "v2.1.90"]
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Agent(claude-code-guide)
  - Bash(awk *)
  - Bash(${CLAUDE_SKILL_DIR}/scripts/fetch-changelog.sh *)
  - Bash(claude --version)
  - Bash(echo *)
  - Bash(rm x_cc-changelog-*)
  - Edit
  - Read
---

**version_provided**: $ARGUMENTS

**user_version**: !`claude --version`

## Step 1: Show Latest Version Summary

Run the fetch script to gather changelog and npm data, then display summary:

Run: `${CLAUDE_SKILL_DIR}/scripts/fetch-changelog.sh --latest-n 8`

Analyse data in `<latest_version_summary>` tags to populate template (use backticks and emoji "🙂"):

<welcome_message_template>

# KNOW WHAT CHANGED IN CLAUDE CODE

Claude Code has `[total_versions]` versions between `v[latest]` → `v[earliest]` ([earliest_date]).

📋 Latest `[N]` Versions (items are changelog entries):

| Version | Released | Items | Changes At A Glance |
| ------- | -------- | ----- | ------------------- |
| `x.x.x` | YYYY-MM-DD | nn | Most impactful change (50-70 chars) |
| `x.x.x` | YYYY-MM-DD | 0 | *(no changelog entry, an npm-only release)* |
| ... | ... | ... | ... |

</welcome_message_template>

## Step 2: Determine Provided Version

Check if `$ARGUMENTS` contains a version in `x_cc-changelog-index.csv`.

**Valid version with changelog_items > 0?** → Proceed to Step 3

**Valid version with changelog_items = 0?** → "🤔 Version `X.X.X` has no changelog entries, so I won't be able to explain what changed. It's likely because [...]. What about `[nearest versions with items]`?"

**Invalid or missing version?** → "🤔 Which version would you like me to explain? For example: latest `[version]`, a timeframe ("[eg1]", "[eg2]", "[eg3]"), or an earlier version?"

## Step 3: Acknowledge & Proceed

| Input Type | Example | Response |
| ---------- | ------- | -------- |
| Minor series | `2.1` | "🙂 Analysing all `2.1.*` versions..." |
| Exact version | `2.1.2` | "🙂 Analysing version `2.1.2`..." |

Then proceed to Step 4.

## Step 4: Extract Changelog

Extract the changelog section for the determined version:

```bash
VERSION="[VERSION]"  # e.g., "2.1.90" or "2.1"
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
