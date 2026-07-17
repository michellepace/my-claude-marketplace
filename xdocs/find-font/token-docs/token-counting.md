---
title: Token counting
source:
  scraped_url: https://platform.claude.com/docs/en/build-with-claude/token-counting.md
  canonical_url: https://platform.claude.com/docs/en/build-with-claude/token-counting
  scraped_date: 2026-04-28
---

Token counting enables you to determine the number of tokens in a message before sending it to Claude, helping you make informed decisions about your prompts and usage. With token counting, you can
- Proactively manage rate limits and costs
- Make smart model routing decisions
- Optimize prompts to be a specific length

<Note>
This feature is eligible for [Zero Data Retention (ZDR)](/docs/en/build-with-claude/api-and-data-retention). When your organization has a ZDR arrangement, data sent through this feature is not stored after the API response is returned.
</Note>

---

## How to count message tokens

The [token counting](/docs/en/api/messages-count-tokens) endpoint accepts the same structured list of inputs for creating a message, including support for system prompts, [tools](/docs/en/agents-and-tools/tool-use/overview), [images](/docs/en/build-with-claude/vision), and [PDFs](/docs/en/build-with-claude/pdf-support). The response contains the total number of input tokens.

<Note>
The token count should be considered an **estimate**. In some cases, the actual number of input tokens used when creating a message may differ by a small amount.

Token counts may include tokens added automatically by Anthropic for system optimizations. **You are not billed for system-added tokens**. Billing reflects only your content.
</Note>

### Supported models

All [active models](/docs/en/about-claude/models/overview) support token counting.

### Count tokens in basic messages

<CodeGroup>

```bash CLI
ant messages count-tokens \
  --model claude-opus-4-7 \
  --system "You are a scientist" \
  --message '{role: user, content: "Hello, Claude"}'
```

```python Python hidelines={1..2}
import anthropic

client = anthropic.Anthropic()

response = client.messages.count_tokens(
    model="claude-opus-4-7",
    system="You are a scientist",
    messages=[{"role": "user", "content": "Hello, Claude"}],
)

print(response.json())
```
</CodeGroup>

```json Output
{ "input_tokens": 14 }
```

### Count tokens in messages with tools

<Note>
[Server tool](/docs/en/agents-and-tools/tool-use/server-tools) token counts only apply to the first sampling call.
</Note>

<CodeGroup>

```bash CLI
ant messages count-tokens <<'YAML'
model: claude-opus-4-7
tools:
  - name: get_weather
    description: Get the current weather in a given location
    input_schema:
      type: object
      properties:
        location:
          type: string
          description: The city and state, e.g. San Francisco, CA
      required:
        - location
messages:
  - role: user
    content: What's the weather like in San Francisco?
YAML
```

```python Python hidelines={1..2}
import anthropic

client = anthropic.Anthropic()

response = client.messages.count_tokens(
    model="claude-opus-4-7",
    tools=[
        {
            "name": "get_weather",
            "description": "Get the current weather in a given location",
            "input_schema": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "The city and state, e.g. San Francisco, CA",
                    }
                },
                "required": ["location"],
            },
        }
    ],
    messages=[{"role": "user", "content": "What's the weather like in San Francisco?"}],
)

print(response.json())
```
</CodeGroup>

```json Output
{ "input_tokens": 403 }
```

### Count tokens in messages with images

<CodeGroup>

```bash
IMAGE_URL="https://upload.wikimedia.org/wikipedia/commons/a/a7/Camponotus_flavomarginatus_ant.jpg"
curl -s "$IMAGE_URL" -o ./ant.jpg

ant messages count-tokens <<'YAML'
model: claude-opus-4-7
messages:
- role: user
    content:
  - type: image
        source:
          type: base64
          media_type: image/jpeg
          data: "@./ant.jpg"
  - type: text
        text: Describe this image
YAML
```

```python Python nocheck hidelines={1}
import anthropic
import base64
import httpx

image_url = "https://upload.wikimedia.org/wikipedia/commons/a/a7/Camponotus_flavomarginatus_ant.jpg"
image_media_type = "image/jpeg"
image_data = base64.standard_b64encode(httpx.get(image_url).content).decode("utf-8")

client = anthropic.Anthropic()

response = client.messages.count_tokens(
    model="claude-opus-4-7",
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": image_media_type,
                        "data": image_data,
                    },
                },
                {"type": "text", "text": "Describe this image"},
            ],
        }
    ],
)
print(response.json())
```
</CodeGroup>

