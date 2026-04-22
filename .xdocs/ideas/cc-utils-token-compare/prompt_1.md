Please confirm if this is true:

```text
  ~/.nvm/versions/node/
  ├── v24.11.0  475 MB← old, has globals: vercel, npm-check-updates
  ├── v24.12.0  481 MB← old, has globals: @anthropic-ai, @shopify, vercel, markdownlint-cli2
  ├── v24.14.1  200 MB← current LTS ("lts/krypton") — clean
  └── v25.8.2204 MB← currently active (default), clean
```

---

TASK: Investigate why my shell is NOT defaulting to `lts`

I set the default to  `lts/*` in a previous shell, I used the alias lts/* (rather than pinning v24.14.1) means future nvm install --lts upgrades automatically. This is a new shell, so it is strange that you are seeing version v25.8.2. I get the same results in a new `zsh` shell:
<results>
```
~/projects/nextjs/devflow git:(chore/update-deps-and-docs) ✗
$ echo $SHELL
/usr/bin/zsh

~/projects/nextjs/devflow git:(chore/update-deps-and-docs) ✗
$ node --version
v25.8.2
```
</results>

Could you please determine the root cause as to why this is?

Start by reading: ~/.zshrc
