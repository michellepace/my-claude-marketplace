# The skill-creator Plugin

A plugin available from the official Claude Code marketplace.

Lives at:

- Locally: `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/skill-creator/`
- GitHub: <https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator>

Plugins are updated continuously, this document was created on 2026-03-29.

## Plugin Structure Overview

| Component | Path | Count |
|:--|:--|:--|
| **Manifest** | `.claude-plugin/plugin.json` | 1 |
| **Commands** | — | 0 |
| **Agents** | — | 0 |
| **Skills** | `skills/skill-creator/` | 1 |
| **Hooks** | — | 0 |

~21 files total (~300 KB).

This plugin is structurally very different from `plugin-dev`. Where `plugin-dev` has 3 plugin-level agents + 7 skills, `skill-creator` is **one skill** with a rich set of bundled resources (Python scripts, subagent reference docs, HTML viewers) packed inside it.

---

## What does this plugin do?

It's a **skill creation and evaluation framework**. It guides you through a full lifecycle:

1. **Create** a skill — interview, research, write SKILL.md + test cases
2. **Test** the skill — spawn parallel subagent runs (with-skill + baseline)
3. **Evaluate** results — grade assertions, aggregate benchmarks, review in an interactive HTML viewer
4. **Iterate** — improve based on user feedback, rerun, repeat
5. **Optimize the description** — automated trigger eval loop with train/test split to avoid overfitting

The core loop is: **draft -> test -> evaluate -> improve -> repeat**.

---

## The Skill: skill-creator

> `skills/skill-creator/SKILL.md` · 480 lines, ~32 KB

### When does it activate?

When you say things like:

- *"Create a skill"*, *"Make a skill for X"*
- *"Run evals"*, *"Test my skill"*, *"Benchmark skill performance"*
- *"Improve skill description"*, *"Optimize triggering"*
- *"Update an existing skill"*, *"Iterate on this skill"*

### What does it teach Claude?

The SKILL.md is a comprehensive guide organised into these sections:

| Section | What it covers |
|:--|:--|
| **Communicating with users** | Adapt language to user's technical level — explain terms like "assertion" and "JSON" when cues suggest unfamiliarity |
| **Creating a skill** | 4-step process: Capture Intent -> Interview & Research -> Write SKILL.md -> Write Test Cases |
| **Running and evaluating test cases** | 5-step pipeline (detailed below) |
| **Improving the skill** | Philosophy: generalise from feedback, keep prompts lean, explain the "why", bundle repeated work into scripts |
| **Blind comparison** | Optional rigorous A/B testing via the comparator subagent |
| **Description optimization** | Automated loop to improve trigger accuracy (detailed below) |
| **Claude.ai-specific instructions** | Adaptations for no-subagent environments (inline execution, skip baselines, no browser viewer) |
| **Cowork-specific instructions** | Use `--static` for HTML output, feedback downloads as file |

### Skill writing guidance embedded in the skill

The skill also teaches Claude **how to write good skills** (since its job is to create them):

| Topic | Key takeaway |
|:--|:--|
| **Anatomy** | `SKILL.md` (required) + optional `scripts/`, `references/`, `assets/` |
| **Progressive disclosure** | 3 levels: metadata (~100 words, always loaded) -> SKILL.md body (<500 lines) -> bundled resources (as needed) |
| **Writing style** | Imperative form. Explain the "why" instead of heavy-handed MUSTs. Use theory of mind. |
| **Description quality** | Make descriptions a bit "pushy" — Claude tends to under-trigger. Include specific contexts, not just what the skill does. |
| **Security** | Skills must not contain malware, exploit code, or misleading content. |

---

## The 5-Step Evaluation Pipeline

This is the heart of the skill. When testing a skill, Claude follows this sequence:

### Step 1: Spawn all runs in parallel

For each test case, spawn **two subagents in the same turn**:
- **With-skill run** — executes the task using the skill
- **Baseline run** — same prompt, no skill (for new skills) or old skill version (for improvements)

Results go into `<skill-name>-workspace/iteration-N/eval-<ID>/{with_skill,without_skill}/outputs/`.

### Step 2: Draft assertions while runs are in progress

Don't wait idle. Draft quantitative assertions (objectively verifiable checks) and explain them to the user. Save to `eval_metadata.json` and `evals/evals.json`.

### Step 3: Capture timing data from notifications

