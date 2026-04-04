# Evaluating Plugin Skill: `nextjs-shadcn-ui` Eval Examples

Location: [nextjs-utils](../../plugins/nextjs-utils):[nextjs-shadcn-ui](../../plugins/nextjs-utils/skills/nextjs-shadcn-ui)

## Use of Anthropic Skills

### Step 1: Structural Validation (plugin-dev → Plugin Validator agent)

**What it does:** Runs a 10-step audit — manifest, directory structure, frontmatter,
MCP config, file hygiene, security (hardcoded secrets, HTTPS), and more.
Outputs a report with Critical / Warning / Pass categories.

**Instruction to give Claude Code:**

```markdown
Validate my plugin at `plugins/nextjs-utils/`. Run the Plugin Validator agent and give me the full report. Fix any Critical issues automatically; list Warnings for me to decide on.
```

---

### Step 2: Skill Quality Review (plugin-dev → Skill Reviewer agent)

**What it does:** Reviews the skill across 4 dimensions:
1. **Description** — Does it contain specific trigger phrases? Right length?
2. **Content** — Word count, writing style, logical flow, concrete guidance
3. **Progressive disclosure** — Core in SKILL.md, details in references/?
4. **Issues** — Categorised as Critical / Major / Minor with before/after examples

Outputs a rating: Pass / Needs Improvement / Needs Major Revision.

**Instruction to give Claude Code:**

```markdown
Review the skill at `plugins/nextjs-utils/skills/nextjs-shadcn-ui/SKILL.md` using the Skill Reviewer agent. DO NOT optimise description triggers, focus on whether the content is well-organised, clear, and concise - the target audience is Claude Code. Give me the full review with the rating and prioritised recommendations.
```

### Step 3 (optional): Eval & Optimise Triggering (skill-creator)

Only do this if Step 2 flagged description or triggering issues.

**What it does:** Runs a rigorous evaluation pipeline:
- Creates test cases (prompts that should/shouldn't trigger the skill)
- Runs with-skill vs baseline comparisons in parallel
- Grades outputs against assertions
- Launches a browser viewer for human review
- Optionally runs a description optimisation loop (up to 5 iterations)

**Instruction to give Claude Code:**

```markdown
Use the skill-creator to evaluate and optimise the nextjs-shadcn-ui skill at `plugins/nextjs-utils/skills/nextjs-shadcn-ui/SKILL.md`. Start by creating test cases, then run the evaluation pipeline. Do not optimise the description.
```

---

## Test Prompts

Realistic test prompts for evaluating plugin skills with the skill-creator pipeline.

### Eval 1 — Customise a Button with a new variant

```markdown
I need a "soft" button variant for my Next.js app that uses shadcn/ui. It should have a muted background from my theme and slightly reduced opacity on hover. Where should I add this and how?
```

Tests: CVA variant guidance, semantic token usage, modify-primitive-vs-composition decision.

### Eval 2 — Architect a settings page

```markdown
I'm building a settings page in my Next.js project (app router, RSC). It needs a sidebar navigation on the left listing sections (Profile, Notifications, Billing), and the right side shows the active section's form. I'm using shadcn/ui — how should I structure the components? Show me the file layout and key code.
```

Tests: composition pattern, server/client boundary advice, component architecture, form guidance.

### Eval 3 — Replace deprecated Toast with Sonner + use new components

```markdown
My app currently uses the shadcn Toast component for notifications. I've heard it's deprecated. What should I use instead? Also, I need a loading spinner and some empty-state UI for when there's no data — does shadcn have anything for those now?
```

Tests: deprecation awareness (Toast to Sonner), knowledge of new utility components (Spinner, Empty), changelog awareness.
