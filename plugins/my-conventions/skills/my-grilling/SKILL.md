---
name: my-grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
argument-hint: '[the decision/plan/idea to grill]'
user-invocable: true
disable-model-invocation: true
disallowed-tools: AskUserQuestion
---

Interview me relentlessly about every aspect of this until we reach a shared understanding. Walk down each branch of the decision tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing. Asking multiple questions at once is bewildering.

If a *fact* can be found by exploring the environment (filesystem, tools, etc.), look it up rather than asking me. The *decisions*, though, are mine — put each one to me and wait for my answer.

Do not act on it until I confirm we have reached a shared understanding.

**Question format & style:** Ask in your normal TUI reply, not the `AskUserQuestion` tool. This makes it easier for me to scroll back. Format that reply however you like e.g. emojis etc. Use short sentences, plainly worded, clear but concise.
