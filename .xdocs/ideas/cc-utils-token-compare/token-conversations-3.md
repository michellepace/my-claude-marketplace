<plan>

# Plan: Rebuild prompt_1 / prompt_2 / prompt_3 token table with deduped data

## Context

The user is comparing three Claude Code conversations (`prompt_1`, `prompt_2`, `prompt_3` — all in the devflow project) to figure out which of their prompt phrasings produced more focused work from the model. My **first answer in this conversation was wrong**: I summed raw JSONL rows under `.message.usage`, but Claude Code splits a single API call into multiple JSONL rows whenever the response has multiple content blocks (text + thinking + tool_use). All rows sharing a `message.id` carry the **same** `usage` object, so naive row-summing double/triple-counts every call. The user pointed me at `token-conversations-2.md`, which already established the dedup-by-`message.id` fix on prompt_1, and asked me to redo the whole table with that fix, add a "User msgs" row, and validate the numbers myself rather than trusting the prior file blindly.

A second issue surfaced during validation: **the prompt_3 session has been actively used since my first answer**. Original snapshot was 7 calls / peak 27,681; current snapshot is 27 calls / peak 67,316. The deliverable uses fresh numbers and notes this drift.

## Source files

| Name | Path |
|---|---|
| prompt_1 | `~/.claude/projects/-home-mp-projects-nextjs-devflow/b50a9757-8e13-4543-9bbd-feac5c840edb.jsonl` |
| prompt_2 | `~/.claude/projects/-home-mp-projects-nextjs-devflow/5cca7b5a-a076-4f49-a7de-b43f03865eaa.jsonl` |
| prompt_3 | `~/.claude/projects/-home-mp-projects-nextjs-devflow/0c0a2a65-b997-4bba-a660-0a2602ac1fdd.jsonl` |

(Identified by the `{"type":"custom-title","customTitle":"prompt_N",...}` line inside each file.)

## Methodology

1. **Calls (turns)** — group rows where `.message.usage != null` by `.message.id`, count distinct ids. (Equivalent to `.requestId` here — both give the same count.)
2. **Per-call usage** — take the usage object from the first row of each id-group (verified identical across all rows in the group).
3. **input / cache_creation / cache_read / output totals** — sum the four `usage` fields across the deduped per-call objects.
4. **Peak ctx** — `max( input_tokens + cache_creation_input_tokens + cache_read_input_tokens )` across the deduped per-call objects. The per-call sum of these three is the prompt the model actually had to read on that turn.
5. **User msgs** — count `type=="user"` rows where `isSidechain==false` and `.message.content` is a string and the string does **not** start with `<local-command-`, `<system-reminder>`, `Caveat:`, or `<command-name>`. The few `text`-array user rows in each file were inspected and turned out to all be `[Request interrupted by user]` notices, not typed prompts — so the string filter is sufficient.

## Execution after plan approval

See `<deliverable>` below.

</plan>

---

<deliverable>

## Token usage by conversation (deduped, fresh snapshot)

| Metric | prompt_1 | prompt_2 | prompt_3 |
|---|--:|--:|--:|
| User msgs (typed by you) | 3 | 3 | 2 |
| Turns (API calls) | 28 | 10 | 27 |
| `input_tokens` (uncached input) | 48 | 35 | 42 |
| `cache_creation_input_tokens` | 82,689 | 95,751 | 119,554 |
| `cache_read_input_tokens` | 934,323 | 331,654 | 1,034,343 |
| `output_tokens` (model output) | 17,820 | 27,871 | 20,865 |
| **Peak ctx** (largest single prompt) | **53,992** | **65,056** | **67,316** |

Rows are ordered top-to-bottom as the data flows: what you typed → how many round-trips it took → the four token buckets the model read/wrote on each round-trip → the peak single-call prompt size.

### Notes

