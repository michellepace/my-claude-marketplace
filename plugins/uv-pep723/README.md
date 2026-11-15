# Plugin: `uv-pep723`

A single Skill for standalone Python scripts: one file that declares its own dependencies in a PEP 723 header and runs via uv.

Install (project scope) where it's wanted:

```bash
claude plugin marketplace add michellepace/my-claude-marketplace --scope project
claude plugin install uv-pep723@my-claude-marketplace            --scope project
```

It auto-invokes, so its description is always in Claude's context window. Install it only in projects that need it. It hardcodes my machine: uv docs are read from `~/projects/python/docs-for-ai`.

## What's Inside

| Run Skill | What it does |
| :-------- | :----------- |
| [`/uv-pep723`](SKILL.md) | Make standalone uv Python scripts |

Single-skill layout: `SKILL.md` sits at the plugin root, and its full name is `uv-pep723:uv-pep723`.

## Usage Examples

- *"use python + rich to visualise data.tsv (Edward Tufte: show me the numbers!)"*
- *"make me a throwaway script to plot this CSV"*
