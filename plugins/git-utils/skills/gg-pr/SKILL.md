---
name: gg-pr
description: "Draft a PR into main, open it once approved."
argument-hint: "[additional guidance]"
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(gh pr status)
  - Bash(gh pr view *)
  - Bash(git fetch *)
  - Bash(git ls-remote *)
  - Bash(rm pr-draft.md)
  - Edit(pr-draft.md)
---

# Draft the PR for this branch

Task: Draft a PR for this branch into main. Write to `pr-draft.md` in project root so I can review it, then ask whether to create the PR as is or refine it. Once I approve, push the branch if needed and open the PR with gh. Once the PR is open, ask whether to delete `pr-draft.md`.

Goal: a reviewer should learn from the description alone what changed and why, what behaviour changed, and anything they must do after merging. Leave out detail they can read in the diff.

How to gather material: the commit messages hold the motive for each change and the diff against main holds the detail. Read both. Before drafting, ask me about any change whose motive isn't clear rather than guess.

Shape:

- Title: under 70 characters, names the dominant theme, follows the repository's title convention if it has one.
- Summary: 2 to 4 sentences on what this PR does and why.
- Changes: short bullets, grouped by theme when there are several. One line each.
- Behaviour changes: say plainly if there are none.
- After merging: only if a reviewer must act; otherwise leave it out.

Tone: plain and specific, no filler, no marketing.

Additional guidance for this PR: $ARGUMENTS
