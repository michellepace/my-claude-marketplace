# Token Usage & Cost by Conversation Session

*Session shape — counts and peak.*

| Metric | session_1 | session_2 | session_3 | $/MToK |
| :----- | -------: | -------: | -------: | -------: |
| User messages | 3 | 3 | 2 | |
| Turns (API calls) | 28 | 10 | 27 | |
| Peak Context (used c.window) | 53,992 | 65,056 | 67,316 | |

*Total Tokens via API (not session size)*

| Metric | session_1 | session_2 | session_3 | $/MToK |
| :----- | -------: | -------: | -------: | -------: |
| input_tokens (uncached) | 48 | 35 | 42 | $5.00 |
| cache_creation_input_tokens | 82,689 | 95,751 | 119,554 | $6.25 |
| cache_read_input_tokens | 934,323 | 331,654 | 1,034,343 | $0.50 |
| output_tokens | 17,820 | 27,871 | 20,865 | $25.00 |
| **Total session tokens** | **1,034,880** | **455,311** | **1,174,804** | *Opus* |
| **Total session cost** | **$1.43** | **$1.46** | **$1.79** | 💵 |

**Peak Context** = for each turn, add its three input buckets (**input_tokens** + **cache_creation_input_tokens** + **cache_read_input_tokens**); Peak CTX is the largest such per-turn sum. It's the used context window.

**Why output_tokens isn't in Peak CTX:** each turn's output becomes the next turn's input (first **cache_creation**, then **cache_read**), so it's already counted there. The last turn's output is the exception — but it never sat in the window either.

```text
Opus 4.6 Pricing: Input tokens $5/MTok, Output tokens $25/MTok
 
prompt_1:
- input: 48 × $5 = $0.000240 
- cache_creation: 82,689 × $6.25 = $0.5168 
- cache_read: 934,323 × $0.50 = $0.4672
- output: 17,820 × $25 = $0.4455 
- Total: $1.43 
prompt_2:
- input: 35 × $5 = $0.000175 
- cache_creation: 95,751 × $6.25 = $0.5984 
- cache_read: 331,654 × $0.50 = $0.1658
- output: 27,871 × $25 = $0.6968 
- Total: $1.46 
prompt_3:
- input: 42 × $5 = $0.000210 
- cache_creation: 119,554 × $6.25 = $0.7472
- cache_read: 1,034,343 × $0.50 = $0.5172
- output: 20,865 × $25 = $0.5216 
- Total: $1.79 
```
