---
name: gg-pr
description: "Draft a PR into main, open it once approved."
argument-hint: "[additional instructions]"
user-invocable: true
disable-model-invocation: true
disallowed-tools: AskUserQuestion
allowed-tools:
  - Bash(gh pr status *)
  - Bash(gh pr view *)
  - Bash(git add pr-draft.md)
  - Bash(git fetch *)
  - Bash(git ls-remote *)
  - Bash(git rm -f pr-draft.md)
  - Edit(pr-draft.md)
---

# Draft the PR for this branch

Additional instructions for this PR: $ARGUMENTS

Run this exact check:

```bash
gh pr view --json number,url,state,headRefName
```

If a PR is **open** already, **stop** and tell me 🤔 in a few words. Ask what I want to do.

## PR Source

Read the branch's commits for the motive behind each change and the diff for the detail:

- `git log main..HEAD` — the commits on this branch
- `git diff main...HEAD` — what the branch introduces, from the merge base, so changes made to main since branching are excluded

State only what the code, the commits, or I have told you. Do not infer intent. Before drafting, **ask me** about any motive that isn't clear, or anything else you need, rather than guess.

## PR Guidelines

Goal: a reader should learn from the description alone what changed and why, what behaviour changed, and the benefit(s) of the PR (if any). This PR will be merged with a merge commit, so the commits keep the low-level detail. The description gives the big picture: enough for a solid understanding without reading the commits, leaving out what the diff already shows.

Title: imperative, stand-alone, under 55 characters (72 max).

Body:

- Summary: lead with what this PR does, then why and its benefit, stated concretely, in no more than 100 words. It must make sense on its own.
- Behaviour changes: say plainly if there are none.
- Changes: grouped by theme when there are several, most important first. Describe each theme as a whole and give the reason where it isn't obvious. Use prose, bullets, or a combination, whichever reads best for the group.
- Decisions: anything non-obvious chosen, rejected, or deferred, and why. Omit if there is nothing to say.
- After merging: only if the reader must act; otherwise omit.

Summary, Changes, and Behaviour changes are always present.

Tone: plain, tight, coherent and professional. No filler, no marketing.

## Write and review

1. Write the draft to `pr-draft.md` in the project root and `git add pr-draft.md`.
2. Reread it top to bottom. Is it coherent? Does it include insignificant detail? Does each part use prose, bullets, or a combination effectively? Edit the file where that improves it. Do not stage these changes.
3. Ask me 😎 whether to refine it, or to push the branch and open the PR.

Once opened successfully, offer to `git rm -f pr-draft.md` 🗑.