```json Output
{ "input_tokens": 1551 }
```

### Count tokens in messages with extended thinking

<Note>
See [how the context window is calculated with extended thinking](/docs/en/build-with-claude/extended-thinking#how-context-window-is-calculated-with-extended-thinking) for more details
- Thinking blocks from **previous** assistant turns are ignored and **do not** count toward your input tokens
- **Current** assistant turn thinking **does** count toward your input tokens
</Note>

<CodeGroup>

```bash CLI nocheck
ant messages count-tokens <<'YAML'
model: claude-sonnet-4-6
thinking:
  type: enabled
  budget_tokens: 16000
messages:
  - role: user
    content: Are there an infinite number of prime numbers such that n mod 4 == 3?
  - role: assistant
    content:
      - type: thinking
        thinking: >-
          This is a nice number theory question. Lets think about it step by step...
        signature: >-
          EuYBCkQYAiJAgCs1le6/Pol5Z4/JMomVOouGrWdhYNsH3ukzUECbB6iWrSQtsQuRHJID6lWV...
      - type: text
        text: Yes, there are infinitely many prime numbers p such that p mod 4 = 3...
  - role: user
    content: Can you write a formal proof?
YAML
```

```python Python nocheck hidelines={1..2}
import anthropic

client = anthropic.Anthropic()

response = client.messages.count_tokens(
    model="claude-sonnet-4-6",
    thinking={"type": "enabled", "budget_tokens": 16000},
    messages=[
        {
            "role": "user",
            "content": "Are there an infinite number of prime numbers such that n mod 4 == 3?",
        },
        {
            "role": "assistant",
            "content": [
                {
                    "type": "thinking",
                    "thinking": "This is a nice number theory question. Let's think about it step by step...",
                    "signature": "EuYBCkQYAiJAgCs1le6/Pol5Z4/JMomVOouGrWdhYNsH3ukzUECbB6iWrSQtsQuRHJID6lWV...",
                },
                {
                    "type": "text",
                    "text": "Yes, there are infinitely many prime numbers p such that p mod 4 = 3...",
                },
            ],
        },
        {"role": "user", "content": "Can you write a formal proof?"},
    ],
)

print(response.json())
```
</CodeGroup>

```json Output
{ "input_tokens": 88 }
```

### Count tokens in messages with PDFs

<Note>
Token counting supports PDFs with the same [limitations](/docs/en/build-with-claude/pdf-support#pdf-support-limitations) as the Messages API.
</Note>

<CodeGroup>

```bash
PDF_URL="https://assets.anthropic.com/m/1cd9d098ac3e6467/original/Claude-3-Model-Card-October-Addendum.pdf"
curl -s "$PDF_URL" -o document.pdf

ant messages count-tokens <<'YAML'
model: claude-opus-4-7
messages:
  - role: user
    content:
      - type: document
        source:
          type: base64
          media_type: application/pdf
          data: "@./document.pdf"
      - type: text
        text: Please summarize this document.
YAML
```

```python
import base64
import anthropic

client = anthropic.Anthropic()

with open("document.pdf", "rb") as pdf_file:
    pdf_base64 = base64.standard_b64encode(pdf_file.read()).decode("utf-8")

response = client.messages.count_tokens(
    model="claude-opus-4-7",
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "document",
                    "source": {
                        "type": "base64",
                        "media_type": "application/pdf",
                        "data": pdf_base64,
                    },
                },
                {"type": "text", "text": "Please summarize this document."},
            ],
        }
    ],
)

print(response.json())
```

</CodeGroup>

```json Output
{ "input_tokens": 2188 }
```

---

## Pricing and rate limits

Token counting is **free to use** but subject to requests per minute rate limits based on your [usage tier](/docs/en/api/rate-limits#rate-limits). If you need higher limits, contact sales through the [Claude Console](/settings/limits).

| Usage tier | Requests per minute (RPM) |
| ------------ | --------------------------- |
| 1 | 100 |
| 2 | 2,000 |
| 3 | 4,000 |
| 4 | 8,000 |

<Note>
  Token counting and message creation have separate and independent rate limits. Usage of one does not count against the limits of the other.
</Note>

---

## FAQ

<section title="Does token counting use prompt caching?">

No, token counting provides an estimate without using caching logic. While you may provide `cache_control` blocks in your token counting request, prompt caching only occurs during actual message creation.

</section>
