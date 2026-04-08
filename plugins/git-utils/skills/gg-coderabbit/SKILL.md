---
name: gg-coderabbit
description: Evaluate CodeRabbit comment and recommend whether to action it
argument-hint: [GitHub PR comment link of CodeRabbit]
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(gh api graphql *)
  - Bash(gh api repos/*/pulls/*/comments *)
  - Bash(gh api repos/*/pulls/comments/*)
  - Bash(rm x_coderabbit_*.md)
  - Glob
  - Grep
  - Read
---

## 1. Fetch

Parse the PR review comment link from `$ARGUMENTS` to extract owner, repo, PR number, and comment ID. **If no link provided, STOP and ask for a CodeRabbit PR review comment link — give example `https://github.com/username/reponame/pull/3#discussion_r3055555555`.**

Then run:

```bash
# strips analysis chain, includes diff context
gh api repos/OWNER/REPO/pulls/comments/COMMENT_ID \
  --jq '"## Diff context\n\n```diff\n" + .diff_hunk + "\n```\n\n## Comment\n\n" + (.body | gsub("<details>\\s*<summary>🧩 Analysis chain</summary>[\\s\\S]*?</details>\\s*"; ""))' \
  > x_coderabbit_COMMENT_ID.md
```

**Important:** Write `x_coderabbit_COMMENT_ID.md` to the project root.

## 2. Evaluate

CodeRabbit AI is not always right.

Evaluate the comment `x_coderabbit_COMMENT_ID.md` against the context of our codebase and files it references. Assess:

| Criterion | Question |
|-----------|----------|
| **Contextually valid** | Does it make sense with full codebase context? |
| **Valuable** | Worth doing? Good practice? Or is it over-engineering? |
| **Elegant** | Is the suggested fix pragmatic and clean? |

## 3. Recommend & Confirm

Follow this output structure:

<structure>
🐰 CodeRabbit Review: [Terse title for comment]

📋 Summary: [Explain the comment, 2-4 simple sentences]

🏷️ Verdict: [Action | Skip | Clarify]
- **Action** - Valid and valuable; implement (or with modifications)
- **Skip** - Not applicable, over-engineered, or incorrect
- **Clarify** - Need more information before deciding

💬 Reasoning: [Why this verdict, 2-3 simple sentences]
</structure>

**Output Format:** Well structured, use emojis, if using tables keep width <100 chars for readability.

Ask for confirmation before proceeding with the verdict.

## 4. Reply To CodeRabbit and Resolve

After actioning or skipping, offer to reply to CodeRabbit **and** resolve the thread. Reply first, then resolve. Never do either without user confirmation.

<reply>
Keep replies concise. State reason for action or skip.

```bash
gh api repos/OWNER/REPO/pulls/PULL_NUMBER/comments \
  -f body="@coderabbitai ..." \
  -F in_reply_to=COMMENT_ID
```
</reply>

<resolve>
Resolve thread:

```bash
gh api graphql -f query='{
  repository(owner: "OWNER", name: "REPO") {
    pullRequest(number: PULL_NUMBER) {
      reviewThreads(first: 50) {
        nodes {
          id
          comments(first: 1) { nodes { databaseId } }
        }
      }
    }
  }
}' --jq '.data.repository.pullRequest.reviewThreads.nodes[]
  | select(.comments.nodes[0].databaseId == COMMENT_ID) | .id' \
| xargs -I{} gh api graphql -f query='mutation {
  resolveReviewThread(input: { threadId: "{}" }) {
    thread { isResolved }
  }
}' --jq '.data.resolveReviewThread.thread.isResolved'
```
</resolve>

## 5. Wrap-up

Clean up: `rm x_coderabbit_COMMENT_ID.md`

State final summary, in 4-10 words and emoji.
