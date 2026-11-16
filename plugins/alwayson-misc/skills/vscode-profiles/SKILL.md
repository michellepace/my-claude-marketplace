---
name: vscode-profiles
description: Answer VSCode Profile questions on this machine
argument-hint: '"What is in my custom profiles?"'
user-invocable: true
disable-model-invocation: true
allowed-tools:
  - Bash(code --list-extensions)
  - Bash(jq *)
  - Bash(sqlite3 -readonly *)
  - Bash(grep *)
  - Read(//mnt/c/Users/mp/AppData/Roaming/Code/User/**)
  - Read(~/.vscode-server/**)
---

# Answer VS Code Profile Questions

User Question: `$ARGUMENTS`

If the question is blank or irrelevant to this skill, show a friendly helpful message:

> 🤔 ...

Otherwise, leverage this information to help answer the question.

## This Machine: VS Code on Windows, Every Window in WSL (Ubuntu)

**The one rule:** this file records *constants and mechanisms*, not inventories. Paths and mechanisms are stable — trust them. Everything else changes — which custom profiles exist and their hashes, extension lists, settings values, directory→profile mappings. Run the commands; never answer from this document or memory.

### 1. Model

- Questions arrive from the integrated terminal of the project's window: `code` is bound to that window, and `$PWD` is the directory VSCode opened or a subdirectory of it.
- **Windows holds the config** (settings, keybindings, profile registry). **WSL holds the extensions** that run. Everything else on either side is cache.
- **Default** is built-in and near-empty — only what new windows open in. Everything else is a *custom profile*; when I ask about profiles I mean these. A project is switched to a custom profile once and remembered. Never assume the roster — list it (§2).
- **Convention:** every custom profile takes *Settings* and *Keyboard Shortcuts* from Default and owns everything else. Net effect: **one `settings.json` and one `keybindings.json` for the whole machine.** One-way — Default never takes anything from a custom profile.

### 2. Paths

| What | Path |
| :--- | :--- |
| User settings | `/mnt/c/Users/mp/AppData/Roaming/Code/User/settings.json` — JSONC, `jq` chokes |
| Keyboard Shortcuts | `/mnt/c/Users/mp/AppData/Roaming/Code/User/keybindings.json` — JSONC, `jq` chokes |
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
- **Extensions:** each profile's list is a full set, not a delta. An extension with `metadata.isApplicationScoped: true` (nested, not top-level) is active in *every* profile regardless — currently Claude Code, which is why Default's list isn't empty. The WSL extension also runs in every profile, on the Windows side, so no WSL-side list (including `code --list-extensions`) shows it — add it.
- **Enabled:** installed lists include disabled extensions. Each profile's and project's Windows-side `state.vscdb` holds them under `extensionsIdentifiers/*` (`sqlite3 -readonly`).
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
| Which extensions are in this profile? | `code --list-extensions` (app-scoped included), plus WSL, minus disabled (§3) |
| Which extensions are in another profile? | `jq -r '.[].identifier.id' ~/.vscode-server/data/User/profiles/<hash>/extensions.json`, plus the app-scoped ones and WSL, minus disabled (§3) |
| What's in Default? | extensions: `jq -r '.[].identifier.id' ~/.vscode-server/extensions/extensions.json`, plus WSL, minus disabled (§3); settings and keybindings: §2 |
| Does profile X inherit from Default? | `jq -r '.userDataProfiles[] \| "\(.name)\t\(.useDefaultFlags // {} \| keys \| join(","))"' $S` |
| What is my effective setting for Y? | User settings, then Workspace settings override them (§2) |

### 5. Traps

Things a cold start gets wrong without being told:

- Remote settings (`~/.vscode-server/data/Machine/settings.json`) are unused. User settings reach every window, except `machine`-scoped ones, which a WSL window reads only from Remote settings.
- `~/.vscode-server/data/User/globalStorage/storage.json` is a stale mirror. Only the Windows one counts.
- `code --profile <name>` is ignored; you get this window's list.
- Windows-side extension lists (`…/Code/User/profiles/<hash>/extensions.json`, `/mnt/c/Users/mp/.vscode/extensions/`) are the UI's "Local – Installed". Ignore them, bar WSL (§3).
- **GitHub Copilot** and **JavaScript Debugger Companion** in the profile UI are VSCode built-ins, not installs.
- `<repo>/.vscode/extensions.json` is recommendations, not installs.

## Answer style & format

Plain worded, concise and easy to read.
