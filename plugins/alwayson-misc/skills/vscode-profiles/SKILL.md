---
name: vscode-profiles
description: Answer VSCode Profile questions on this machine
argument-hint: '"What is in my custom profiles?"'
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(code --list-extensions)
  - Bash(jq *)
  - Bash(grep *)
  - Read(//mnt/c/Users/mp/AppData/Roaming/Code/User/**)
  - Read(~/.vscode-server/**)
---


# Answer VS Code Profile Questions

Question: `$ARGUMENTS`

You are to answer a Question regarding the VS Code profiles on this machine. If the Question is blank or irrelevant to this, show me a friendly helpful message. List 3-4 examples of what I could ask. Keep it short and easy to read.

> 🤔 ...

Otherwise, leverage this information to help answer the question.

## VSCode Profiles on This Machine — Answer the Question

**The one rule:** this file records *constants and mechanisms*, not inventories. Paths and mechanisms are stable — trust them. Everything else changes — which custom profiles exist and their hashes, extension lists, settings values, directory→profile mappings. Run the commands; never answer from this document or memory.

### 1. Model

- VSCode runs on Windows; every window is Remote-WSL (Ubuntu). Questions arrive from the integrated terminal of the project's window: `code` is bound to that window, and `$PWD` is the directory VSCode opened or a subdirectory of it.
- **Windows holds the config** (settings, keybindings, profile registry). **WSL holds the extensions** that run. Everything else on either side is cache.
- **Default** is built-in and near-empty — only what new windows open in. Everything else is a *custom profile*; when I ask about profiles I mean these. A project is switched to a custom profile once and remembered. Never assume the roster — list it (§2).
- **Convention:** every custom profile takes *Settings* and *Keyboard Shortcuts* from Default and owns everything else. Net effect: **one `settings.json` and one `keybindings.json` for the whole machine.** One-way — Default never takes anything from a custom profile.

### 2. Paths

| What | Path |
| :--- | :--- |
| The one `settings.json` / `keybindings.json` | `/mnt/c/Users/mp/AppData/Roaming/Code/User/` — **JSONC**: read as text, `json.load` chokes |
| Profile registry (names, hashes, inheritance flags, directory→profile map) | `/mnt/c/Users/mp/AppData/Roaming/Code/User/globalStorage/storage.json` — plain JSON |
| Default profile's extensions | `~/.vscode-server/extensions/extensions.json` |
| Custom profile's extensions | `~/.vscode-server/data/User/profiles/<hash>/extensions.json` |
| Workspace settings (override everything) | `<repo>/.vscode/settings.json` |

**The custom profiles and their hashes** — always list, never recall (deleting a profile in the UI drops it from here, and its `profiles/<hash>/` directory is left behind on both sides, so the registry is authoritative, not the disk):

```shell
jq -r '.userDataProfiles[] | [.location, .name] | @tsv' \
  /mnt/c/Users/mp/AppData/Roaming/Code/User/globalStorage/storage.json
```

### 3. Mechanisms

- **Inheritance:** `storage.json` → `userDataProfiles[].useDefaultFlags`, one key per resource; `true` = use Default's, absent = own (own files would live in `/mnt/c/Users/mp/AppData/Roaming/Code/User/profiles/<hash>/`). In the profile UI these are the *Contents* toggles: `Default` selected = `true`. Currently every custom profile has exactly `settings: true, keybindings: true`.
- **Extensions:** each profile's list is a full set, not a delta. An extension with `metadata.isApplicationScoped: true` (nested, not top-level) is active in *every* profile regardless — currently Claude Code, which is why Default's list isn't empty.
- **Directory → profile:** `storage.json` → `profileAssociations.workspaces`, keyed by the directory VSCode opened. **Last-write-wins**; entries outlive moved or deleted directories.

### 4. Answers

```shell
# Profile registry (Windows side)
S=/mnt/c/Users/mp/AppData/Roaming/Code/User/globalStorage/storage.json

# A. Directory → profile, every entry, one per line: "<Profile>\t<dir>"
jq -r '(.userDataProfiles | map({(.location): .name}) | add) as $n | .profileAssociations.workspaces | to_entries[] | "\($n[.value] // "Default")\t\(.key | sub("^vscode-remote://wsl%2Bubuntu";""))"' $S

# B. Profile of $PWD — exact match, else nearest recorded ancestor (printed, so a fallback is visible)
jq -r --arg p "$PWD" '(.userDataProfiles | map({(.location): .name}) | add) as $n | [.profileAssociations.workspaces | to_entries[] | .key |= sub("^vscode-remote://wsl%2Bubuntu";"") | select((.key + "/") as $k | ($p + "/") | startswith($k))] | max_by(.key | length) | if . then "\($n[.value] // "Default")\t\(.key)" else "(not recorded)" end' $S
```

| Question | Do |
| :--- | :--- |
| Which profile is this project in? | **B** — cross-check with `code --list-extensions` |
| Which projects use profile X? | **A** `\| grep -P '^<Profile>\t'` (the `\t` matters — one profile name may prefix another) |
| Which extensions are in this profile? | `code --list-extensions` — complete for this window's profile, app-scoped included |
| Which extensions are in another profile? | `jq -r '.[].identifier.id' ~/.vscode-server/data/User/profiles/<hash>/extensions.json`, plus the app-scoped ones |
| What's in Default? | extensions: `jq -r '.[].identifier.id' ~/.vscode-server/extensions/extensions.json`; settings and keybindings: *the* two files in §2 |
| Does profile X inherit from Default? | `jq -r '.userDataProfiles[] \| "\(.name)\t\(.useDefaultFlags // {} \| keys \| join(","))"' $S` |
| What is my effective setting for Y? | Windows `settings.json`, then `<repo>/.vscode/settings.json` overrides it |

### 5. Traps

Things a cold start gets wrong without being told:

- There is **no** `settings.json` or `keybindings.json` under `~/.vscode-server/`. `~/.vscode-server/data/Machine/settings.json` exists but is `{}`.
- `~/.vscode-server/data/User/globalStorage/storage.json` is a stale mirror. Only the Windows one counts.
- `code --status` is unreliable from this shell (often returns nothing). The registry is the answer, not the window title.
- `code --profile <name>` is silently ignored. Other profiles are answered from files, not the CLI.
- Windows-side extension lists (`…/Code/User/profiles/<hash>/extensions.json`, `/mnt/c/Users/mp/.vscode/extensions/`) are not what runs. Ignore.
- **GitHub Copilot** and **JavaScript Debugger Companion** in the profile UI are VSCode built-ins, not installs.
- `<repo>/.vscode/extensions.json` is recommendations, not installs.
- `profileAssociations.emptyWindows` (timestamp → profile) is folderless windows. Not projects; A and B ignore it.
- `~/.vscode-server/data/User/{History,globalStorage/<ext>,workspaceStorage}` are Local History, extension cache and UI state. Every `snippets/` dir is empty; no tasks/MCP/prompt files exist in any profile.

## Answer style & format

Plain worded, concise and easy to read.
