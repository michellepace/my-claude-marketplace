# Evaluation Strategy for find-font

## Clarifying the tooling confusion

### What each plugin actually evaluates

| | **plugin-dev** | **skill-creator** |
|:--|:--|:--|
| **Nature** | Static review — checks structure, formatting, best practices | Functional testing — runs the skill and measures whether it works |
| **Evaluates** | Does the plugin follow conventions? Are skills well-written? | Does the skill produce correct output? Can it be improved? |
| **Scope** | Whole plugin (manifest, directory structure, all components) + individual skill quality | One skill at a time (test cases, assertions, benchmarking) |
| **Architecture advice** | No — validates structure, not design decisions | No — improves a skill's content, not whether it should exist |

They are **complementary, not overlapping**:

- `plugin-dev` is the **linter** — tells you if your code follows the style guide
- `skill-creator` is the **test suite** — tells you if your code actually works

Neither evaluates whether your overall architecture is sound (e.g., "should this be an agent instead of a skill?"). That requires manual reasoning, addressed below.

### Which agents and skills to use

| Tool | What to use it for | When |
|:--|:--|:--|
| **plugin-dev: plugin-validator** (agent) | Structural check of the whole plugin — manifest, directories, naming, MCP config, security | First. Catches format/config issues before anything else. |
| **plugin-dev: skill-reviewer** (agent) | Quality review of each SKILL.md — description triggers, writing style, progressive disclosure, content organisation | Second. Reviews each skill individually for best-practice compliance. |
| **skill-creator** (skill) | Functional testing — run each skill on real prompts, grade outputs, iterate | Third, selectively. Only for skills where you want to verify correctness, not just formatting. |
| **plugin-dev: agent-creator** (agent) | Not relevant here | N/A |

### Description optimization

Out of scope per your note. The `skill-creator` description optimization pipeline (`run_loop.py`, `run_eval.py`) and the `skill-reviewer`'s description analysis are both skipped.

---

## Architectural review (manual)

Neither plugin answers "is the overall approach valid?" — so this needs to happen first, by reasoning about the design.

### Is the skill-only approach correct?

**Yes, skills are the right choice for this plugin.** Here's the reasoning:

The plugin-dev documentation defines the distinction clearly:

- **Agents** = autonomous subprocesses that Claude spawns automatically when it detects a matching scenario. They run independently with their own model/tools and return a result.
- **Skills** = knowledge modules loaded into Claude's context. They teach Claude how to do something; Claude does the work itself.

Your workers (`ff-1-curate-font-google`, `ff-2-classify-font-matrix`, `ff-3-create-font-matrix-svg`) are explicitly orchestrated by `ff-0-pair-my-font` — the orchestrator decides *which* fonts to curate and classify based on user input. Auto-triggering (the defining feature of agents) would be wrong here because:

- You don't want `ff-1-curate-font-google` firing every time someone mentions a font name
- You don't want `ff-2-classify-font-matrix` running without the orchestrator having confirmed the brief
- The orchestrator needs to control the sequence and parallelism

Additionally, skills can be invoked standalone by the user (e.g., just curate a font without the full pairing workflow), which is a useful bonus.

**One thing to consider**: the workers are used as instructions for subagents spawned via the `Agent` tool. This is a valid pattern — the orchestrator skill tells Claude to spawn subagents using `Agent`, and those subagents follow the worker skill instructions. This is different from plugin-level agents (which have their own YAML frontmatter and auto-trigger). Your approach is fine.

### What to watch for architecturally

