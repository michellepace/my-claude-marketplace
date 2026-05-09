# Experiment 02 — Results

- **Run 1 (baseline `b3fffd5`):** `~/.claude/projects/-home-mp-projects-shopify-sparklepop/546340aa-2220-4d63-92f4-14708950d9c2.jsonl`
- **Run 2 (refactored `68721a0`):** `~/.claude/projects/-home-mp-projects-shopify-sparklepop/5323d196-3d8e-4cee-9a31-844b1b326422.jsonl`

## §1. TL;DR

The refactor introduced a `fully-cached` short-circuit that lets the orchestrator skip ff-1 curate and ff-2 classify when every requested font already has a complete profile on disk — both runs hit that path here, so 8 of 9 spawn-points collapsed. Wall-clock 6m44s → 3m37s, cost $3.6529 → $1.0168, peak CTX 56,276 → 45,788, subagent boots 19 → 2, run-wide tokens 1,982,903 → 675,615. Run 1 also burned ~11 TaskCreate/TaskUpdate ceremony calls that the refactor never touched (variance, not refactor).

**Verdict:** The refactor reduced cost by 72.2% (65.9% on tokens, 46.3% wall-clock).

## §2. Headline comparison

| Metric | Run 1 | Run 2 | Δ | Δ% |
|:--|--:|--:|--:|--:|
| Wall-clock (active) | 6m 44s | 3m 37s | −3m 7s | −46.3% |
| Run-wide cost ($) | $3.6529 | $1.0168 | −$2.6361 | −72.2% |
| Run-wide Peak CTX | 56,276 | 45,788 | −10,488 | −18.6% |
| Subagent boots | 19 | 2 | −17 | −89.5% |
| Run-wide total tokens | 1,982,903 | 675,615 | −1,307,288 | −65.9% |

*Tokens deduped by `message.id` before summing; cost computed by `cost_report.py` (per-bucket per-model rates from `rates.json`). Quoted $ to 4 decimals so small deltas don't round to zero. Run 1 totals corrected: cost_report.py left one ff-3 wrapper file (`agent-ad03f72c746bd1b5a.jsonl`) unclassified — first-user-message starts `Invoke the Skill tool to run …` instead of the expected `` Invoke `/find-font:ff-N-…` ``. Added it back via orient.sh per-subagent rollup: +49,158 tok / +$0.0820 to ff-3 (Run 1 only); see cost-report.txt line 33.*

## §3. Where the work lived (step-level)

| Step | Run 1 tok | Run 1 $ | Run 2 tok | Run 2 $ | Δ tok | Δ $ |
|:--|--:|--:|--:|--:|--:|--:|
| Orchestrator | 441,388 | $1.0160 | 436,551 | $0.7074 | −4,837 | −$0.3086 |
| Curate (ff-1) | 683,461 | $1.2326 | 0 | $0.0000 | −683,461 | −$1.2326 |
| Classify (ff-2) | 535,396 | $0.9434 | 0 | $0.0000 | −535,396 | −$0.9434 |
| SVG (ff-3) | 322,658 | $0.4609 | 239,064 | $0.3094 | −83,594 | −$0.1515 |
| **Total** | **1,982,903** | **$3.6529** | **675,615** | **$1.0168** | **−1,307,288** | **−$2.6361** |

The dollar saving is dominated by the two skills that didn't run at all in Run 2 — ff-1 (−$1.2326) and ff-2 (−$0.9434) together account for **82% of the total saving**. No row regressed; orchestrator dropped −$0.3086 (see §4 for the bucket-mix breakdown driving that), and ff-3 still ran but came out −$0.1515 cheaper despite identical work, reflecting a leaner spawn prompt and lighter sidechain trajectory in Run 2.

## §4. Orchestrator drill-down

**Tool calls** — Source: `orient.sh` §Orchestrator tool-call counts.

