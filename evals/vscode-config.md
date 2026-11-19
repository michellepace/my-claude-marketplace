---
title: vscode-config evals
skill: plugins/alwayson-misc/skills/vscode-config/SKILL.md
skill-commit: b57713f
flags: --model claude-opus-5-5 --effort medium --permission-mode auto
result: pass
---

**Start directory:** this repo's root, from its VS Code terminal. Check answers against VS Code, not the skill: the window title, and the Extensions view of a window open in that profile (built-ins aside).

**Setup:** in this window, Disable one installed extension (profile-wide).

> /vscode-config which profile is this project in, and which extensions are enabled?

- [x] Names the profile in the window title
- [x] Lists the enabled extensions in the Extensions view, WSL included
- [x] Leaves out the disabled one and says it's disabled

> /vscode-config which extensions are in my Default profile?

- [x] Lists the enabled extensions in a Default window's Extensions view, WSL included

> /vscode-config which extensions are in my Markdown profile?

- [x] Lists the enabled extensions in a Markdown window's Extensions view, WSL included

> /vscode-config have I got VS Code settings specific to Claude Code, excluding extensions

- [x] Accurately answers from `/mnt/c/Users/mp/AppData/Roaming/Code/User/settings.json` and `/mnt/c/Users/mp/AppData/Roaming/Code/User/keybindings.json`
