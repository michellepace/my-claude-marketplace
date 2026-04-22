# TASK: Determine the root cause of why `node` keeps reverting to v25.8.2

I develop Next.js 16+ applications and Vercel recommends to use `node` LTS. I am trying to clean my node installation up by
having only the `lts` as the default.

Verify my setup:

<setup_verify>

```text
 ~/.nvm/versions/node/
 ├── v24.14.1200 MB ← LTS ("lts/krypton"), clean (only npm + corepack), default alias target
 └── v25.8.2204 MB ← stable, currently active, clean (only npm)
```

<setup_verify>

Analyse what I did please:

<what_i_did>

```bash
~/projects/nextjs/devflow git:(chore/update-deps-and-docs) ✗
$ echo $SHELL
/usr/bin/zsh

$ node --version
v25.8.2

$ nvm use --lts # activate v24.14.1 in this shell
Now using node v24.14.1 (npm v11.11.0)

$ nvm alias default 'lts/*' # new shells default to whatever the current LTS is
default -> lts/* (-> v24.14.1)

$ node --version
v24.14.1
$ source ~/.zshrc
$ node --version
v24.14.1
```

</what_i_did>

The problem is that when I open new terminals, the node version reverts back to:

<new_shell>

```bash
~/projects/nextjs/devflow git:(chore/update-deps-and-docs) ✗
$ echo $SHELL
/usr/bin/zsh

$ node --version
v25.8.2
```

</new_shell>

What I suspect (but I am a beginner so don't trust me, just look):

<what_i_suspect>
- run `node --version` for yourself, I think you will also get v25.8.2 despite this being a new shell
- Read ~/.zshrc lines 74:86,~/.zshrc sources nvm.sh and i am unsure if this is related
- run `printenv` .. perhaps this is related?

Also strangely, in Windows > Powershell > ubuntu tab:

```bash
~
$ node --version
v24.14.1
```

Wow!! what's going on here!

That is all the ideas that I have, but I am a beginner, so please think deeply for yourself and logically.
</what_i_suspect>

Could you please determine the root cause so that `node` correctly defaults to LTS for all new shells.

I want to be able to:
- Safely remove: v25.8.2
- Install `npm install -g markdownlint-cli2`
- Verify the new LTS version works as expected for this next.js app (e.g. run the entire test suite including e2e tests)
