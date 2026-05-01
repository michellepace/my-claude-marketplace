# Experiment 01: Summary

## Setup

| Run | Variant | SKILL.md @ commit | Session path |
|:--|:--|:--|:--|
| 1 | baseline | `b3fffd5` | `~/.claude/projects/-home-mp-projects-shopify-sparklepop/d12c0278-ee40-4622-9c7e-4d86750c006d` |
| 2 | refactored | `68721a0` | `~/.claude/projects/-home-mp-projects-shopify-sparklepop/71791195-a881-4708-b16b-34ed5cc39f0b` |

**Prompt (identical for both runs):**

```text
/find-font:ff-0-pair-my-font Body font Lora. Pairing candidates are Bodoni Moda, Montserrat, and spectral.jpg. No other pairing candidates needed. I'm aiming for quiet editorial luxury with high readability. Include SVG matrix.
```

**Cache state at run-time** (what the refactor's pre-check could see):

| Font | Profile | Matrix done? | Pre-check state | Refactor's effect |
|:--|:--|:--|:--|:--|
| Lora | ✅ | ✅ | `fully-cached` | skip ff-1 **and** ff-2 |
| Bodoni Moda | ❌ | n/a | `needs-curate` | no change vs baseline |
| Montserrat | ❌ | n/a | `needs-curate` | no change vs baseline |
| Spectral | ❌ | n/a | `needs-curate` | no change vs baseline |

## Headline Results

Run 2 introduced unexpected ceremony — 9 TaskCreate + 18 TaskUpdate + 1 ToolSearch + 8 extra Bash calls in the orchestrator — that the baseline did not run and the SKILL.md did not prescribe.

| Metric | Run 1 | Run 2 | Δ | Δ% |
|:--|--:|--:|--:|--:|
| Wall-clock (active) | 6m 18s | 7m 19s | +61s | +16.1% |
| Run-wide cost ($) | $2.9928 | $3.7835 | +$0.7907 | +26.4% |
| Run-wide Peak CTX | 48,010 | 59,219 | +11,209 | +23.3% |
| Subagent boots | 16 | 14 | -2 | -12.5% |
| Run-wide total tokens | 1,651,825 | 1,960,424 | +308,599 | +18.7% |

## Conclusion

**Experiment under-exercised the refactor.** Only 1 of 4 candidates (Lora) was cached, so the pre-check could skip just one ff-1 spawn (~$0.05 saving) — well below run-to-run noise (~$0.38 of ceremony variance in Run 2). The `needs-classify`-only and `unknown` branches were never exercised. Verdict on the refactor itself is inconclusive from this run alone.
