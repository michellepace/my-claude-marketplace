---
name: uv-pep723
description: uv + PEP 723 conventions. Use to write a standalone Python script (no associated pyproject.toml) or run inline code.
user-invocable: true
disable-model-invocation: false
allowed-tools:
  - Bash(uv init --script *)
  - Bash(uv add --script *)
  - Bash(uv run *)
  - Read(~/projects/python/docs-for-ai/collections/uv/**)
---

# Standalone Python Scripts — uv + PEP 723

A standalone script is one file that declares its own dependencies in a PEP 723 header. The header is what isolates the script: it runs in its own cached environment, ignoring the dependencies of any project it sits in.

## Create

Create the script first, then add dependencies:

```shell
uv init --script report.py --python 3.15
uv add --script report.py requests rich
```

Resulting header (uv adds a `>=` lower bound from the latest version):

```python
# /// script
# requires-python = ">=3.15"
# dependencies = [
#     "requests>=2.34.2",
#     "rich>=15.0.0",
# ]
# ///
```

## Run

```shell
uv run report.py
```

uv's own options go before the filename; anything after it is passed to the script.

## Make executable

For a file on `PATH`, a git hook or a skill script. Add the shebang above the header; `--script` is what parses an extensionless file as PEP 723:

```python
#!/usr/bin/env -S uv run --script
```

```shell
chmod +x report         # `report.py` renamed to `report`
./report                # runs via the shebang
uv run --script report  # or invoke uv directly
```

## No file to hold a header

Code generated on the fly and never saved has nowhere for a header, so name deps inline:

```shell
uv run --with rich --no-project python -c 'import rich; rich.print("[bold]hi[/]")'
echo 'import rich; rich.print("[bold]hi[/]")' | uv run --with rich --no-project -
```

With no header to isolate it, `--no-project` skips the surrounding project. Anything worth running twice gets a file and a header instead.

## Reference Docs

For any uv question this doesn't answer, read the index at `~/projects/python/docs-for-ai/collections/uv/INDEX.xml` and pick the local doc to read from it.
