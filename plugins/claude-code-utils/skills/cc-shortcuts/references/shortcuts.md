# Claude Code Shortcuts + VSCode

**MY KEYS:** | 🌸Force me | ⚠️VSCode problem | 🪲 VSCode does this (nice) | ok Later |

## Deletion shortcuts

| Key | Shortcut | What it does |
|:---|:---|:---|
| 🌸 | `Ctrl+C` | Delete **everything** typed (or stops generation) |
| 🌸 | `Ctrl+U`/`Ctrl+K` | Delete **before / after** cursor on line |
| 🌸 | `Ctrl+W`/`Alt+D` | Delete **previous / next** word |
| 🌸 | `Ctrl+Y` | **Paste back** what was deleted above |
| ok | `Alt+Y` | Cycle through paste history (after Ctrl+Y) |

## Cursor movement

| Key | Shortcut | What it does |
|:---|:---|:---|
| 🌸 | `Ctrl+A` | Jump to **start** of line |
| ⚠️ | `Ctrl+E` | ~~Jump to **end** of line~~ |
| 🪲 | `Ctrl+E` | Search VSCode project by filename |
| ok | `Alt+B` | Move back **one word** |
| ok | `Alt+F` | Move forward **one word** |

## General controls

| Key | Shortcut | What it does |
|:---|:---|:---|
| 🌸 | `Ctrl+S` | Stash current prompt for later |
| ok | `Ctrl+R` | Search through prompt history interactively |
| 🌸 | `Ctrl+L` | Redraw terminal window when garbled |
| 🌸 | `Ctrl+D` | Exit Claude Code |
| ⚠️ | `Ctrl+J` | ~~Insert newline without submitting~~ |
| 🪲 | `Ctrl+J`/`Ctrl+B` | VSCode hide **right / left panel** |

## Claude Code-specific actions

| Key | Shortcut | What it does |
|:---|:---|:---|
| 🌸 | `Esc Esc` | Rewind conversation to a previous point |
| ok | `Alt+P` | Switch model without clearing your prompt |
| ok | `Alt+T` | Toggle extended thinking mode |
| ⚠️ | `Ctrl+G` | ~~Open current prompt in your external editor~~ |
| 🪲 | `Ctrl+G` | VSCode go to line number |
| ? | `Ctrl+O` | Toggle transcript viewer (shows tool calls, MCP) |

## My VSCode

| Key | Shortcut | What it does |
|:---|:---|:---|
| 🪲 | `Ctrl+Shift+V` | Markdown preview |
| 🪲 | `Alt + ←` | Exit preview AND "last place" |
| 🪲 | `Ctrl+Shift+E` | View Exlorer |
| 🪲 | `Ctrl+Shift+G` | View Source Control |

---

## Appendix

## Practice Text

```text
The Alignment team works to understand the risks of AI models and develop ways to ensure that future ones remain helpful, honest, and harmless.

- Hello
- hello there cow
- inky pink ponky

The Frontier Red Team analyzes the implications of frontier AI models for cybersecurity, biosecurity, and autonomous systems.

echo
echo me
echo hello

## Societal Impacts
Working closely with the Anthropic Policy and Safeguards teams, Societal Impacts is a technical research team that explores how AI is used in the real world.
```

---

### ⚠️ WINDOWS ON CTRL+K

VSCode shortcut key binding conflicts above... figure out one day.

VSCode intercepts `Ctrl+K` as the start of a chord shortcut (e.g. `Ctrl+K Ctrl+C` to comment code), so it never reaches the terminal. Add this to your User Settings to pass it through.

```jsonc
// My File (WSL): /mnt/c/Users/mp/AppData/Roaming/Code/User/settings.json

// Pass Ctrl+K (and other chord-leader keys) through to the
// integrated terminal so Claude Code can receive them
"terminal.integrated.allowChords": false,
```
---

### ♥️ Windows WSL: Copy from Desktop

Ask Claude Code

```text
# TASK: I'm on Windows WSL (VSCode), make it easy for me to copy files
Set up `~/Desktop` and `~/Downloads` as symlinks to my Windows folders.
Verify by copying `cp` one file from each to here, show me the commands.

Can I also reference these in prompts e.g. "analyse ~/Desktop/image.jpg"?
```
