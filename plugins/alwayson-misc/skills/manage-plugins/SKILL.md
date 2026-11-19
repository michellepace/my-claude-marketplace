---
name: manage-plugins
description: Answer Claude plugin and marketplace questions
argument-hint: '"Which plugins apply to this project?"'
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(claude plugin * --help)
  - Bash(claude plugin --help)
  - Bash(claude plugin details *)
  - Bash(claude plugin list *)
  - Bash(claude plugin marketplace list *)
  - Bash(claude plugin marketplace update *)
  - Bash(claude plugin update *)
  - Bash(curl -fsSL https://raw.githubusercontent.com/*)
  - Bash(jq *)
---

# Answer Claude Plugin & Marketplace Questions

**Question to answer:** $ARGUMENTS

If blank or not about plugins or marketplaces, reply with a short message listing 3 questions as examples. Start with "🤔 ..."

## Scopes and Commands

Plugins and marketplaces come from the `enabledPlugins` and `extraKnownMarketplaces` keys in three settings files, one per scope. They merge, and if two scopes set the same entry, local wins over project, and project wins over user:

- **local** `.claude/settings.local.json`
- **project** `.claude/settings.json` — my default scope
- **user** `~/.claude/settings.json` — CLI default

| Task | How |
| :--- | :-- |
| See this project's plugins (`true` = enabled) and marketplaces | `jq -n 'inputs \| {file: input_filename, enabledPlugins, extraKnownMarketplaces}' .claude/settings.local.json .claude/settings.json ~/.claude/settings.json 2>/dev/null` |
| Find which marketplace offers a plugin | `claude plugin list --json --available \| jq -r '.available[] \| select(.name=="<name>") \| .marketplaceName'` |
| Inspect an installed plugin | `claude plugin details <name>@<mkt>` |
| Add a marketplace | `claude plugin marketplace add <owner/repo, URL or path> --scope project` |
| Refresh every marketplace from source (plugins not updated; see below) | `claude plugin marketplace update` |
| Find which projects use a marketplace | Search `~/projects` for `.claude/settings*.json` files containing `<mkt>` (plus `~/.claude/settings.json`) |
| Remove a marketplace | **This project:** `claude plugin uninstall <name>@<mkt> --scope project` for each `*@<mkt>` plugin, then delete `<mkt>` from `extraKnownMarketplaces` in `.claude/settings.json`. **Every project:** `claude plugin marketplace remove <mkt>`, then delete `*@<mkt>` and `<mkt>` from each file the "which projects" row finds |
| Install / enable / disable / update a plugin | `claude plugin <verb> <name>@<mkt> --scope project` |
| Uninstall a plugin | `claude plugin uninstall <name>@<mkt> --scope project`; if no `*@<mkt>` plugin is left in that file, also delete `<mkt>` from its `extraKnownMarketplaces` |
| Test a plugin from my marketplace without installing it | Tell me to run `claude --plugin-dir ~/path/to/<marketplace>/plugins/<plugin-name>`, then `/reload-plugins` after each edit |
| Anything else | `claude plugin --help`, `claude plugin <cmd> --help` |

## Gotchas

- `claude plugin list` and `claude plugin marketplace list` are machine-wide and contain duplicates — never a per-project answer; read the settings files.
- A plugin loaded with `--plugin-dir` runs for that session whatever the settings files say. Its skills' base directory is my working copy, not under `~/.claude/plugins/cache`.
- `details` only sees installed plugins, and `--available` only works with `--json` — hence the "which marketplace" row.
- `marketplace remove` does one of two things, depending on whether it removes the last scope that declares `<mkt>` from this directory. Hence the "Remove a marketplace" row.
  - **Last scope** (no `--scope`, or the only declaring one): uninstalls its plugins in every project, and deletes `*@<mkt>` and `<mkt>` from this directory's files only. Other projects keep both, and `remove` and `uninstall` there now fail with `not found`. A leftover `extraKnownMarketplaces` entry re-clones the marketplace at the next session start.
  - **Any other scope**: deletes only that scope's `<mkt>` declaration. `*@<mkt>` and installs stay.
- Non-zero exits that aren't failures:
  - `enable` / `disable` exit `1` when the plugin is already in that state (`--json` gives `failureCode: "already_in_goal_state"`).
  - `jq` exits `2` when a settings file is missing, but still reads the others.

## Examples

Examples of questions I am likely to ask you.

### 1. What plugins apply to this project?

One row per plugin, sorted State (✅ first) → Scope. Show the winning scope; flag 🚩 any that isn't project:

| State | Plugin@Marketplace | Scope |
| :---- | :----------------- | :---- |
| ✅ | alwayson-misc@my-claude-marketplace | --plugin-dir 🧪 (overrides project ❌) |
| ✅ | pyright-lsp@claude-plugins-official | project |
| ✅ | hive-health@honeybellblue-farm-bees | user 🚩 |
| ❌ | git-utils@my-claude-marketplace | local 🚩 (overrides project ✅) |

### 2. How do I install this plugin?

> How do I install this plugin https://github.com/anthropics/claude-plugins-community for my project?

Read its manifest; don't add the marketplace:

```bash
curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/HEAD/.claude-plugin/marketplace.json \
| jq -r '"\(.name): \(.plugins | length) plugins", (.plugins[] | "- \(.name): \(.description // "")")'
```

List its plugins and ask which I want. Over 20? Ask what I'm after and show matches. Once I pick, give me:

```bash
claude plugin marketplace add <owner/repo> --scope project
claude plugin install <name>@<mkt> --scope project
```

### 3. Update All Plugins, Everywhere

Two layers, updated separately:

- **Marketplace copy**: one per machine, shared by every project.
- **Install record**: one per `(plugin, scope, project)`. Each is updated from its own project; there is no `--all`.

**1. Refresh every marketplace copy.** Run it straight away; it changes no project.

```bash
claude plugin marketplace update
```

**2. Dry run.** Run the loop with `echo` in place of `claude plugin update`. It lists all install records, also current ones. Count with code. Report the totals and the marketplace count from step 1. Give detail only for problems. Wait for my go-ahead.

```bash
# set m to a marketplace name to limit it
m=""
claude plugin list --json \
| jq -r --arg m "$m" '.[] | select($m == "" or (.id | endswith("@" + $m)))
    | [.id, .scope, .projectPath // ""] | @tsv' | sort -u \
| while IFS=$'\t' read -r id scope proj; do
    if [ -n "$proj" ] && [ ! -d "$proj" ]; then echo "skip (missing): $id  $proj"; continue; fi
    echo "== $id  ${proj:-.}"
    ( cd "${proj:-.}" && claude plugin update "$id" --scope "$scope" </dev/null ) || echo "FAILED"
  done 2>&1 | tee /tmp/plugin-update.log
```

**3. Update for real.** Run the loop as written, then from the log report:

- The tally
- What moved: plugin, project, old → new version
- Any failure or skip. An update that needs a command approved fails here: don't pass `-y` or `--accept-command`; give me `cd <project> && claude plugin update <id> --scope <scope>` to run myself

Open sessions need `/reload-plugins`.

**Never clean the cache by hand.** Old versions are swept automatically.

## Deliverable

Answer the question in a format that is simple, tight, and easy to scan. I am trying to understand and get things done, don't leave me with a wall of undue complexity. Include emojis strategically.

Rules
- If you are unsure about my question or anything else, ask me
- Get every count you report from a command (`wc -l`, `grep -c`, `jq length`), never by counting the output by eye
