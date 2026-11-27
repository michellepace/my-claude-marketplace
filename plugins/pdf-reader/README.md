# Plugin: `pdf-reader`

A single Skill for reading PDFs: a slimmed-down version of Anthropic's `pdf` skill that only covers reading and inspection (no creating, filling, merging or splitting).

Install (project scope) where it's wanted:

```bash
claude plugin marketplace add michellepace/my-claude-marketplace --scope project
claude plugin install pdf-reader@my-claude-marketplace           --scope project
```

It auto-invokes, so its description is always in Claude's context window. Install it only in projects that need it.

## What's Inside

| Run Skill | What it does |
| :-------- | :----------- |
| [`/pdf-reader`](SKILL.md) | Read, inspect and extract content from PDFs |

Single-skill layout: `SKILL.md` sits at the plugin root, and its full name is `pdf-reader:pdf-reader`.

## Usage Examples

- *"what's in the chart on page 3 of report.pdf?"*
- *"this PDF is a scan, get the text out"*
- *"pull the attached spreadsheet out of invoice.pdf"*