When each subagent completes, a notification arrives with `total_tokens` and `duration_ms`. This is the **only chance** to capture this data — save to `timing.json` immediately.

### Step 4: Grade, aggregate, and launch viewer

1. **Grade** — spawn a grader subagent (reads `agents/grader.md`) to evaluate assertions against outputs. Saves `grading.json`.
2. **Aggregate** — run `python -m scripts.aggregate_benchmark` to produce `benchmark.json` + `benchmark.md` with mean +/- stddev for pass_rate, time, tokens.
3. **Analyst pass** — surface patterns the aggregate stats hide (non-discriminating assertions, high-variance evals, time/token tradeoffs).
4. **Launch viewer** — `python eval-viewer/generate_review.py` opens an interactive browser UI with two tabs: "Outputs" (qualitative review + feedback textboxes) and "Benchmark" (quantitative stats).

### Step 5: Read feedback

User reviews in the browser, clicks "Submit All Reviews", feedback saves to `feedback.json`. Empty feedback = looks fine. Focus improvements on specific complaints.

---

## Description Optimization

A separate workflow to improve **when** the skill triggers:

| Step | What happens |
|:--|:--|
| **1. Generate eval queries** | Create 20 queries — 8-10 should-trigger, 8-10 should-not-trigger. Must be realistic, detailed, and tricky (near-misses for negatives, not obvious irrelevancies). |
| **2. User review** | Present via `assets/eval_review.html` template. User can edit queries, toggle should-trigger, add/remove entries, then export. |
| **3. Run optimization loop** | `python -m scripts.run_loop` — splits eval set 60/40 train/test, evaluates current description (3 runs per query), uses extended thinking to propose improvements, iterates up to 5 times. Selects best by test score (not train) to avoid overfitting. |
| **4. Apply result** | Take `best_description` from JSON output, update SKILL.md frontmatter. |

---

## Bundled Subagent References

> These are **not** plugin-level agents. They have no YAML frontmatter and are not auto-triggered by Claude. They are reference documents that the skill tells Claude to read when it needs to spawn a specialised subagent.

### 1. Grader

> `skills/skill-creator/agents/grader.md` · 224 lines

Evaluates assertions against execution transcripts and outputs.

| Aspect | Detail |
|:--|:--|
| **What it does** | Reads transcripts + output files, evaluates each assertion as PASS/FAIL with evidence, extracts implicit claims (factual/process/quality), critiques the evals themselves |
| **Burden of proof** | On the expectation — when uncertain, FAIL |
| **Output** | `grading.json` with expectations (text/passed/evidence), summary, execution_metrics, timing, claims, eval_feedback |
| **Critical detail** | The expectations array **must** use fields `text`, `passed`, `evidence` — the viewer depends on these exact names |

### 2. Comparator

> `skills/skill-creator/agents/comparator.md` · 203 lines

Performs blind A/B comparison between two outputs.

| Aspect | Detail |
|:--|:--|
| **What it does** | Receives two anonymised outputs (A and B), generates content + structure rubrics, scores each output 1-5 per criterion, picks a winner |
| **Blindness** | Does not know which skill produced which output — prevents bias |
| **Output** | `comparison.json` with winner (A/B/TIE), reasoning, rubric scores, output_quality assessments |
| **Ties** | Should be rare — if both fail, pick the one that fails less badly |

### 3. Analyzer

> `skills/skill-creator/agents/analyzer.md` · 275 lines

Has two modes:

**Post-hoc analysis** — after a blind comparison, reads the results to understand *why* the winner won. Outputs `analysis.json` with winner strengths, loser weaknesses, instruction-following scores, and prioritised improvement suggestions (high/medium/low).

**Benchmark analysis** — surfaces patterns across multiple runs that aggregate stats hide: non-discriminating assertions (always pass regardless of skill), high-variance evals (possibly flaky), and time/token tradeoffs.

---

## Bundled Scripts

All Python scripts live in `skills/skill-creator/scripts/`.

