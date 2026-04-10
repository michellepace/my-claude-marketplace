# Understanding Claude Code Token Numbers — prompt_1 Walkthrough

## The question

You're staring at six terms that all sound like they should add up, but don't:

- `input_tokens`
- `output_tokens`
- `cache_creation_input_tokens` (I'll call it `cache_creation`)
- `cache_read_input_tokens` (I'll call it `cache_read`)
- "Peak context window"
- "Σ new tokens (in+out+cache_create)" — the cumulative figure I gave in my first answer

This document explains what each one is, where it comes from, and how it relates to the **54k/1m (5%)** that `/context` reports for **prompt_1**.

## The mental model: every turn is one API call

Inside a Claude Code session, each time the model speaks it's because Claude Code made one HTTP request to Anthropic's Messages API:

```text
[ Claude Code ]  ──── prompt ────▶  [ Anthropic API ]
                                          │
                                          ▼
                                       model runs
                                          │
                 ◀──── reply + usage ─────┘
```

The reply carries a `usage` object describing **what just happened on that one request** [^1]. Four counters, all per-call:

| Field | What it counts |
|---|---|
| `input_tokens` | new prompt tokens on this call, **after the last cache breakpoint**, that weren't cached |
| `cache_creation_input_tokens` | prompt tokens on this call that were **written into** the cache (billed at 1.25×) |
| `cache_read_input_tokens` | prompt tokens on this call that were **read from** an earlier cache write (billed at 0.1×) |
| `output_tokens` | tokens the model **generated** in its reply |

A subtlety worth knowing: caching does **not** shrink the prompt the model actually reads. The model still sees every byte. Caching is a billing/latency optimization — the server already has those tokens pre-computed and serves them cheaply [^2].

## The key identity (the one fact that unlocks everything)

Anthropic's prompt-caching docs spell it out exactly [^3]:

> `total_input_tokens = cache_read_input_tokens + cache_creation_input_tokens + input_tokens`

So for any single API call:

```
prompt size the model saw  =  cache_read + cache_creation + input
```

`output_tokens` is **not** part of that sum. It's what the model wrote *back*. Generated tokens only enter a future prompt on the *next* turn (where they'll usually show up under `cache_creation`, then `cache_read` after that).

## prompt_1 walkthrough — real numbers from your jsonl

prompt_1 is `b50a9757-…jsonl` — **5 user prompts that fanned out into 44 assistant API responses** (every tool call triggers another model invocation, so heavy tool use multiplies the response count). When this doc says "turn N", it means the N-th of those 44 assistant responses, not the N-th user prompt. The very first user message in that session was *"Please confirm if this is true:"* followed by a Node version listing.

### Turn 1 — the very first model response

```
input_tokens                 :     6
cache_creation_input_tokens  : 8,948
cache_read_input_tokens      : 15,378
output_tokens                :   153
```

Prompt size the model saw on turn 1:

```
6 + 8,948 + 15,378  =  24,332 tokens
```

Of those, 15,378 were already cached from prior Claude Code state (system prompt, tool definitions, memory files). 8,948 were freshly written into the cache on this call. Just 6 were uncached "after the last cache breakpoint" — the genuinely new bits Claude Code couldn't reuse. The model then wrote **153** tokens of reply. Those 153 are *not* in the 24,332.

### Turn 12 — somewhere in the middle

```
input_tokens                 :      1
cache_creation_input_tokens  :    497
cache_read_input_tokens      : 30,528
output_tokens                :    543
```

Prompt size on turn 12: `1 + 497 + 30,528 = 31,026 tokens`.

The conversation has grown — more history to send each call. Notice the cache is doing its job: 30,528 of those 31,026 were served cheaply from cache; only 498 were new work for the cache layer.

### Turn 44 — the very last model response

```
input_tokens                 :      1
cache_creation_input_tokens  :    417
cache_read_input_tokens      : 53,574
output_tokens                :    111
```

Prompt size on turn 44:

```
1 + 417 + 53,574  =  53,992 tokens
```

**That is the 54k that `/context` shows you.** Rounded to "54k/1m (5%)". One number, one snapshot, one moment in time — the size of the prompt sent on the most recent API call.

## "Peak context window"

By "peak" I just meant: the largest single-turn prompt size seen during the conversation. In an uncompacted Claude Code session the prompt only grows turn-by-turn (each new user message and tool result gets appended), so the **last** turn is also the **biggest** turn. For prompt_1 the peak is 53,992 — exactly what `/context` reports right now.

```
peak_context_window  =  max over all turns of (input + cache_creation + cache_read)
                     =  what /context displays
```

If you'd run `/context` at turn 12, it would have said ~31k. At turn 44 it says 54k. Same conversation, different snapshots.

## Why "Σ new tokens (in + out + cache_create)" is **not** the same thing

In my first answer I gave you a cumulative number — **150,603** — labelled "Σ new tokens (in+out+cache_create)" for prompt_1. That number is **not** the context window. Here's what it actually is and why it doesn't match `/context`:

- I walked through all 44 turns and added up `input_tokens + output_tokens + cache_creation_input_tokens` for each.
- That's a **billing-style aggregate**: roughly "how many novel tokens were processed or generated across the whole session, ignoring re-reads from cache."
- It's meaningful for **cost** (it approximates what `/cost` multiplies against the price list), but it has nothing to do with how full the context window is *right now*.

I deliberately excluded `cache_read` from that sum, because if I'd included it the same tokens would get counted dozens of times — once per turn — and the total would balloon to ~1.6M for a session whose context window never held more than 54k. Either way (with or without `cache_read`), **summing across turns answers a billing question, not a context-window-fullness question.**

Three different questions, three different numbers:

| Question | Right metric | prompt_1 value |
|---|---|---:|
| How full is the context window right now? | `input + cache_creation + cache_read` on the latest turn | **53,992** ≈ /context's 54k |
| How much total work did this session cost? | sum across turns of `(input + output + cache_creation)` | 150,603 |
| How much cache reuse happened in total? | sum across turns of `cache_read` | 1,462,649 |

None of them is "wrong" in isolation. The mistake was using the second one as if it answered the first.

## A picture for prompt_1

```
turn 1   prompt =  24,332  ┃■■                                     ┃  + 153 out
turn 12  prompt =  31,026  ┃■■■                                    ┃  + 543 out
turn 44  prompt =  53,992  ┃■■■■■                                  ┃  + 111 out  ◀── /context "54k/1m"
                            └────────────────────────────────────────┘
                            0                                        1,000,000
```

The bar grows turn-by-turn as conversation history accumulates. `/context` just prints the length of the **last** bar.

## TL;DR

- **`input_tokens`** — new prompt tokens this call, after the last cache breakpoint, not in cache.
- **`cache_creation_input_tokens`** — prompt tokens this call that got written into the cache.
- **`cache_read_input_tokens`** — prompt tokens this call that were served cheaply from a previous cache write.
- **`output_tokens`** — tokens the model wrote back; not part of the prompt.
- **Peak / current context window** = `input + cache_creation + cache_read` on the most recent turn = what `/context` shows. For prompt_1: **53,992 ≈ 54k**. ✅
- **"Σ new tokens"** = a cumulative billing-style aggregate I made up in my first answer. It answers *"how much work?"* not *"how full?"*.

## Reference

## Footnote [^1]

Anthropic Messages API reference — `usage` object. Each of the four field names used in this document is defined here.

<https://docs.anthropic.com/en/api/messages>

> "The cumulative number of input tokens which were used."
>
> "The cumulative number of output tokens which were used."
>
> "The cumulative number of input tokens used to create the cache entry."
>
> "The cumulative number of input tokens read from the cache."

## Footnote [^2]

Anthropic prompt caching documentation — caching is a billing/latency optimization only. The model still sees the full prompt regardless of whether parts of it were served from cache.

<https://platform.claude.com/docs/en/build-with-claude/prompt-caching>

> "Prompt caching has no effect on output token generation. The response you receive will be identical to what you would get if prompt caching was not used."

## Footnote [^3]

Anthropic prompt caching documentation — the total-input-tokens identity, and what `input_tokens` actually represents in the presence of cache breakpoints.

<https://platform.claude.com/docs/en/build-with-claude/prompt-caching>

> "total_input_tokens = cache_read_input_tokens + cache_creation_input_tokens + input_tokens"
>
> "The `input_tokens` field represents only the tokens that come after the last cache breakpoint in your request — not all the input tokens you sent."

## Footnote [^4]

**All concrete numbers in this document were computed locally** from prompt_1's session file. The shell variable `$F` below points at that file:

```
F=~/.claude/projects/-home-mp-projects-nextjs-devflow/b50a9757-8e13-4543-9bbd-feac5c840edb.jsonl
```

Each of the three commands below has its verbatim output shown so you can re-run and verify against the doc.

### (a) Per-turn breakdowns

Source for the **Turn 1 / Turn 12 / Turn 44** walkthroughs in the body of the document.

```
jq -c 'select(.message.usage) | .message.usage' "$F" | awk 'NR==1 || NR==12 || NR==44'
```

Output (relevant fields only — the raw `usage` objects also contain `server_tool_use`, `service_tier`, `iterations`, etc., which are unrelated to context-window accounting):

```
turn  1: input_tokens=6  cache_creation=8948 cache_read=15378 output=153
turn 12: input_tokens=1  cache_creation=497  cache_read=30528 output=543
turn 44: input_tokens=1  cache_creation=417  cache_read=53574 output=111
```

### (b) Cumulative aggregate across all 44 assistant turns

Source for `Σ(input + output + cache_creation) = 150,603` and `Σ cache_read = 1,462,649` in the "Three different questions, three different numbers" table.

```
jq -r 'select(.message.usage) | .message.usage
       | "\(.input_tokens // 0)\t\(.output_tokens // 0)\t\(.cache_creation_input_tokens // 0)\t\(.cache_read_input_tokens // 0)"' "$F" \
  | awk 'BEGIN{i=0;o=0;cc=0;cr=0}
         {i+=$1; o+=$2; cc+=$3; cr+=$4}
         END{printf "input=%d output=%d cache_creation=%d cache_read=%d turns=%d sum_in_out_cc=%d\n",
                    i,o,cc,cr,NR,i+o+cc}'
```

Output:

```
input=79 output=39507 cache_creation=111017 cache_read=1462649 turns=44 sum_in_out_cc=150603
```

Mapping back to the doc:

- `sum_in_out_cc=150603` → the **150,603** "total work" cell
- `cache_read=1462649` → the **1,462,649** "cache reuse" cell
- `turns=44` → "44 assistant turns"

### (c) Peak single-turn prompt size

Source for the **53,992** that matches `/context`'s "54k/1m" reading.

```
jq -r 'select(.message.usage) | .message.usage
       | ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))' "$F" \
  | awk 'BEGIN{m=0} {if($1>m)m=$1} END{print "peak="m}'
```

Output:

```
peak=53992
```

Because prompt_1 was never compacted, the peak equals the **last** turn's `input + cache_creation + cache_read`, which is also the value `/context` would print at any moment up to the latest assistant message.
