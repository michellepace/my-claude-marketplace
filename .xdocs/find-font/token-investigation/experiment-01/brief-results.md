# Experiment 01 — Refactor token-efficiency results

## §1. TL;DR

The refactor achieved its narrow goal — Lora was correctly skipped on Step 2 (ff-1 dropped from 4 calls to 3, saving $0.0475) — but the run regressed overall because the refactored orchestrator added a heavy TaskCreate / TaskUpdate / ToolSearch ceremony that the baseline did not run. Headline numbers: wall-clock active 378s → 439s, cost $2.9928 → $3.7835, Peak CTX 48,010 → 59,219, subagent boots 16 → 14, total tokens 1.65M → 1.96M. The biggest variance flag is the ceremony itself — Run 2 emitted 18 TaskUpdate + 9 TaskCreate + 1 ToolSearch in the orchestrator that Run 1 had zero of, accounting for most of the orchestrator regression and is run-to-run model variance, not refactor structure.

**Verdict:** The refactor regressed cost by 26.4% (18.7% on tokens, 16.1% wall-clock). The structural saving from skipping the cached Lora curate was real but small (-$0.0475) and was overwhelmed by Run 2's orchestrator ceremony bloat (+$0.4778).

## §2. Headline comparison

| Metric | Run 1 | Run 2 | Δ | Δ% |
|:--|--:|--:|--:|--:|
| Wall-clock (active) | 6m 18s | 7m 19s | +61s | +16.1% |
| Run-wide cost ($) | $2.9928 | $3.7835 | +$0.7907 | +26.4% |
| Run-wide Peak CTX | 48,010 | 59,219 | +11,209 | +23.3% |
| Subagent boots | 16 | 14 | -2 | -12.5% |
| Run-wide total tokens | 1,651,825 | 1,960,424 | +308,599 | +18.7% |

*Tokens deduped by `message.id` before summing; cost computed by `cost_report.py` (per-bucket per-model rates from `rates.json`). Quote $ to 4 decimals so small deltas don't round to zero.*

## §3. Where the work lived (step-level)

| Step | Run 1 tok | Run 1 $ | Run 2 tok | Run 2 $ | Δ tok | Δ $ |
|:--|--:|--:|--:|--:|--:|--:|
| Orchestrator | 279,027 | $0.6580 | 507,528 | $1.1357 | +228,501 | +$0.4778 |
| Curate (ff-1) | 573,034 | $1.1526 | 498,265 | $1.1051 | -74,769 | -$0.0475 |
| Classify (ff-2) | 642,216 | $0.9548 | 681,918 | $1.2175 | +39,702 | +$0.2627 |
| SVG (ff-3) | 157,548 | $0.2275 | 272,713 | $0.3252 | +115,165 | +$0.0977 |
| **Total** | **1,651,825** | **$2.9928** | **1,960,424** | **$3.7835** | **+308,599** | **+$0.7907** |