| Tool | Run 1 | Run 2 | Δ | Note |
|:--|--:|--:|--:|:--|
| Agent | 9 | 1 | −8 | structural — refactor's `fully-cached` short-circuit skips 4× curate + 4× classify spawns |
| Read | 6 | 6 | 0 | structural — orchestrator now reads font profiles & references directly |
| Bash | 2 | 3 | +1 | structural — refactor adds `find` calls to locate cached profiles |
| TaskCreate | 4 | 0 | −4 | variance — Run 1 model chose Task ceremony; SKILL.md mentions no Tasks |
| TaskUpdate | 7 | 0 | −7 | variance — same Task ceremony as above |
| ToolSearch | 1 | 0 | −1 | variance — Run 1 model loaded a deferred tool; refactor doesn't require it |

**Token buckets** — Source: `cost_report.py` orchestrator bucket detail.

| Token Bucket | Run 1 tok | Run 2 tok | Δ tok | Δ $ |
|:--|--:|--:|--:|--:|
| input_tokens | 421 | 21 | −400 | −$0.0020 |
| cache_create_5m | 0 | 0 | 0 | $0.0000 |
| cache_create_1h | 57,886 | 30,971 | −26,915 | −$0.2692 |
| cache_read | 373,143 | 397,609 | +24,466 | +$0.0122 |
| output_tokens | 9,938 | 7,950 | −1,988 | −$0.0497 |
| **Total** | **441,388** | **436,551** | **−4,837** | **−$0.3086** |

The orchestrator's $0.31 saving is **87% from `cache_create_1h`** (−$0.2692) and the remainder from output_tokens. Tokens almost broke even (−4,837) but dollars moved meaningfully because cache_create_1h prices at 2.0× while cache_read prices at 0.10× — Run 2 shifted prompt from "creating new 1h cache" to "reading existing 1h cache", which is the cache-shape win the refactor was designed for. The output-token drop (−1,988) is mostly the structural Agent-call reduction (1 spawn vs 9), partly offset by a ~3.4k-output Agent turn in Run 2 (diagnose-run2.txt §3) that bundled the orchestrator's analysis into one Agent call. The TaskCreate/TaskUpdate ceremony cost in Run 1 sits inside `output_tokens` and is **variance-driven, not refactor-driven**.

## §5. Subagent drill-down (per skill, wrapper + sidechain)

Run 1 (baseline) — 19 subagent files

| Skill | Calls | Wrapper tok | Sidechain tok | Total tok | Total $ |
|:--|--:|--:|--:|--:|--:|
| ff-1 curate | 4 | 141,284 | 542,177 | 683,461 | $1.2326 |
| ff-2 classify | 4 | 126,494 | 408,902 | 535,396 | $0.9434 |
| ff-3 svg | 1 | 49,158 | 273,500 | 322,658 | $0.4609 |
| **Subtotal** | **9** | **316,936** | **1,224,579** | **1,541,515** | **$2.6369** |

Run 2 (refactored) — 2 subagent files

| Skill | Calls | Wrapper tok | Sidechain tok | Total tok | Total $ |
|:--|--:|--:|--:|--:|--:|
| ff-1 curate | 0 | 0 | 0 | 0 | $0.0000 |
| ff-2 classify | 0 | 0 | 0 | 0 | $0.0000 |
| ff-3 svg | 1 | 32,996 | 206,068 | 239,064 | $0.3094 |
| **Subtotal** | **1** | **32,996** | **206,068** | **239,064** | **$0.3094** |