| Script | Lines | What it does |
|:--|:--|:--|
| `run_eval.py` | ~310 | Tests whether a skill description triggers Claude for eval queries. Uses `claude -p` via subprocess. Supports `--num-workers`, `--runs-per-query`, `--trigger-threshold`. |
| `run_loop.py` | ~333 | Combines eval + improve in an iterative loop. Stratified train/test split (40% holdout), up to 5 iterations, uses extended thinking. Generates live HTML report. |
| `aggregate_benchmark.py` | ~401 | Aggregates `grading.json` files into `benchmark.json` + `benchmark.md`. Calculates mean, stddev, min, max for pass_rate, time, tokens. |
| `improve_description.py` | ~100+ | Calls Claude with extended thinking to improve descriptions based on failed/false triggers. Includes history to avoid repetition. |
| `generate_report.py` | ~80+ | Generates HTML report from `run_loop.py` output. Distinguishes train vs test queries. Supports auto-refresh. |
| `quick_validate.py` | ~80+ | Validates skill structure: SKILL.md exists, valid frontmatter, required fields, kebab-case naming. |
| `package_skill.py` | ~80+ | Creates distributable `.skill` file (zip archive). Excludes `__pycache__`, `node_modules`, `.pyc`, `.DS_Store`. |
| `utils.py` | 48 | Parses SKILL.md frontmatter (name, description). Handles YAML block scalars. |
| `__init__.py` | 0 | Package marker |

---

## Viewer and UI Files

| File | Size | What it does |
|:--|:--|:--|
| `eval-viewer/viewer.html` | 44 KB | Interactive two-tab browser UI. "Outputs" tab: renders output files inline, shows grades, auto-saves feedback per test case. "Benchmark" tab: stats summary with per-eval breakdowns and analyst observations. Navigation via arrows/buttons. |
| `eval-viewer/generate_review.py` | ~16 KB | Generates and serves the viewer. Discovers runs, embeds data into self-contained HTML, serves via localhost. Supports `--static` for headless environments and `--previous-workspace` for iteration comparison. |
| `assets/eval_review.html` | ~7 KB | Trigger eval query editor. Table UI where user can edit queries, toggle should-trigger, add/delete entries, export as `eval_set.json`. |

---

## JSON Schemas

> `skills/skill-creator/references/schemas.md` · ~430 lines

Defines exact JSON structures for all data files in the evaluation pipeline:

| Schema | Purpose |
|:--|:--|
| `evals.json` | Test case definitions — skill_name, evals array with id/prompt/expected_output/files/expectations |
| `grading.json` | Assertion evaluation results — expectations, summary, execution_metrics, timing, claims, eval_feedback |
| `benchmark.json` | Aggregated stats — metadata, runs, run_summary (with_skill/without_skill/delta), notes |
| `timing.json` | Execution timing — total_tokens, duration_ms, total_duration_seconds |
| `history.json` | Version progression tracking across iterations |
| `metrics.json` | Tool usage — tool_calls, total_steps, errors, output/transcript chars |
| `comparison.json` | Blind A/B results — winner, reasoning, rubric scores |
| `analysis.json` | Post-hoc analysis — strengths, weaknesses, improvement suggestions |

Field names and nesting must be exact — the viewer HTML depends on them.

---

## Platform Support

| Platform | Subagents | Browser viewer | Description optimization | Packaging |
|:--|:--|:--|:--|:--|
| **Claude Code** | Full parallel execution | `generate_review.py` opens browser | `run_loop.py` via `claude -p` | `package_skill.py` |
| **Claude.ai** | Not available — run test cases inline, one at a time | Skip — present results in conversation | Not available (needs `claude` CLI) | Works (needs Python + filesystem) |
| **Cowork** | Available (may need serial fallback for timeouts) | Use `--static` flag for standalone HTML | Works via `claude -p` | Works |

---

## How it compares to plugin-dev

| | **plugin-dev** | **skill-creator** |
|:--|:--|:--|
| **Purpose** | Teaches how to build plugins (structure, commands, agents, skills, hooks, MCP, settings) | Creates, tests, and iterates on individual skills |
| **Components** | 3 agents + 7 skills + 1 command | 1 skill (with bundled evaluation infrastructure) |
| **Agents** | Plugin-level (YAML frontmatter, auto-triggered) | Reference docs (no frontmatter, manually read by skill) |
| **Scripts** | 3 bash validation scripts (across skills) | 9 Python scripts (eval pipeline, optimization, packaging) |
| **Interactive UI** | None | 3 HTML files (results viewer, report generator, eval editor) |
| **Focus** | Knowledge (teaches patterns and conventions) | Workflow (guides you through a process with tooling) |
