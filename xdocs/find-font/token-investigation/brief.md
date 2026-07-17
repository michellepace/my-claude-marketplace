# Investigation: Has the refactoring of `plugins/find-font/skills/ff-0-pair-my-font/SKILL.md` increased token efficiency?

## Investigation Goal

Compare two Claude Code runs of `/ff-0-pair-my-font` — same prompt, baseline SKILL.md (`b3fffd5`) vs refactored (`68721a0`) — and answer:

1. **Did it get cheaper?** — run-wide tokens, peak context, wall-clock, subagent count.
2. **Where did the cost shift?** — which step (orchestrator / curate / classify / svg), and which kind of work (Agent spawns / Skill invocations / token buckets).
3. **Is the change structural or noise?** — refactor effect vs run-to-run model variance.
4. **Where is the single biggest cost sink?** — name the one step (orchestrator, ff-1, ff-2, or ff-3) that, if optimised, would cut the most **dollars**, and say why.

Produce a short, scannable verdict in `brief-results.md` (under the relevant `experiment-NN/` folder — see [Execution Runbook](#execution-runbook)).

## Experiment Outline

`/ff-0-pair-my-font` (the orchestrator at `plugins/find-font/skills/ff-0-pair-my-font/SKILL.md`) spawns subagents. An experiment was run with two different versions of this file:

| Run | Variant | SKILL.md @ commit | Session path (passed to all tools below) |
| :--- | :--- | :--- | :--- |
| 1 | baseline | `b3fffd5` | `~/.claude/projects/-home-mp-projects-shopify-sparklepop/SESSION_1` |
| 2 | refactored | `68721a0` | `~/.claude/projects/-home-mp-projects-shopify-sparklepop/SESSION_2` |

Each path fans out to `<path>.jsonl` (orchestrator) + `<path>/subagents/` (subagents) — see [Run Transcript Sources](#run-transcript-sources).

The same instruction was given to Claude Code:

```text
/find-font:ff-0-pair-my-font Body font Newsreader. Pairing candidates are Bodoni Moda, Spectral, faustina. No other pairing candidates needed. I'm aiming for clean luxary with high readability. Include SVG matrix.
```

Each experiment ran in Claude Code terminal with PWD `~/projects/shopify/sparklepop`. Runs were spaced > 5 minutes apart so the 5m cache had expired between them — no cross-run cache leakage. Within a single run the cache *is* shared across the orchestrator and its subagents, which is exactly what the refactor changes.

## Run Transcript Sources

Per-stem artefacts:

- `<stem>.jsonl` — orchestrator transcript.
- `<stem>/subagents/` — per subagent: `agent-<id>.jsonl` (transcript) + `agent-<id>.meta.json` (`description` set for wrappers, absent for sidechains). Includes sub-helpers spawned by other subagents.

**JSONL field shape** (for custom `jq`/Python — Constraints allow deviating from scripts):

```jsonc
{
  "type": "assistant" | "user",
  "timestamp": "...",
  "parentUuid": "...",  // on a subagent's first row → spawning orchestrator turn
  "message": {
    "id": "msg_…",       // dedup by this when summing tokens (see caveat below)
    "model": "claude-opus-4-7",
    "usage": {
      "input_tokens": 5,                   // post-last-cache-breakpoint, NOT full prompt
      "cache_creation_input_tokens": 9809, // = ephemeral_5m + ephemeral_1h
      "cache_read_input_tokens": 14816,
      "output_tokens": 1103,
      "cache_creation": { "ephemeral_5m_input_tokens": 0, "ephemeral_1h_input_tokens": 9809 }
    },
    "content": [ { "type": "tool_use", ... } | { "type": "tool_result", ... } ]
  }
}
```

Parallel `tool_use` blocks in one turn persist as separate rows sharing `message.id` + `message.usage` — dedup by `message.id` for token sums; do NOT dedup for peak-CTX or tool-call counts.

## Analysis tools

Three scripts produce the data behind the deliverable — costs (`cost_report.py`), orientation (`orient.sh`), diagnosis (`diagnose.sh`). This section provides contextual knowledge for understanding tool outputs.

### Costs: cost_report.py

CLI: `uv run cost_report.py <session> [<compare-session>]` — second arg adds the Δ table. See `--help`.

Output blocks: **Per-step rollup** → §2 row 2 + §3; **Orchestrator bucket detail** → §4 buckets; **Per-skill wrapper/sidechain split** → §5.

**Per-bucket cost weight** (× the model's base `input_tokens` rate; constant across all models):

| Token Bucket | `message.usage` field | × base input_tokens |
| :-- | :-- | --: |
| input_tokens | `input_tokens` | 1.00× |
| cache_create_5m | `cache_creation.ephemeral_5m_input_tokens` | 1.25× |
| cache_create_1h | `cache_creation.ephemeral_1h_input_tokens` | 2.00× |
| cache_read | `cache_read_input_tokens` | 0.10× |
| output_tokens | `output_tokens` | 5.00× |

Reference for reading §4's `$` column.

**Subagent classification** (drives the per-skill wrapper/sidechain split, by first user message):
- **Wrapper** (Agent tool body) starts with: `` Invoke `/find-font:ff-N-...` using the Skill tool. ``
- **Sidechain** (Skill tool body) starts with: `Base directory for this skill: .../ff-N-...`

### Orientation: orient.sh

CLI: `./orient.sh <session>`.

Output blocks (peak context, timing, spawn order, tool behaviour):

- **Run-wide Peak CTX** — context-pressure vs the 200k window, not a cost.
- **Per-subagent rollup** — spawn-time, peak CTX, total tokens (deduped), `cache_read_%`, `usd`, description. High `cache_read_%` = cheap regardless of total tokens. Default sort is spawn order.
- **Wall-clock duration** — `elapsed / idle / active`. Quote `active` in §2.
- **Orchestrator tool-call counts** — feeds §4's "Tool calls" table.

### Diagnosis: diagnose.sh

Run after `cost_report.py` flags a regression to localise *why* a step grew. CLI: `./diagnose.sh <session>`.

Output blocks:

- **§1 Per-subagent tool-call counts** — what each subagent actually did.
- **§2 Top-10 largest tool_result payloads** — payload size + next-turn bucket fate (`next_create_5m`, `next_create_1h`, `next_read`, `next_usd`).
- **§3 Orchestrator per-turn output histogram** — all turns by output (deduped by `message.id`), with tool mix per turn.
- **§4 First user message size per subagent** — flags front-loaded spawn prompts.
- **§5 Orchestrator tool-call counts** — duplicate of `orient.sh`'s last block, for self-containment.

§2 caveat: payload size ≠ dollars — sibling subagents share prompt cache, so read `next_usd`, not `size_chars`.

## Execution Runbook

**Rely on analysing the output of these tools coupled with the knowledge in this brief. Perform the initial analysis then analyse deeper.**

**Folder convention:** each experiment lives under `xdocs/find-font/token-investigation/experiment-NN/`. All tool outputs and the final `brief-results.md` go in that folder.

Initial Analysis:

```bash
# Per session — for K = 1, 2:
./orient.sh <sK>                  > experiment-NN/orientation-runK.txt

# Once — read CLI, then produce run
uv run cost_report.py --help      # Read CLI surface always
uv run cost_report.py <s1> <s2>   > experiment-NN/cost-report.txt
```

Deeper Analysis:

```bash
# # Per session — for K = 1, 2:
./diagnose.sh <sK>                > experiment-NN/diagnose-runK.txt
```

Ad hoc Analysis / Additional Insight:
- Conduct against raw transcripts as needed
- Leverage textual understanding from this brief and/or scripts

## Deliverable

Produce `xdocs/find-font/token-investigation/experiment-NN/brief-results.md`. Eight sections in order, each one short.

The intent of this layout: each section answers exactly one question, so a reader can scan the report top-to-bottom and pinpoint root causes without re-reading. Don't add prose beyond what's specified — the tables are the report.

### §1. TL;DR (3 sentences max)

Lead sentence: plain-language verdict. Second sentence: the five headline numbers from §2 in this order — wall-clock, **cost ($)**, peak CTX, subagent boots, tokens. Third sentence: the single biggest variance flag from §6 (so the reader knows what *not* to attribute to the refactor). End with a single bold line of this shape:

<authoring_template>

**Verdict:** The refactor reduced / regressed / preserved cost by X% (Y% on tokens, Z% wall-clock). [one sentence.]

</authoring_template>

### §2. Headline comparison

One table, five rows. Order = user-felt → financial → risk → structural → raw input.

```markdown
| Metric | Run 1 | Run 2 | Δ | Δ% |
|:--|--:|--:|--:|--:|
| Wall-clock (active) | <m s> | <m s> | <Δ> | <Δ%> |
| Run-wide cost ($) | <$> | <$> | <Δ$> | <Δ%> |
| Run-wide Peak CTX | <n> | <n> | <Δ> | <Δ%> |
| Subagent boots | <n> | <n> | <Δ> | <Δ%> |
| Run-wide total tokens | <n> | <n> | <Δ> | <Δ%> |
```

Footnote (one line): *Tokens deduped by `message.id` before summing; cost computed by `cost_report.py` (per-bucket per-model rates from `rates.json`). Quote $ to 4 decimals so small deltas don't round to zero.*

### §3. Where the work lived (step-level)

Group run-wide tokens by logical step (orchestrator + each `ff-N` skill). Each `ff-N` row sums its Agent wrappers + Skill sidechains. **This replaces the old per-spawn flow tables.** Source: `cost_report.py` per-step rollup (or pass both sessions for the Δ columns pre-computed).

```markdown
| Step | Run 1 tok | Run 1 $ | Run 2 tok | Run 2 $ | Δ tok | Δ $ |
|:--|--:|--:|--:|--:|--:|--:|
| Orchestrator | <n> | <$> | <n> | <$> | <Δ> | <Δ$> |
| Curate (ff-1) | <n> | <$> | <n> | <$> | <Δ> | <Δ$> |
| Classify (ff-2) | <n> | <$> | <n> | <$> | <Δ> | <Δ$> |
| SVG (ff-3) | <n> | <$> | <n> | <$> | <Δ> | <Δ$> |
| **Total** | **<n>** | **<$>** | **<n>** | **<$>** | **<Δ>** | **<Δ$>** |
```

One short paragraph below: which step drove the **dollar** saving (largest negative Δ $), which step regressed (positive Δ $), and one sentence pointing the reader to §4 for the orchestrator bucket-mix breakdown. If Δ tok and Δ $ disagree in sign for any row, call it out — that's a cache-shape shift, not a real cost change.

### §4. Orchestrator drill-down

Two tables, side by side. Together they explain the orchestrator-row Δ from §3.

**Tool calls** — Source: `orient.sh` §Orchestrator tool-call counts (one column per run). Counts are computed naively (no dedup) — `tool_use` blocks are genuinely distinct across parallel-shard rows. Label each row `structural` (caused by the refactor) or `variance` (run-to-run model choice). Add one row per tool name observed in either run.

```markdown
| Tool | Run 1 | Run 2 | Δ | Note |
|:--|--:|--:|--:|:--|
| <tool-name> | <n> | <n> | <Δ> | structural / variance — <reason> |
```

**Token buckets** — five rows, one per priced bucket. Source: `cost_report.py` orchestrator bucket detail. Omit the `cache_create_1h` row if both runs are zero.

```markdown
| Token Bucket | Run 1 tok | Run 2 tok | Δ tok | Δ $ |
|:--|--:|--:|--:|--:|
| input_tokens | <n> | <n> | <Δ> | <Δ$> |
| cache_create_5m | <n> | <n> | <Δ> | <Δ$> |
| cache_create_1h | <n> | <n> | <Δ> | <Δ$> |
| cache_read | <n> | <n> | <Δ> | <Δ$> |
| output_tokens | <n> | <n> | <Δ> | <Δ$> |
| **Total** | **<n>** | **<n>** | **<Δ>** | **<Δ$>** |
```

One short paragraph below: identify which bucket drives the **dollar** Δ. Per the [per-bucket cost-weight table](#costs-cost_reportpy), `output_tokens` and the cache-creation buckets (`cache_create_5m` + `cache_create_1h`) dominate cost; `cache_read` moves tokens but barely moves cost. Tie back to the structural vs variance labels in the tool-calls table.

### §5. Subagent drill-down (per skill, wrapper + sidechain)

Each Skill invocation produces two `agent-*.jsonl` files — a wrapper (`meta.json.description` set) and a sidechain (`description` absent). Group by skill. Source: `cost_report.py` per-skill split; markers in [Subagent classification](#costs-cost_reportpy).

```markdown
Run 1 (baseline) — <n> subagent files
| Skill | Calls | Wrapper tok | Sidechain tok | Total tok | Total $ |
|:--|--:|--:|--:|--:|--:|
| ff-1 curate | <n> | <n> | <n> | <n> | <$> |
| ff-2 classify | <n> | <n> | <n> | <n> | <$> |
| ff-3 svg | <n> | <n> | <n> | <n> | <$> |
| **Subtotal** | **<n>** | **<n>** | **<n>** | **<n>** | **<$>** |
```

```markdown
Run 2 (refactored) — <n> subagent files
| Skill | Calls | Wrapper tok | Sidechain tok | Total tok | Total $ |
|:--|--:|--:|--:|--:|--:|
| ff-1 curate | <n> | <n> | <n> | <n> | <$> |
| ff-2 classify | <n> | <n> | <n> | <n> | <$> |
| ff-3 svg | <n> | <n> | <n> | <n> | <$> |
| **Subtotal** | **<n>** | **<n>** | **<n>** | **<n>** | **<$>** |
```

`Calls` = number of logical Skill invocations for that skill. Total subagent files = `Σ wrappers + Σ sidechains` (each wrapper normally pairs with one sidechain; a skill can also be invoked directly with no wrapper, in which case the wrapper-tokens cell is `0`). `Total $` is computed per skill from its bucket mix, not by averaging — a cache-heavy skill can have a huge token total but a small dollar total. One paragraph below: which row is structural (call-count change) vs variance (per-call sidechain weight). Quote the **dollar** shift, not just tokens.

If a regression isn't fully explained by call-count or per-call weight, run `diagnose.sh` on the regressing run and use §1 (per-subagent tool-call counts) and §3 (orchestrator per-turn output) to localise it. Cite the relevant §N output as the source.

### §6. Variance flags

Bullet list, max five items. Each bullet labels a *non-refactor* difference between runs that affects interpretation. The point of this section: tell the reader explicitly **what to ignore** when judging the refactor.

Template:

<authoring_template>

**{What differed}** — Run 1 did X, Run 2 did Y. Δ ≈ N tokens / seconds. Source: §M.

Examples:
- *One run used a Task / ToolSearch ceremony pattern (M extra tool calls); the other didn't. Δ ≈ N orchestrator tokens. Source: §4.*
- *Skill X's sidechain ran ~N tokens heavier in one run — same instruction, run-to-run trajectory. Source: §5 + `diagnose.sh` §1.*
- *One run has a long idle gap; wall-clock trimmed to active-task period. Source: §2 footnote.*

If there are no variance flags, state that explicitly: *"No notable variance — the runs are directly comparable."*

</authoring_template>

### §7. Verdict (3 sentences)

Restate, in plain language:

1. Sentence 1 — the **structural finding** (what the refactor actually changed, cited from §3-§5).
2. Sentence 2 — the **quantified deltas in dollars and tokens** (cited from §2; lead with $).
3. Sentence 3 — the **honest caveat** (variance from §6, sample-of-one if applicable).

No bullet list, no extra headings, no concluding paragraph — three sentences, then stop.

### §8. Biggest cost sink (Q4)

§3–§5 examined where the refactor *moved* costs. §8 names where costs *are* — so the next round of optimisation has a target. A step that didn't change between runs can still be the largest absolute $.

Two sentences: (1) name the step with the largest absolute $ from §3, and (2) identify one concrete optimisation lever, citing evidence from §4 (orchestrator bucket mix) or §5 (skill: call-count × per-call cost). No table; no implementation recommendation.

## Constraints

- Work from the `.jsonl` files only — do not try to replay or `--resume` sessions.
- Default tools: `cost_report.py` (dollars), `orient.sh` (orientation), `diagnose.sh` (diagnosis). Use them as-is when correct. If you find a bug, an undercount, or a metric they can't produce, deviate: write your own `jq`/Python and add a one-line note in the deliverable stating what you changed and why (e.g. *"`cost_report.py` missed unclassified subagents — added them via jq, +N tokens."*).
- $ figures must come from `cost_report.py` (or your corrected version of it), not hand-math on bash output.
- If a metric genuinely isn't computable from the transcripts, say so — don't fabricate.
