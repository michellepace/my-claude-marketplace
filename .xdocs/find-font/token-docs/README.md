# Readme - Reference Docs In this Dir

Curated by Claude Code when counting tokens.

| No. | Anthropic Doc | Why it would have been useful (desc) |
| :--- | :--- | :--- |
| 1 | [cost-tracking.md](cost-tracking.md) | **The single doc I should have read first.** Officially documents the dedup-by-ID rule, defines "step" (= my "turn"), and confirms `cache_creation_input_tokens` / `cache_read_input_tokens` are tracked alongside `input_tokens` not added to it. Validates everything. |
| 2 | [sessions.md](sessions.md) | Exposes `listSessions()` / `getSessionMessages()` (TS) and `list_sessions()` / `get_session_messages()` (Py). I parsed JSONL by hand; there's an SDK helper. For a future reusable tool I should use this instead of raw file parsing. |
| 3 | [streaming.md](streaming.md) | Documents that `message_start` carries the initial usage and `message_delta` carries updates — explains *why* the JSONL stores duplicate assistant lines per request: each content block (`thinking`, `tool_use`, `text`) emits its own start/stop event, and Claude Code persists each one separately while they all share the same parent message ID. |
| 4 | [prompt-caching.md](prompt-caching.md) | Defines the token-breakdown formula `total_input_tokens = cache_read_input_tokens + cache_creation_input_tokens + input_tokens` and the critical caveat that `input_tokens` is **only** tokens after the last cache breakpoint, not the full input. Without this, summing the JSONL fields naively would double-count or undercount. Also documents cache pricing multipliers (writes 1.25×, reads 0.1× of base input) needed for any cost calculation. |
| 5 | [token-counting.md](token-counting.md) | Important caveat: "Token counts may include tokens added automatically by Anthropic for system optimizations. **You are not billed for system-added tokens.**" Means raw JSONL totals could be slightly higher than what you actually pay. Doesn't change the comparative analysis though. |
| 6 | [statusline.md](statusline.md) | Documents how custom statuslines receive session data on stdin — the structured shape might mirror the JSONL fields. Could be a cleaner schema reference than what I reverse-engineered. |
| 7 | [context-window.md](context-window.md) | Background on how Claude Code packs the context window — useful for understanding what `/context` includes (system prompt, tools, memory, skills, messages) and why the breakdown gap exists. |
| 8 | [pricing.md](pricing.md) | Per-model $/MTok rates needed to convert token counts into actual dollar costs. Confirms the cache multipliers used by `prompt-caching.md` (5m write 1.25×, 1h write 2×, read 0.1×), documents the Opus 4.7 tokenizer caveat (up to 35% more tokens for the same text vs older models — affects cross-model comparisons), and notes the data-residency 1.1× and Fast mode 6× multipliers that can apply on top. Also flags that `tools` adds ~346 system-prompt tokens per call — relevant when reconciling JSONL totals against `/context`. |

[`z_token-convo.md`](z_token-convo.md) — my own rough notes from a Claude conversation walking through what each token field means. Kept here for convenience; not part of the curated set above.