1. **Peak ctx = max single-call (`input_tokens` + `cache_creation_input_tokens` + `cache_read_input_tokens`).** It is a **per-call maximum**, not a sum across the conversation. It tells you the size of the largest prompt the model ever had to read on a single round-trip — i.e. how much state it had to juggle at the densest moment. (`output_tokens` is excluded because it's what the model *wrote*, not what it read.)

2. **A turn = one round-trip with the API** (one model call: prompt in, response out). Every typed user message triggers one or more turns; every tool result the model wants to use triggers another turn. Claude Code stores some single-call responses across multiple JSONL rows when the response has multiple content blocks (text + thinking + tool_use), so this count is deduped by `message.id` rather than counting raw rows.

### What it tells you

- **prompt_2 was the most efficient per call**: only 10 round-trips, but the highest output-per-call (~2.8k tokens vs ~640 / ~770 for prompts 1 and 3) and the smallest cumulative `cache_read`. The model finished each turn in fewer iterations.
- **prompt_1 and prompt_3 are similar in shape**: ~28 calls, ~33–38k average prompt size per call, similar peak ctx.
- **prompt_3's peak ctx (67k) is the highest** despite having the fewest typed user messages (2). Pointing the model at a long instruction file (`@x2-improved.md`) and letting it run produced the densest single-turn context, but not necessarily the most output.
- **User msgs ÷ Turns ratio** is a rough "steering" indicator — prompt_2 = 0.30 (you typed often relative to how much Claude did between), prompt_1 = 0.11, prompt_3 = 0.07 (most autonomous run).

## Verifications

I sanity-checked everything before writing the table — none of these were taken on faith from `token-conversations-2.md`:

1. **Row type check** — every row carrying `.message.usage` is `type:"assistant"` (44 / 41 / 41 rows respectively). No tool-result or system row contributes phantom usage.
2. **Dedup is sound** — for every `message.id` group, all rows in the group have an **identical** `usage` object (jq `unique | length` is always 1). Confirms naive row-summing multi-counts and dedup-by-id is the correct fix.
3. **Row-per-call distribution makes sense** — prompt_1: most calls split into 1-2 rows, max 3; prompt_2: heavy splitting (calls of 5 / 6 / 7 rows are common — this is why prompt_2's raw row count was inflated 4× by the original method); prompt_3: mostly 1-2 row calls. The distributions add back to the raw row counts (44 / 41 / 41).
4. **Cross-check against `token-conversations-2.md` for prompt_1** — my deduped numbers (48 / 17,820 / 82,689 / 934,323; 28 calls; peak 53,992) match that file **exactly**. Methodology is correct.
5. **User-msg filter doesn't drop real prompts** — checked the small number of `text`-array (non-string) user-content rows in each file. All were `[Request interrupted by user]` system notices, not user-typed prompts. String filter is complete.
6. **`sum(input + cache_creation)` vs `peak_ctx` ratio** — 1.53× / 1.47× / 1.78×. All > 1, all < 2. This is the expected range for a normal conversation: each call's `output` becomes part of the next call's cached prefix (so it shows up in `cache_creation` on the *next* call), which inflates cumulative `cc` above the peak window. A ratio of 1× would mean zero turnover; > 2× would suggest cache eviction or branching. None of the three sessions show pathological turnover.
7. **`max_single_call_cc` < `peak_ctx`** — 38,103 < 53,992 (prompt_1), 20,407 < 65,056 (prompt_2), 51,506 < 67,316 (prompt_3). Correct, since `peak_ctx` adds `cache_read` on top of `cache_creation` for that same turn.
8. **`avg(cache_read per call)` < `peak_ctx`** — 33,368 / 33,165 / 38,309 vs peaks 53,992 / 65,056 / 67,316. Correct, since the peak is by definition the max and the average must be ≤ max.
9. **Snapshot freshness** — re-ran all queries during this plan; **prompt_3 has grown** since the original snapshot taken earlier this conversation (was 7 calls / peak 27,681; now 27 calls / peak 67,316). You must still be actively using that session in another terminal. The table above uses the **current** snapshot. prompt_1 and prompt_2 are unchanged from the original measurement.

**Verification commands (reproducible):**

```bash
# Deduped per-call totals + peak ctx for one file
jq -c 'select(.message.usage != null) | {mid: .message.id, u: .message.usage}' "$path" \
  | jq -s 'group_by(.mid) | map(.[0].u) | {
      n_calls: length,
      input: (map(.input_tokens // 0) | add),
      output: (map(.output_tokens // 0) | add),
      cache_creation: (map(.cache_creation_input_tokens // 0) | add),
      cache_read: (map(.cache_read_input_tokens // 0) | add),
      peak_ctx: (map((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)) | max)
    }'

# Typed user msgs in one file
jq -r '
  select(.type=="user" and .isSidechain==false and (.message.content | type=="string"))
  | .message.content
  | select(
      (startswith("<local-command-") | not)
      and (startswith("<system-reminder>") | not)
      and (startswith("Caveat:") | not)
      and (startswith("<command-name>") | not)
    )
' "$path" | grep -c .   # ← caveat: this counts MESSAGES correctly only because the
                         #    surviving prompts each emit one match line; for safety
                         #    pipe through `jq -s length` instead.
```

</deliverable>
