# The plugin-dev Plugin

 A plugin available from the official Claude Code marketplace.

📍 Lives at:

- Locally: `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/plugin-dev/`
- GitHub: <https://github.com/anthropics/claude-plugins-official/tree/main/plugins/plugin-dev>

Plugins are updated continuously, this document was created on 2026-03-29.

## Plugin Structure Overview

| Component | Path | Count |
|:--|:--|:--|
| **Manifest** | `.claude-plugin/plugin.json` | 1 |
| **Commands** | `commands/create-plugin.md` | 1 |
| **Agents** | `agents/` | 3 (`agent-creator.md`, `plugin-validator.md`, `skill-reviewer.md`) |
| **Skills** | `skills/` | 7 skills (`agent-development`, `command-development`, `hook-development`, `mcp-integration`, `plugin-settings`, `plugin-structure`, `skill-development`) |

60 files total (~772 KB).

---

## 📚 Agents vs Skills

Both agents and skills are plugin components defined as `.md` files — but they serve fundamentally different roles. **Agents do work** (they're autonomous subprocesses Claude spawns to complete a task independently). **Skills teach knowledge** (they inject specialised context so Claude can do the work itself, better).

### How they differ

| | 🤖 **Agents** | 📚 **Skills** |
|:--|:--|:--|
| **What they are** | Autonomous subprocesses with their own model and tools | Knowledge modules loaded into Claude's context |
| **Analogy** | A specialist worker Claude delegates to | An on-demand cheat sheet Claude reads before helping you |
| **How they activate** | Claude spawns one when it matches a scenario | Claude loads one when it detects you're in that domain |
| **What they produce** | A result (report, generated file, validation output) | Nothing directly — they make Claude smarter for the task |
| **Run independently?** | Yes — separate model, tools, system prompt | No — they enrich the main conversation |
| **File format** | `agents/*.md` with YAML frontmatter + system prompt | `skills/*/SKILL.md` with YAML frontmatter + instructions |
| **In this plugin** | 3 agents | 7 skills |

### The 3 Agents

| # | Agent | Model | Tools | One-liner |
|:-:|:--|:--|:--|:--|
| 1 | [Agent Creator](#agent-1-agent-creator) | sonnet | `Read`, `Write` | A factory that **builds other agents** from a plain-English description |
| 2 | [Plugin Validator](#agent-2-plugin-validator) | inherit | `Read`, `Grep`, `Glob`, `Bash` | A **linter for your entire plugin** — structure, manifest, security |
| 3 | [Skill Reviewer](#agent-3-skill-reviewer) | inherit | `Read`, `Grep`, `Glob` | A **quality reviewer for skills** — triggers, content, organisation |

### The 7 Skills

| # | Skill | One-liner |
|:-:|:--|:--|
| 1 | [Plugin Structure](#skill-1-plugin-structure) | Directory layout, manifest, naming, auto-discovery |
| 2 | [Command Development](#skill-2-command-development) | Slash commands — frontmatter, arguments, file refs, bash |
| 3 | [Agent Development](#skill-3-agent-development) | Agent files — frontmatter, triggering, system prompts |
| 4 | [Skill Development](#skill-4-skill-development) | Creating skills — the meta-skill for building skills |
| 5 | [Hook Development](#skill-5-hook-development) | Event-driven automation — 9 hook events, matchers, output |
| 6 | [MCP Integration](#skill-6-mcp-integration) | External services via Model Context Protocol servers |
| 7 | [Plugin Settings](#skill-7-plugin-settings) | Per-project config via `.claude/plugin-name.local.md` |

> 💡 **Skills use progressive disclosure** — only metadata (~100 words) is always in context. The full SKILL.md body (~1,500–2,000 words) loads when the skill triggers. Detailed references, examples, and scripts load only when Claude actually needs them.

---

## Agent 1. Agent Creator

> `agents/agent-creator.md` · model: **sonnet** · tools: `Read`, `Write`

### What does it do?

It **writes new agent `.md` files for you**. You describe what you want an agent to do in plain English, and it generates a complete, ready-to-use agent definition — frontmatter, system prompt, triggering examples, and all.

Think of it as a **factory that builds other agents**.

### Why is it useful?

Writing an agent file from scratch means getting a lot of details right: the YAML frontmatter format, a good system prompt, well-crafted triggering examples, choosing the right model/color/tools, etc. This agent handles all of that so you can focus on *what* the agent should do, not *how* to format it.

### How does it work?

When you say something like *"Create an agent that reviews code for security issues"*, it:

1. **Extracts your intent** — figures out the agent's purpose, responsibilities, and success criteria.
2. **Designs an expert persona** — gives the agent a clear identity and domain expertise.
3. **Writes the system prompt** — comprehensive instructions (500–3,000 words) covering the agent's process, quality standards, output format, and edge cases.
4. **Picks configuration** — chooses model (`inherit`/`sonnet`/`haiku`), a color that matches the purpose (e.g. 🔴 red for security, 🟢 green for generation), and the minimal set of tools needed.
5. **Creates the file** — writes `agents/<your-agent-name>.md` directly into your plugin.
6. **Explains what it built** — gives you a summary and suggests how to test it.

---

## Agent 2. Plugin Validator

> `agents/plugin-validator.md` · model: **inherit** · tools: `Read`, `Grep`, `Glob`, `Bash`

### What does it do?

It **checks your entire plugin for correctness** — structure, manifest, commands, agents, skills, hooks, MCP config, and security. It's basically a **linter for your plugin**.

### Why is it useful?

A plugin has many moving parts (JSON manifests, YAML frontmatter, naming conventions, file organisation, security concerns). One typo in `plugin.json` or a missing field in an agent file can silently break things. This agent catches those issues *before* you publish, saving you debugging time.

It also **triggers proactively** — if you just finished creating a plugin or modified `plugin.json`, it will offer to validate without you asking.

### How does it work?

It runs a **10-step validation pipeline**:

| Step | What it checks |
|:--:|:--|
| 1 | 📁 **Plugin root** — `.claude-plugin/plugin.json` exists |
| 2 | 📄 **Manifest** — valid JSON, required `name` field, kebab-case naming, valid optional fields |
| 3 | 🗂️ **Directory structure** — `commands/`, `agents/`, `skills/`, `hooks/` in the right places |
| 4 | ⚡ **Commands** — YAML frontmatter present, `description` field exists, valid `allowed-tools` |
| 5 | 🤖 **Agents** — name format, `<example>` blocks in description, valid model/color, substantial system prompt |
| 6 | 📚 **Skills** — `SKILL.md` exists per skill dir, frontmatter with `name` + `description` |
| 7 | 🪝 **Hooks** — valid JSON, correct event names, proper `matcher` + `hooks` array structure |
| 8 | 🔌 **MCP config** — server types correct, required fields present, `${CLAUDE_PLUGIN_ROOT}` for portability |
| 9 | 📝 **File hygiene** — README exists, no junk files (`.DS_Store`, `node_modules`), LICENSE present |
| 10 | 🔒 **Security** — no hardcoded credentials, HTTPS/WSS for MCP servers, no secrets in examples |

It then produces a **validation report** with issues categorised as Critical / Warning / Positive, plus specific fix suggestions for each problem.

---

## Agent 3. Skill Reviewer

> `agents/skill-reviewer.md` · model: **inherit** · tools: `Read`, `Grep`, `Glob`

### What does it do?

It **reviews the quality of a skill** you've written — focusing on whether the description will trigger correctly, whether the content is well-organised, and whether you're following best practices. Think of it as a **code review, but for skills**.

### Why is it useful?

The most important part of a skill is its **description** — that's what Claude uses to decide *when* to load it. A vague description means the skill never triggers when it should. A bloated `SKILL.md` means Claude wastes context on info it doesn't need yet. This agent catches both problems and gives you concrete fixes.

### How does it work?

It evaluates your skill across **four dimensions**:

**1. 🎯 Description Analysis**

- Does it contain specific trigger phrases users would actually say?
- Is it written in third person (*"This skill should be used when..."*)?
- Is it the right length (50–500 chars)?
- Does it list concrete scenarios, not vague ones?

**2. 📝 Content Quality**

- Word count check — `SKILL.md` body should be 1,000–3,000 words (lean and focused).
- Writing style — should use imperative form (*"To do X, do Y"* not *"You should do X"*).
- Clear sections, logical flow, concrete guidance.

**3. 📂 Progressive Disclosure**

- Is essential info in `SKILL.md` and detailed docs in `references/`?
- Are examples separated into `examples/`?
- Are utility scripts in `scripts/`?
- Does `SKILL.md` point to these resources clearly?

**4. 🐛 Issue Categorisation**

- Groups problems as **Critical** / **Major** / **Minor**.
- Flags anti-patterns (vague triggers, too much content in core file, missing references).
- Gives before/after examples for suggested rewrites.

Final output: a structured review with an overall rating of **Pass** / **Needs Improvement** / **Needs Major Revision**, plus a prioritised list of recommendations.

---

## Skill 1. Plugin Structure

> `skills/plugin-structure/` · The **foundation skill** — start here.

### What is it?

The blueprint for how a Claude Code plugin is organised. It covers the directory layout, the `plugin.json` manifest, naming conventions, auto-discovery rules, and the `${CLAUDE_PLUGIN_ROOT}` variable.

### When does it activate?

When you say things like:

- *"Create a plugin"*, *"Scaffold a plugin"*
- *"Set up plugin.json"*, *"Understand plugin structure"*
- *"How does auto-discovery work?"*

### What does it teach you?

| Topic | Key takeaway |
|:--|:--|
| 📁 **Directory layout** | `.claude-plugin/plugin.json` is the only required file. Components (`commands/`, `agents/`, `skills/`, `hooks/`) go at the root, **not** inside `.claude-plugin/`. |
| 📄 **Manifest (`plugin.json`)** | Only `name` (kebab-case) is required. Add `version`, `description`, `author`, `keywords` as needed. Custom component paths supplement defaults — they don't replace them. |
| 🔍 **Auto-discovery** | Claude scans `commands/*.md`, `agents/*.md`, `skills/*/SKILL.md`, `hooks/hooks.json`, and `.mcp.json` automatically on enable. No registration needed. |
| 🔗 **`${CLAUDE_PLUGIN_ROOT}`** | Use this in hook commands, MCP server args, and script paths. Never hardcode absolute paths. |
| 📛 **Naming** | Everything is kebab-case. Commands: verb-noun (`review-pr`). Agents: role (`code-reviewer`). Skills: topic (`error-handling`). |

### 📦 Bundled resources

| Folder | Files |
|:--|:--|
| `references/` | `manifest-reference.md`, `component-patterns.md` |
| `examples/` | `minimal-plugin.md`, `standard-plugin.md`, `advanced-plugin.md` |

---

## Skill 2. Command Development

> `skills/command-development/` · Everything about **slash commands**.

### What is it?

A guide to creating `/slash-commands` — markdown files with optional YAML frontmatter that become reusable prompts Claude executes. Commands are **instructions FOR Claude**, not messages to the user.

### When does it activate?

When you say things like:

- *"Create a slash command"*, *"Add a command"*
- *"Define command arguments"*, *"Use command frontmatter"*
- *"How do file references work in commands?"*

### What does it teach you?

| Topic | Key takeaway |
|:--|:--|
| 📝 **File format** | A `.md` file in `commands/`. No frontmatter needed for basic commands. Add `---` YAML for `description`, `allowed-tools`, `model`, `argument-hint`. |
| 🎯 **Dynamic arguments** | `$ARGUMENTS` captures everything. `$1`, `$2`, `$3` capture positional args. `argument-hint` documents expected args. |
| 📎 **File references** | `@$1` or `@path/to/file` injects file contents into the prompt before Claude processes it. |
| 🖥️ **Bash execution** | `` !`git diff --name-only` `` runs inline bash to gather dynamic context. Requires `allowed-tools: Bash(...)`. |
| 📂 **Organisation** | Flat for ≤15 commands. Subdirectories for namespacing (e.g., `commands/ci/build.md` → `/build (project:ci)`). |
| 🔌 **Plugin features** | `${CLAUDE_PLUGIN_ROOT}` for portable paths. Commands can invoke agents, leverage skills, and coordinate with hooks. |

### 📦 Bundled resources

| Folder | Files |
|:--|:--|
| `references/` | `frontmatter-reference.md`, `plugin-features-reference.md`, `advanced-workflows.md`, `interactive-commands.md`, `testing-strategies.md`, `documentation-patterns.md`, `marketplace-considerations.md` |
| `examples/` | `simple-commands.md`, `plugin-commands.md` |

---

## Skill 3. Agent Development

> `skills/agent-development/` · How to **build autonomous agents**.

### What is it?

A guide to creating agent `.md` files — autonomous subprocesses that handle complex, multi-step tasks independently. Unlike commands (user-initiated), agents are triggered automatically when Claude detects a matching scenario.

### When does it activate?

When you say things like:

- *"Create an agent"*, *"Add an agent"*
- *"Agent frontmatter"*, *"Agent tools"*, *"Agent colors"*
- *"How do triggering examples work?"*

### What does it teach you?

| Topic | Key takeaway |
|:--|:--|
| 📋 **Frontmatter** | Four required fields: `name` (kebab-case, 3–50 chars), `description` (with `<example>` blocks), `model` (`inherit`/`sonnet`/`opus`/`haiku`), `color` (blue/cyan/green/yellow/magenta/red). Optional: `tools` array. |
| 🎯 **Triggering** | The `description` field is **the most critical part**. Must start with *"Use this agent when..."* and include 2–4 `<example>` blocks showing context → user message → assistant response → commentary. |
| 🧠 **System prompt** | The markdown body below frontmatter. Write in 2nd person (*"You are..."*). Structure: role → responsibilities → step-by-step process → quality standards → output format → edge cases. Target 500–3,000 words (note: `agent-development/SKILL.md` incorrectly says "characters" — should be "words"). |
| 🎨 **Color meaning** | 🔵/🔵 Analysis/review · 🟢 Generation/creation · 🟡 Validation/caution · 🔴 Security/critical · 🟣 Creative/transformation |
| 🔧 **Tool restriction** | Omit `tools` for full access. Provide an array for least-privilege (e.g., `["Read", "Grep", "Glob"]` for read-only analysis). |

### 📦 Bundled resources

| Folder | Files |
|:--|:--|
| `references/` | `agent-creation-system-prompt.md`, `system-prompt-design.md`, `triggering-examples.md` |
| `examples/` | `agent-creation-prompt.md`, `complete-agent-examples.md` |
| `scripts/` | `validate-agent.sh` |

---

## Skill 4. Skill Development

> `skills/skill-development/` · How to **create new skills** (this is the meta-skill!).

### What is it?

A guide to building skills themselves — the modular knowledge packages that extend Claude's capabilities. It covers the full lifecycle: understanding use cases → planning resources → creating the structure → writing SKILL.md → validating → iterating.

### When does it activate?

When you say things like:

- *"Create a skill"*, *"Add a skill to my plugin"*
- *"Improve skill description"*, *"Organise skill content"*
- *"How does progressive disclosure work?"*

### What does it teach you?

| Topic | Key takeaway |
|:--|:--|
| 🧩 **Anatomy** | `SKILL.md` (required) with YAML frontmatter (`name` + `description`). Optional: `scripts/`, `references/`, `assets/`. |
| 📐 **Progressive disclosure** | Core essentials in SKILL.md (1,500–2,000 words). Detailed docs in `references/`. Working code in `examples/`. Utilities in `scripts/`. |
| ✍️ **Writing style** | Imperative/infinitive form (*"To do X, do Y"*), **not** 2nd person (*"You should..."*). Description in 3rd person (*"This skill should be used when..."*). |
| 🎯 **Description quality** | Include specific trigger phrases users would say. Be concrete (*"create a hook", "add a PreToolUse hook"*), not vague (*"hook guidance"*). |
| 🔄 **6-step process** | 1️⃣ Understand use cases → 2️⃣ Plan resources → 3️⃣ Create structure → 4️⃣ Write SKILL.md + resources → 5️⃣ Validate & test → 6️⃣ Iterate |
| ⚠️ **Common mistakes** | Weak trigger descriptions · Too much in SKILL.md (>3k words) · 2nd person writing · Missing resource references |

### 📦 Bundled resources

| Folder | Files |
|:--|:--|
| `references/` | `skill-creator-original.md` (the full original skill-creator methodology) |

> **Note:** This skill only bundles `references/`. Skill subdirectories are free-form — common ones include `examples/`, `scripts/`, and `assets/`, but you can add any directory you like. See [Hook Development](#skill-5-hook-development) or [Plugin Settings](#skill-7-plugin-settings) for skills that use all three.

---

## Skill 5. Hook Development

> `skills/hook-development/` · **Event-driven automation** that reacts to Claude's lifecycle.

### What is it?

A guide to creating hooks — scripts or prompts that fire automatically in response to Claude Code events (before a tool runs, when a session starts, when the agent is about to stop, etc.). Hooks can approve, deny, modify, or enrich Claude's behaviour.

### When does it activate?

When you say things like:

- *"Create a hook"*, *"Add a PreToolUse hook"*
- *"Block dangerous commands"*, *"Validate tool use"*
- *"Set up event-driven automation"*
- Or mention any event name: `PreToolUse`, `PostToolUse`, `Stop`, `SessionStart`, etc.

### What does it teach you?

| Topic | Key takeaway |
|:--|:--|
| 🔀 **Two hook types** | **Prompt-based** (recommended) — LLM-driven, context-aware, flexible. **Command** — bash scripts, deterministic, fast. |
| 📡 **9 events** | `PreToolUse` · `PostToolUse` · `Stop` · `SubagentStop` · `UserPromptSubmit` · `SessionStart` · `SessionEnd` · `PreCompact` · `Notification` |
| 🎯 **Matchers** | Exact (`"Write"`), multi (`"Read\|Write\|Edit"`), wildcard (`"*"`), regex (`"mcp__.*__delete.*"`). Case-sensitive. |
| 📤 **Output format** | JSON with `continue`, `suppressOutput`, `systemMessage`. PreToolUse adds `permissionDecision` (`allow`/`deny`/`ask`). Exit code `2` = blocking error. |
| 📥 **Input format** | JSON via stdin: `session_id`, `cwd`, `hook_event_name`, plus event-specific fields (`tool_name`, `tool_input`, `user_prompt`, etc.). |
| 🔧 **Plugin format** | `hooks/hooks.json` uses a wrapper: `{ "hooks": { "PreToolUse": [...] } }`. Settings format is direct (no wrapper). |
| ⚡ **Parallel execution** | All matching hooks run in parallel — design for independence. |
| 🔄 **Restart required** | Hooks load at session start. Changes need a Claude Code restart. |

### 📦 Bundled resources

| Folder | Files |
|:--|:--|
| `references/` | `patterns.md` (8+ proven patterns), `advanced.md`, `migration.md` |
| `examples/` | `validate-write.sh`, `validate-bash.sh`, `load-context.sh` |
| `scripts/` | `validate-hook-schema.sh`, `test-hook.sh`, `hook-linter.sh` |

---

## Skill 6. MCP Integration

> `skills/mcp-integration/` · Connecting Claude to **external services via Model Context Protocol**.

### What is it?

A guide to bundling MCP (Model Context Protocol) servers with your plugin so Claude gains access to external tools — databases, APIs, cloud services — as if they were native tools.

### When does it activate?

When you say things like:

- *"Add MCP server"*, *"Integrate MCP"*, *"Configure MCP in plugin"*
- *"Use .mcp.json"*, *"Set up Model Context Protocol"*
- Or mention server types: *"SSE"*, *"stdio"*, *"HTTP"*, *"WebSocket"*

### What does it teach you?

| Topic | Key takeaway |
|:--|:--|
| 📋 **Two config methods** | `.mcp.json` at plugin root (recommended, cleaner) **or** inline `mcpServers` in `plugin.json` (simpler for single server). |
| 🔌 **4 server types** | **stdio** (local process, env-var auth) · **SSE** (hosted cloud, OAuth) · **HTTP** (REST, token auth) · **WebSocket** (real-time, token auth) |
| 🏷️ **Tool naming** | Auto-prefixed: `mcp__plugin_<plugin>_<server>__<tool>`. Pre-allow specific tools in commands, avoid wildcards. |
| 🔐 **Auth patterns** | OAuth (automatic for SSE/HTTP) · Token via `headers` + env vars · Env vars passed to stdio via `env` field. Never hardcode secrets. |
| 🔄 **Lifecycle** | MCP servers start when plugin enables → tools discovered → available as `mcp__...` → connection on first use → shutdown on exit. |
| 🛡️ **Security** | Always HTTPS/WSS. Use env vars for tokens. Pre-allow specific tools, not wildcards. Document required env vars in README. |

### 📦 Bundled resources

| Folder | Files |
|:--|:--|
| `references/` | `server-types.md`, `authentication.md`, `tool-usage.md` |
| `examples/` | `stdio-server.json`, `sse-server.json`, `http-server.json` |

---

## Skill 7. Plugin Settings

> `skills/plugin-settings/` · Storing **per-project, user-configurable** plugin state.

### What is it?

A pattern for giving your plugin persistent, per-project configuration using `.claude/plugin-name.local.md` files. These files combine YAML frontmatter (structured settings) with a markdown body (free-form context like task descriptions or prompts). They're user-local, gitignored, and read by hooks/commands/agents.

### When does it activate?

When you say things like:

- *"Plugin settings"*, *"Store plugin configuration"*
- *".local.md files"*, *"Per-project plugin settings"*
- *"Read YAML frontmatter"*, *"Make plugin configurable"*

### What does it teach you?

| Topic | Key takeaway |
|:--|:--|
| 📍 **File location** | `.claude/plugin-name.local.md` in the project root. Must be in `.gitignore`. |
| 📐 **File structure** | YAML frontmatter between `---` markers (structured key-value settings) + markdown body below (free-form content). |
| 🔍 **Parsing** | `sed` to extract frontmatter, `grep` + `sed` to read individual fields, `awk` to extract the body. Full parsing scripts provided. |
| 🎛️ **Common patterns** | *Temporarily active hooks* (check `enabled: true` flag) · *Agent state management* (store task, coordinator, dependencies) · *Configuration-driven behaviour* (validation level, allowed extensions, etc.) |
| 🔄 **Restart required** | Like hooks, settings changes need a Claude Code restart to take effect. |
| 🛡️ **Security** | Sanitise user input, validate file paths (no `..`), set `chmod 600`, never commit to git. |
| 🌍 **Real-world examples** | `multi-agent-swarm` (agent coordination with task assignments) · `ralph-loop` (iteration counter with completion promise) |

### 📦 Bundled resources

| Folder | Files |
|:--|:--|
| `references/` | `parsing-techniques.md`, `real-world-examples.md` |
| `examples/` | `read-settings-hook.sh`, `create-settings-command.md`, `example-settings.md` |
| `scripts/` | `validate-settings.sh`, `parse-frontmatter.sh` |
