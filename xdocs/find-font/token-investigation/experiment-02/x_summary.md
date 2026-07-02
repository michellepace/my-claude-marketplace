# Experiment 02: Summary

## Setup

| Run | Variant | SKILL.md @ commit | Session path |
|:--|:--|:--|:--|
| 1 | baseline | `b3fffd5` | `~/.claude/projects/-home-mp-projects-shopify-sparklepop/546340aa-2220-4d63-92f4-14708950d9c2` |
| 2 | refactored | `68721a0` | `~/.claude/projects/-home-mp-projects-shopify-sparklepop/5323d196-3d8e-4cee-9a31-844b1b326422` |

**Prompt (identical for both runs):**

```text
/find-font:ff-0-pair-my-font Body font Newsreader. Pairing candidates are Bodoni Moda, Spectral, faustina. No other pairing candidates needed. I'm aiming for clean luxary with high readability. Include SVG matrix.
```

**Cache state at run-time** (what the refactor's pre-check could see):

| Font | Profile | Matrix done? | Pre-check state | Refactor's effect |
|:--|:--|:--|:--|:--|
| Newsreader | ✅ | ✅ | `fully-cached` | skip ff-1 **and** ff-2 |
| Bodoni Moda | ✅ | ✅ | `fully-cached` | skip ff-1 **and** ff-2 |
| Spectral | ✅ | ✅ | `fully-cached` | skip ff-1 **and** ff-2 |
| Faustina | ✅ | ✅ | `fully-cached` | skip ff-1 **and** ff-2 |

## Headline Results

All 4 candidates resolved as `fully-cached`, so the refactor skipped 4× ff-1 curate + 4× ff-2 classify — only the ff-3 SVG agent fired in Run 2 (1 Agent call vs 9 in Run 1).

| Metric | Run 1 | Run 2 | Δ | Δ% |
|:--|--:|--:|--:|--:|
| Wall-clock (active) | 6m 44s | 3m 37s | −3m 7s | −46.3% |
| Run-wide cost ($) | $3.6529 | $1.0168 | −$2.6361 | −72.2% |
| Run-wide Peak CTX | 56,276 | 45,788 | −10,488 | −18.6% |
| Subagent boots | 19 | 2 | −17 | −89.5% |
| Run-wide total tokens | 1,982,903 | 675,615 | −1,307,288 | −65.9% |

*Run 1 totals corrected: cost_report.py left one ff-3 wrapper unclassified ($0.0820 / 49,158 tok); folded back via orient.sh per-subagent rollup. See `brief-results.md` §2 footnote.*

## Conclusion

**Experiment cleanly exercises the refactor's `fully-cached` short-circuit.** All four candidates were on disk, so 8 of 9 Agent spawns collapsed — the structural saving is unambiguous: $2.64 / 72% cheaper, 1.31M / 66% fewer tokens, 187s / 46% faster. This is the upper bound of the refactor's value; on prompts where any candidate is `needs-curate` or `needs-classify`, the saving will scale down proportionally to how many spawns survive.