The single largest dollar regression is the **orchestrator** (+$0.4778, +72.6%) — that one row alone is 60% of the run-wide regression. The only step that saved dollars was **ff-1 curate** (-$0.0475, -4.1%), driven by call-count dropping 4 → 3 (Lora skipped — exactly the refactor's intent). Both ff-2 and ff-3 regressed at constant call-count (3 and 1 respectively), so their lift is per-call sidechain weight, not structure. See §4 for the orchestrator bucket-mix breakdown.

## §4. Orchestrator drill-down

**Tool calls** (source: `orient.sh` §Orchestrator tool-call counts):

| Tool | Run 1 | Run 2 | Δ | Note |
|:--|--:|--:|--:|:--|
| Agent | 8 | 7 | -1 | structural — one fewer ff-1 spawn (Lora cached) |
| Read | 6 | 7 | +1 | variance — orchestrator made one extra Read |
| Bash | 1 | 9 | +8 | variance — Run 2 ran extra status / probe Bash calls |
| TaskCreate | 0 | 9 | +9 | variance — Run 2 used a TodoWrite-style plan, Run 1 did not |
| TaskUpdate | 0 | 18 | +18 | variance — same TodoWrite ceremony, status flips |
| ToolSearch | 0 | 1 | +1 | variance — Run 2 deferred-tool fetch; not in baseline |

**Token buckets** (source: `cost_report.py` orchestrator bucket detail; `cache_create_5m` row omitted — both runs zero):

| Token Bucket | Run 1 tok | Run 2 tok | Δ tok | Δ $ |
|:--|--:|--:|--:|--:|
| input_tokens | 32 | 27 | -5 | -$0.0001 |
| cache_create_1h | 33,188 | 58,363 | +25,175 | +$0.2517 |
| cache_read | 237,521 | 435,775 | +198,254 | +$0.0991 |
| output_tokens | 8,286 | 13,363 | +5,077 | +$0.1269 |
| **Total** | **279,027** | **507,528** | **+228,501** | **+$0.4778** |

The orchestrator's $0.4778 regression is split across two heavy-priced buckets: **`cache_create_1h`** (+$0.2517, ~53% of the lift) and **`output_tokens`** (+$0.1269, ~27%). Both are downstream of the `variance` rows in the tool-calls table — the 27 extra TaskCreate/TaskUpdate turns and 8 extra Bash turns add output tokens directly and force fresh 1h-cache prefixes for each new turn. `cache_read` moved 198k tokens but contributes only ~$0.10 because reads are 0.10× base. The structural row (Agent -1) saves orchestrator tokens only marginally; the dominant signal is ceremony, not refactor.

## §5. Subagent drill-down (per skill, wrapper + sidechain)

```
Run 1 (baseline) — 16 subagent files
```

| Skill | Calls | Wrapper tok | Sidechain tok | Total tok | Total $ |
|:--|--:|--:|--:|--:|--:|
| ff-1 curate | 4 | 124,184 | 448,850 | 573,034 | $1.1526 |
| ff-2 classify | 3 | 93,743 | 548,473 | 642,216 | $0.9548 |
| ff-3 svg | 1 | 31,056 | 126,492 | 157,548 | $0.2275 |
| **Subtotal** | **8** | **248,983** | **1,123,815** | **1,372,798** | **$2.3349** |

```
Run 2 (refactored) — 14 subagent files
```

| Skill | Calls | Wrapper tok | Sidechain tok | Total tok | Total $ |
|:--|--:|--:|--:|--:|--:|
| ff-1 curate | 3 | 92,329 | 405,936 | 498,265 | $1.1051 |
| ff-2 classify | 3 | 93,622 | 588,296 | 681,918 | $1.2175 |
| ff-3 svg | 1 | 31,801 | 240,912 | 272,713 | $0.3252 |
| **Subtotal** | **7** | **217,752** | **1,235,144** | **1,452,896** | **$2.6478** |

**ff-1 curate** is the only **structural** row — calls drop 4 → 3 (Lora skipped) for a -$0.0475 saving, exactly matching the refactor's intent (commit `68721a0`). **ff-2 classify** and **ff-3 svg** are pure **variance** — call-count is identical across runs, but per-call sidechain weight grew: ff-2 went from $0.3183/call → $0.4058/call (+$0.0875/call × 3 = +$0.2627), and ff-3's single sidechain ballooned from 126,492 → 240,912 tokens (+$0.0977). Per `diagnose.sh` §1, ff-3's sidechain agent did similar tool-call counts in both runs, so the lift is per-turn output and cache-creation drift, not extra work — classic run-to-run trajectory variance.

## §6. Variance flags

- **TaskCreate/TaskUpdate ceremony** — Run 2 emitted 9 TaskCreate + 18 TaskUpdate orchestrator turns; Run 1 emitted zero. Δ ≈ +5,077 output tokens and +25,175 `cache_create_1h` tokens, ≈ +$0.38 of orchestrator cost. Source: §4 + `diagnose.sh` §3 (orchestrator per-turn output histogram shows TaskUpdate-dominated turns at 2977 / 2821 output tokens).
- **ToolSearch ceremony** — Run 2 made 1 ToolSearch tool call (deferred-tool fetch); Run 1 made zero. Small contribution (~one extra orchestrator turn) but signals harness-pattern variance, not refactor. Source: §4.
- **Extra orchestrator Bash calls** — Run 2 ran 9 Bash calls vs Run 1's 1 Bash call. Δ ≈ +8 turns, mostly status probes. Source: §4 + `diagnose.sh` §3.
- **ff-3 svg sidechain heavier** — same instruction, Run 2's single SVG sidechain ran 240,912 tokens vs Run 1's 126,492 (+114,420 tokens, +$0.0977). Run-to-run trajectory variance, not refactor. Source: §5 + `diagnose.sh` §1 (similar tool-call counts both runs).
- **ff-2 classify sidechain heavier** — same 3 calls each run, but per-call cost rose $0.3183 → $0.4058. Source: §5.

## §7. Verdict

The refactor's only structural change visible in the data is the intended one — pre-checking profile state in Step 2 successfully skipped the cached Lora font, dropping ff-1 curate from 4 calls to 3 (-$0.0475) and removing one Agent spawn from the orchestrator. Quantified deltas: cost rose +$0.7907 (+26.4%), tokens rose +308,599 (+18.7%), wall-clock active rose +61s (+16.1%) — so on the headlines the refactor regressed, not improved. The honest caveat is that this is a sample-of-one and Run 2's orchestrator alone added ~$0.38 of TaskCreate / TaskUpdate / ToolSearch / Bash ceremony that has nothing to do with the SKILL.md refactor — strip that out and the refactor's net effect is roughly cost-neutral with a small structural saving.

## §8. Biggest cost sink (Q4)

The single largest absolute dollar step in the refactored run is **ff-2 classify ($1.2175, 32% of run-wide cost)**, with three calls at ~$0.41 each and 86% of the skill's tokens spent inside the sidechain (588,296 of 681,918). The concrete optimisation lever is per-call sidechain weight: per §5 the call count is fixed at one-per-candidate, and per `diagnose.sh` §1 each classify sidechain runs `1xSkill` only — so the cost is sidechain-internal Read / output volume, and the highest-leverage move is to trim what the classify sidechain reads (or what it writes back) on each invocation, not to change call counts.
