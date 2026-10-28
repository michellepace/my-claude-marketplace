---
skill: plugins/alwayson-misc/skills/grill-me/SKILL.md
result: pass
---

# Manual Evals: `grill-me`

Test each in a new session.

## grill-me

*Tested 2026-08-17 · commit `178dabf` · Opus 5 xHigh*

> /grill-me "should I move my blog from WordPress to Next.js?"

Expected (confirm this):
- [x] Autocomplete offers `/grill-me`
- [x] `/gg-grilling` still shows, from installed git-utils 1.1.2 — gone after merge + `marketplace update`
- [x] Asks one question at a time, each with a recommended answer
- [x] Does not start any work; waits for confirmed shared understanding
- [x] Does not use the UserQ&A form (added `e7dfdb9`)
