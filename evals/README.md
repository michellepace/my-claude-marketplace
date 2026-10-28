# 🧮 Manual Evals for Skills

One eval file per skill. Its frontmatter records the last run: the skill's commit, the model, and the result.

See every skill's last run at once (from the repo root):

```bash
grep -H -E '^(skill-commit|model|result):' evals/*.md
```

To eval a working copy without installing:

```bash
# e.g. skills in alwayson-misc
claude --plugin-dir ~/projects/my-claude-marketplace/plugins/alwayson-misc
```
