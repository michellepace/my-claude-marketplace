# Claude Code Shortcuts + VSCode

**MY KEYS:** | 🌸Force me | ⚠️VSCode problem | 🪲 VSCode does this (nice) | ok Later |

## Deletion shortcuts

| Key | Shortcut | What it does |
| :--- | :--- | :--- |
| 🌸 | `Ctrl+C` | Delete **everything** typed (or stops generation) |
| 🌸 | `Ctrl+U`/`Ctrl+K` | Delete **before / after** cursor on line |
| 🌸 | `Ctrl+W`/`Alt+D` | Delete **previous / next** word |
| 🌸 | `Ctrl+Y` | **Paste back** what was deleted above |
| ok | `Alt+Y` | Cycle through paste history (after Ctrl+Y) |

## Cursor movement

| Key | Shortcut | What it does |
| :--- | :--- | :--- |
| 🌸 | `Ctrl+A` | Jump to **start** of line |
| ⚠️ | `Ctrl+E` | ~~Jump to **end** of line~~ |
| 🪲 | `Ctrl+E` | Search VSCode project by filename |
| ok | `Alt+B` | Move back **one word** |
| ok | `Alt+F` | Move forward **one word** |

## General controls

| Key | Shortcut | What it does |
| :--- | :--- | :--- |
| ok | `Ctrl+R` | Search prompt history. **Inside it,** `Ctrl+S` cycles scope (session → project → all) |
| 🌸 | `Ctrl+Q` | Unfreeze terminal after an accidental `Ctrl+S` (XOFF/XON freeze) |
| 🌸 | `Ctrl+L` | Redraw terminal window when garbled |
| 🌸 | `Ctrl+D` | Exit Claude Code |
| ⚠️ | `Ctrl+J` | ~~Insert newline without submitting~~ |
| 🪲 | `Ctrl+J`/`Ctrl+B` | VSCode hide **right / left panel** |

## Workflow: park a long prompt, send a quick one first

Typed a big multi-line prompt but need to fire off a short question first? Cut the
draft to the yank buffer, send the quick prompt, then paste the draft back — no mouse,
no manual copy.

1. **Cut it** — from the **end** of the input, press `Ctrl+U` repeatedly. Each press cuts from the cursor back to line-start, walking up through every line until the whole prompt is gone (and stored).
2. **Send your quick prompt** — type it, `Enter`.
3. **Paste the draft back** — `Ctrl+Y` restores the whole thing. `Alt+Y` cycles older cuts if you stashed more than one.

> `Ctrl+A` `Ctrl+K` does **not** work for this — `Ctrl+K` only kills the single line the cursor is on. Use repeated `Ctrl+U` for multi-line prompts.
>
> `Ctrl+E` does not work to take me to the end of big prompt, use arrow keys.

## Claude Code-specific actions

| Key | Shortcut | What it does |
| :--- | :--- | :--- |
| 🌸 | `Esc Esc` | Rewind conversation to a previous point |
| ok | `Alt+P` | Switch model without clearing your prompt |
| ok | `Alt+T` | Toggle extended thinking mode |
| ⚠️ | `Ctrl+G` | ~~Open current prompt in your external editor~~ |
| 🪲 | `Ctrl+G` | VSCode go to line number |
| ? | `Ctrl+O` | Toggle transcript viewer (shows tool calls, MCP) |

## My VSCode

| Key | Shortcut | What it does |
| :--- | :--- | :--- |
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