| Question | Status |
|:--|:--|
| Should any skill be an agent? | No — orchestrated workers shouldn't auto-trigger |
| Is the orchestrator-worker split logical? | Yes — each worker has a single clear responsibility |
| Are responsibilities cleanly separated? | Check — `ff-1-curate-font-google` and `ff-2-classify-font-matrix` both write to the same font profile files. Verify they don't conflict. |
| Is MCP as hard dependency acceptable? | Yes for ff-1-curate-font-google (Google Fonts is JS SPA, can't WebFetch). The plugin should degrade gracefully if MCP is unavailable for the other skills. |
| Is `font-profiles/` at plugin root correct? | Worth checking — plugin-dev conventions suggest data could live inside a skill directory. But shared data used by multiple skills at plugin root is reasonable. |

---

## Recommended evaluation sequence

### Phase 1: Structural validation (plugin-dev: plugin-validator)

Run the plugin-validator agent against the whole plugin. This checks:

- `plugin.json` manifest (valid JSON, required fields, kebab-case)
- Directory structure conventions
- SKILL.md frontmatter in all 4 skills
- `.mcp.json` configuration (server types, HTTPS, no hardcoded secrets)
- File hygiene (README, no junk files)

**How**: Ask Claude to validate the plugin. The `plugin-validator` agent triggers automatically when you mention validation, or you can be explicit:

> *"Validate my plugin at plugins/find-font"*

**Expected output**: A report with Critical / Warning / Positive items. Fix any Critical issues before proceeding.

### Phase 2: Skill quality review (plugin-dev: skill-reviewer)

Run the skill-reviewer agent on each of the 4 skills. This evaluates:

- Description quality (trigger phrases, specificity, length)
- Content quality (word count, writing style, organisation)
- Progressive disclosure (is the right content in SKILL.md vs references?)
- Anti-patterns (vague triggers, too much in core file, missing references)

**How**: Ask Claude to review each skill. Do them one at a time so you can discuss findings:

> *"Review the skill at plugins/find-font/skills/ff-1-curate-font-google"*

Repeat for `ff-2-classify-font-matrix`, `ff-3-create-font-matrix-svg`, and `ff-0-pair-my-font`.

**Expected output**: A structured review per skill with Pass / Needs Improvement / Needs Major Revision, plus prioritised recommendations.

**Note on description feedback**: The skill-reviewer will comment on description quality (trigger phrases, etc.). Since you invoke manually and don't need auto-triggering, you can acknowledge but deprioritise these suggestions. Focus on content quality and organisation feedback.

### Phase 3: Functional testing (skill-creator — selective)

This is the heaviest step. Use it only for skills where you want to verify *correctness*, not just formatting. The most valuable candidates:

| Skill | Worth functional testing? | Why |
|:--|:--|:--|
| **ff-1-curate-font-google** | Yes | It fetches live data via MCP and writes structured profiles. You want to verify output completeness and format. |
| **ff-2-classify-font-matrix** | Yes | It makes subjective classification judgments. You want to verify the Kupferschmid framework is applied correctly. |
| **ff-0-pair-my-font** | Maybe | The orchestrator's value depends on its workers. Test the workers first, then test the orchestrator if you want to verify the end-to-end pairing recommendations. |
| **ff-3-create-font-matrix-svg** | Low priority | SVG generation is more visual — harder to write assertions for. Manual inspection may be more practical. |

**How**: Invoke the skill-creator workflow:

> *"I have an existing skill at plugins/find-font/skills/ff-1-curate-font-google that I want to evaluate and improve"*

The skill-creator will guide you through: writing test prompts -> running evals -> grading -> reviewing in the viewer -> iterating.

**What you'll get**: Quantitative benchmarks (pass rates, timing, tokens) and qualitative review via the HTML viewer. This tells you whether the skill actually produces correct output, not just whether it's well-formatted.

### Phase 4: Apply improvements and re-validate

After making changes based on Phases 1-3:

1. Re-run plugin-validator to confirm structural fixes
2. Re-run skill-reviewer on any modified skills
3. If you did functional testing, re-run those evals to confirm improvements

---

## Summary: the order and why

```
Phase 1: plugin-validator     Catch structural issues first (fast, cheap)
    |
Phase 2: skill-reviewer x4   Review each skill's quality (medium effort)
    |
Phase 3: skill-creator        Functional testing of key skills (high effort, selective)
    |
Phase 4: re-validate          Confirm fixes didn't break anything
```

Start broad (whole plugin structure), narrow down (individual skill quality), then go deep (functional correctness) only where it matters most. This avoids wasting effort on functional testing of skills that have structural problems, and avoids the overhead of the full skill-creator pipeline for skills where a quality review is sufficient.
