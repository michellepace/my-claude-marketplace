# Task: Make Node.js LTS the default for every new zsh shell

## Goal

When I open a brand-new terminal, `node --version` should report the LTS
(currently `v24.14.1`), not `v25.8.2`. Once that is true, I want to safely
uninstall `v25.8.2`, install `markdownlint-cli2` globally on the LTS, and
verify this Next.js app still passes its full test suite (unit + E2E) on the
LTS.

## Environment (verified facts — please trust these)

- Shell: `zsh` at `/usr/bin/zsh`, running inside WSL2 (Ubuntu) on Windows.
- Node manager: `nvm`. Installations under `~/.nvm/versions/node/`:
  - `v24.14.1` — LTS ("lts/krypton"), contains only `npm` + `corepack`.
  - `v25.8.2`  — current stable, contains only `npm`.
- I already ran `nvm alias default 'lts/*'` and `nvm` confirmed it resolves to
  `v24.14.1`. Within the *same* shell after running it, `node --version`
  correctly reports `v24.14.1`. The problem only appears in **newly launched**
  shells.

## Reproduction

A freshly opened zsh window, no commands run beforehand:

<new_shell_problem>

```bash
$ echo $SHELL
/usr/bin/zsh
$ node --version
v25.8.2          # expected v24.14.1
```

</new_shell_problem>

## The most diagnostic clue I have

The same WSL Ubuntu user, with the same `~/.zshrc` and the same nvm install,
behaves *correctly* when the shell is launched from the Windows Terminal
"Ubuntu" tab instead of from my current launch path:

<ubuntu_tab_works>

```bash
$ node --version
v24.14.1
```

</ubuntu_tab_works>

Treat this asymmetry as your primary lead. Whatever is wrong is specific to
*how* my broken shells are being launched (login vs. interactive, parent
process environment, an inherited `PATH` entry, a sourced file that runs in
one path but not the other) — it is **not** a problem with `nvm`'s default
alias itself, because that alias is already correct.

## What I'd like you to do, in order

1. **Diagnose the root cause from a fresh broken shell**, not from my current
   one. Inspect the inherited environment and the zsh startup file chain
   (`/etc/zsh/*`, `~/.zshenv`, `~/.zprofile`, `~/.zshrc`, `~/.zlogin`, plus
   anything they `source`). Explain *why* `v25.8.2` ends up first on `PATH`
   in the broken launch path but not in the working one.
2. **Propose the smallest possible fix** and describe what it changes and why
   **before** editing anything under `~/`.
3. **After I approve the fix**, guide me through:
   1. Confirming a brand-new shell now reports `v24.14.1`.
   2. Checking whether `v25.8.2` has any globally-installed packages I would
      lose, then uninstalling it (`nvm uninstall v25.8.2`).
   3. `npm install -g markdownlint-cli2` on the LTS and confirming it runs.
   4. Running the full test suite for this Next.js app (`npm run test`,
      which covers Vitest + Playwright) and reporting any failure that looks
      Node-version related.

## Constraints

- I am a beginner with shell startup files. **Ask before** modifying anything
  under `~/` (`.zshrc`, `.zshenv`, `.zprofile`, `.profile`) or running
  anything destructive (`nvm uninstall`, `rm`, rewriting `PATH` exports,
  changing nvm aliases).
- Do **not** anchor on the guesses I have made (`printenv`, "it's the nvm.sh source line", etc.). They were beginner intuitions; investigate independently and only reference them if your own evidence supports them.
- Prefer read-only inspection (`printenv`, `echo $PATH`, reading startup
  files) over editing until the root cause is understood.

## Definition of done

- A new zsh window — opened by whatever launch path I normally use — reports
  `v24.14.1` from `node --version` with no manual `nvm use` step.
- `v25.8.2` is removed from `~/.nvm/versions/node/`.
- `markdownlint-cli2` is on `PATH` and runnable.
- `npm run test` completes, and any failures are explained as either
  unrelated to the Node upgrade or fixed.
