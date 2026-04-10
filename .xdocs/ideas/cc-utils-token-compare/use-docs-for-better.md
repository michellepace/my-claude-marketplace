Both verifications are clean. Here's the synthesis.

## Verification results

**1. The `iterations` field is not a problem.** Across all three files, every assistant call has at most **one** entry in `usage.iterations`, and when present that single entry's values match the top-level `usage` exactly (zero mismatches across 64 calls). One call per long file has *no* `iterations` array at all. So `iterations` is just a redundant per-call breakdown — Claude Code stores both the rolled-up and the per-step view, but for these sessions they're identical. **No undercounting.**

**2. Duplicate-`requestId` lines are byte-identical on usage.** The cost-tracking doc warns that "in rare cases, you might observe different `output_tokens` values for messages with the same ID" and recommends taking the highest. I checked: across 36 duplicated `requestId` groups (15 + 8 + 13), **zero have differing usage**. So my "take the first" dedup is equivalent to "take the highest" here. **No undercounting.**

**3. The cost-tracking doc validates the entire methodology.** This is the document I should have read first. The agent's strongest find. Direct quote:

> Parallel tool calls produce multiple assistant messages whose nested `BetaMessage` shares the same `id` and identical usage. **Always deduplicate by ID** to get accurate per-step token counts.

This is *exactly* what I did. The mapping is:
- SDK `message.message.id` ↔ JSONL `requestId`
- SDK "step" ↔ what I called a "turn"
- The dedup-by-ID rule is *officially documented*, not folklore I had to reverse-engineer.

The doc also defines the hierarchy I was groping toward:

> **`query()` call** → multiple **steps** → each step is one request/response cycle → each step produces assistant messages → multiple messages can share the same `id` (parallel tool use) → deduplicate.

So a "session" (one JSONL file) ≈ a series of `query()` calls, and a "turn" = a "step" = one unique `requestId`.

## The most useful URLs the agent surfaced (ranked)

| URL | Why it would have been useful |
|---|---|
| `https://code.claude.com/docs/en/agent-sdk/cost-tracking.md` | **The single doc I should have read first.** Officially documents the dedup-by-ID rule, defines "step" (= my "turn"), and confirms `cache_creation_input_tokens` / `cache_read_input_tokens` are tracked alongside `input_tokens` not added to it. Validates everything. |
| `https://code.claude.com/docs/en/agent-sdk/sessions.md` | Exposes `listSessions()` / `getSessionMessages()` (TS) and `list_sessions()` / `get_session_messages()` (Py). I parsed JSONL by hand; there's an SDK helper. For a future reusable tool I should use this instead of raw file parsing. |
| `https://platform.claude.com/docs/en/build-with-claude/streaming.md` | Documents that `message_start` carries the initial usage and `message_delta` carries updates — explains *why* the JSONL stores duplicate assistant lines per request: each content block (`thinking`, `tool_use`, `text`) emits its own start/stop event, and Claude Code persists each one separately while they all share the same parent message ID. |
| `https://platform.claude.com/docs/en/build-with-claude/token-counting.md` | Important caveat: "Token counts may include tokens added automatically by Anthropic for system optimizations. **You are not billed for system-added tokens.**" Means raw JSONL totals could be slightly higher than what you actually pay. Doesn't change the comparative analysis though. |
| `https://code.claude.com/docs/en/statusline.md` | Documents how custom statuslines receive session data on stdin — the structured shape might mirror the JSONL fields. Could be a cleaner schema reference than what I reverse-engineered. |
| `https://code.claude.com/docs/en/context-window.md` | Background on how Claude Code packs the context window — useful for understanding what `/context` includes (system prompt, tools, memory, skills, messages) and why the breakdown gap exists. |

## What still doesn't exist

The agent confirmed there is **no published spec for the JSONL session file format**. Field names (`requestId`, `parentUuid`, `isSidechain`, `isMeta`, `slug`, the full set of `type` values) are nowhere in official docs. My reverse-engineered schema is correct for the current Claude Code version, but it could break on upgrade. The robust path is to use the SDK's `getSessionMessages()` / `get_session_messages()` instead of raw file parsing.

## Anything that invalidates the original analysis?

**No.** Both potential issues — `iterations` and per-ID usage discrepancies — were checked empirically and are non-issues for these files. The agent's other concerns (JSONL schema not documented, `/context` algorithm not documented) are real long-term risks but don't undermine the numbers I reported. The cross-validation between my Peak ctx and `/context` (54k / 65.1k / 67.3k) plus the now-confirmed dedup rule from the cost-tracking doc means the table stands.

## What I'd change next time

1. **Read `cost-tracking.md` first** before parsing anything — would have saved me from reverse-engineering the dedup rule.
2. **Use the Agent SDK's session helpers** instead of parsing JSONL by hand, if I were turning this into a reusable script.
3. **Note the `iterations` field as a Claude Code-specific extension** in any documentation I write — it's not in the public Messages API and could disappear without notice.
4. **Mention the "system-added tokens" caveat** when reporting absolute numbers — the JSONL total is "what the model processed," which is a small overestimate of "what you'd be billed for."