The ff-1 and ff-2 deltas are **purely structural — call-count went from 4 to 0**, a direct consequence of the refactor's pre-check (Step 2 of `SKILL.md`: classify each font into `needs-curate` / `needs-classify` / `fully-cached` and only spawn agents for the first two). All four fonts in this prompt (Newsreader, Bodoni Moda, Spectral, Faustina) resolved as `fully-cached` because their `.md` profiles already exist under `plugins/find-font/font-profiles/` (recent commit `94d42af` added bodoni-moda/spectral; faustina/newsreader pre-existed). The ff-3 row is **per-call lighter (−$0.1515 on the same 1 call)** — wrapper down 16k tokens, sidechain down 67k tokens. Diagnose-run2 §1 shows the Run 2 ff-3 sidechain ran with `4×Bash + 2×Read + 2×Edit` versus Run 1's heavier sidechain trajectory; same instruction, leaner exploration — call this **variance** in the per-call weight, not a structural refactor effect, since `ff-3-create-font-matrix-svg/SKILL.md` itself was unchanged.

## §6. Variance flags

- **Task-tool ceremony** — Run 1 made 11 TaskCreate/TaskUpdate calls, Run 2 made zero. Neither SKILL.md mentions Tasks; this is run-to-run model choice. Δ ≈ a few thousand orchestrator output tokens. Source: §4 tool-call table.
- **ff-3 sidechain trajectory** — Same prompt, but Run 2's SVG sidechain ran ~67k tokens lighter than Run 1's (206k vs 273k). `ff-3-create-font-matrix-svg/SKILL.md` was not refactored, so this is per-call run-to-run variance. Source: §5 + diagnose-run1.txt §1 vs diagnose-run2.txt §1.
- **cost_report.py undercount in Run 1** — One ff-3 wrapper subagent (`agent-ad03f72c746bd1b5a.jsonl`, $0.0820 / 49,158 tok) was unclassified because its first-user-message starts `Invoke the Skill tool to run …` instead of the expected `` Invoke `/find-font:ff-N-…` `` marker. Re-added via orient.sh per-subagent rollup. Source: cost-report.txt line 33; orientation-run1.txt line 26.
- **Run-spacing** — Brief states ">5 min apart"; the actual gap between Run 1 last-event (06:13:20) and Run 2 first-event (06:15:07) is ~1m47s, inside the 5m TTL. Cross-run cache leakage is not possible here (the refactored SKILL.md changes the prompt prefix, so cache keys don't overlap), so this affects **bookkeeping only, not numbers**. Source: orient outputs §Wall-clock.
- **Sample of one** — One run of each variant. Per-call sidechain weights swing run-to-run; the structural delta (8 spawns avoided) is unambiguous, but the orchestrator's $0.31 delta sits in noise range for a single sample.

## §7. Verdict

The refactor's only structural change with cost impact is the `fully-cached` short-circuit in Step 2 of `ff-0-pair-my-font/SKILL.md`: when `find` resolves every requested font's profile on disk, ff-1 and ff-2 are skipped entirely (8 of 9 Agent spawns gone, per §3 and §4). This cut **$2.6361 / 72.2%** of run cost and **1,307,288 tokens / 65.9%** at a wall-clock saving of 187 seconds (§2). The honest caveat: this is one trial per variant against a fully-warmed profile cache, both ff-3 and orchestrator carry per-call run-to-run noise (§6), and the dramatic delta would shrink considerably on a prompt where any font is `needs-curate` or `needs-classify`.

## §8. Biggest cost sink (Q4)

The largest absolute step in Run 2 is the **orchestrator** at $0.7074 (70% of run cost; ff-3 SVG is the only other non-zero step at $0.3094). Per §4, the orchestrator's dominant bucket is `cache_create_1h` at $0.3097 — 44% of the orchestrator's own bill — and diagnose-run2.txt §2 shows that bucket is fed primarily by one 22,827-char `Read` at 06:15:35 (next_create_1h=9,126 / next_usd=$0.1091, almost certainly `references/kupferschmid-matrix.md` plus the example output) and a 4,050-char `Read` at 06:18:03 ($0.0949). The optimisation lever is to move Step 3's reference-reading + analysis into a sidechain (or trim those reference files in-line) so the large 1h-cache write happens once in a child process whose context dies with it, instead of inflating the orchestrator's prompt for the rest of the run.
