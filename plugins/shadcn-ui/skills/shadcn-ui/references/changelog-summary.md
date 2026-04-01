# shadcn/ui Changelog Summary (Jun 2025–Mar 2026)

Dense summary of key shadcn/ui changes beyond Claude Code's training data (Opus 4.6 knowledge cutoff: May 2025). Scoped to: Next.js 16 apps initialised with shadcn/ui from March 2026 onwards, Radix UI (not Base UI), LTR only.

## Jan–Mar 2026

CLI v4 released March 2026. Major additions: skills, presets, inspection flags, templates, new registry types.

### Skills & Agent Workflows

**shadcn/skills** gives coding agents context about components, Radix UI primitives, registry workflows, and the CLI (commands, flags, when to use them). Agents produce code that matches the project's design system with fewer mistakes.

Install (note: `skills` CLI, not `shadcn`):

```bash
npx skills add shadcn/ui
```

Example agent prompts skills enables:

- "create a new next app with a monorepo"
- "find me a hero from tailark, add it to the homepage, animate the text using an animation from react-bits"
- "install and configure a sign in page from @clerk"

Skills and presets work together — agents can scaffold projects using presets and switch design systems via prompts.

### Presets

A **preset** packs an entire design system config (colors, theme, icon library, fonts, radius) into a short code string. Build presets on `shadcn/create`, preview live, grab the code.

```bash
npx shadcn@latest init --preset a1Dg5eFl       # Scaffold with preset
npx shadcn@latest init --preset ad3qkJ7        # Switch preset mid-project (reconfigures everything incl. components)
```

Presets are portable across tools (Claude, Codex, v0, Replit) and shareable with teams. Drop in prompts so agents know the target design system.

### Inspection Flags

Inspect what a registry item will do before anything is written to disk:

```bash
npx shadcn@latest add button --dry-run          # Preview full registry payload
npx shadcn@latest add button --diff             # Show diff against local files (also checks for upstream updates)
npx shadcn@latest add button --view             # Review source code before installing
```

Use `--diff` to check for registry updates: `npx shadcn@latest add button --diff`. Or ask an agent: "check for updates from @shadcn and merge with my local changes".

### Templates, Info & Docs

**Templates** — `shadcn init` scaffolds full project templates. Dark mode included for Next.js:

```bash
npx shadcn@latest init --template next --base radix            # Next.js + Radix (default base)
npx shadcn@latest init --template next --base radix --monorepo # Monorepo setup
```

**`shadcn info`** — shows framework, version, CSS vars, installed components, and docs/examples links for every component. Useful for giving agents full project context.

**`shadcn docs <component>`** — retrieves docs, code, and examples from the CLI:

```bash
npx shadcn@latest docs combobox
# → docs URL + raw example file URL
```

### Registry Types

Two new first-class registry types:

**`registry:base`** — distributes an entire design system as a single payload: components, dependencies, CSS vars, fonts, config. One install, everything configured.

**`registry:font`** — fonts as registry items. Install and configure like components:

```bash
npx shadcn@latest add font-inter
```

Font schema includes: `family`, `provider`, `import`, `variable`, `subsets`.

### Blocks for Radix UI

All blocks (login, signup, sidebar, dashboard) are now available for Radix UI:

```bash
npx shadcn@latest add login-01
```

Browse the full collection at `/blocks`.

### Unified `radix-ui` Package

Components use the unified `radix-ui` package (not `@radix-ui/react-*`). See Jun–Dec 2025 section for import patterns and details.

## Jun–Dec 2025

### Visual Styles & `create` Command

`npx shadcn create` — full project customisation. Picks component library, icons, base color, theme, fonts and rewrites component code to match.

**5 visual styles:**

| Style | Character |
| :---- | :-------- |
| **Vega** | Classic shadcn/ui look |
| **Nova** | Compact variant of the classic look — reduced padding/margins, same proportions |
| **Maia** | Soft, rounded, generous spacing |
| **Lyra** | Boxy, sharp — pairs with mono fonts |
| **Mira** | Purpose-built for data-dense interfaces — minimal chrome, tight spacing |

Component library choice: **Radix UI** (default) or **Base UI** (alternative with same abstraction). CLI auto-detects library and applies the right transformations.

**Radix UI unified package**: As of June 2025, Radix UI ships as a single `radix-ui` package (not the old `@radix-ui/react-*` scoped packages). New projects use the unified import:

```tsx
import { AlertDialog } from "radix-ui"  // NOT @radix-ui/react-alert-dialog
import { Dialog } from "radix-ui"        // NOT @radix-ui/react-dialog
import { Popover } from "radix-ui"       // NOT @radix-ui/react-popover
```

The CLI handles this automatically when adding components, but any manual Radix usage must follow this format.

### New Components

Seven library-agnostic components. All import from `@/components/ui/<name>`.

| Component | Purpose | Key exports |
| :-------- | :------ | :---------- |
| **Spinner** | Loading indicator | `Spinner` |
| **Kbd** | Keyboard key display | `Kbd`, `KbdGroup` |
| **ButtonGroup** | Group buttons, split buttons | `ButtonGroup`, `ButtonGroupSeparator`, `ButtonGroupText` |
| **InputGroup** | Icons/buttons/labels on inputs | `InputGroup`, `InputGroupAddon`, `InputGroupInput` |
| **Field** | Complete form fields | `Field`, `FieldLabel`, `FieldDescription`, `FieldError`, `FieldGroup`, `FieldSet`, `FieldLegend` |
| **Item** | Flex container for lists/cards | `Item`, `ItemMedia`, `ItemContent`, `ItemTitle`, `ItemDescription`, `ItemGroup` |
| **Empty** | Empty state placeholder | `Empty`, `EmptyMedia`, `EmptyTitle`, `EmptyDescription`, `EmptyContent` |

Non-obvious patterns:

- **ButtonGroup**: nest `ButtonGroup` inside `ButtonGroup` for sub-groups with spacing. Use `ButtonGroupSeparator` for split button dropdowns. Combine `ButtonGroupText`, `Input`, and `Button` for input prefix/suffix.
- **InputGroup**: also works with `<Textarea>` (prompt forms, multi-line inputs) and `<Spinner>` inside addons.
- **Field**: works with React Hook Form, TanStack Form, Server Actions, or any form library. Use `FieldSet`/`FieldGroup` for multi-section forms. `orientation="responsive"` switches vertical/horizontal by container width. Wrap fields in `FieldLabel` for choice card pattern (selectable radio/checkbox cards).
- **Item**: `ItemMedia` supports `variant="icon"` plus avatars/images. Use `asChild` to render as a link. `ItemGroup` for consistent list styling.
- **Empty**: combine with `InputGroup` inside `EmptyContent` for search/subscribe empty states.

### Registry Ecosystem

The registry system evolved across three releases into a layered architecture:

**Namespaced registries** (Aug) — configure in `components.json`, install with `@namespace/name`:

```json
{
  "registries": {
    "@acme": "https://acme.com/r/{name}.json"
  }
}
```

```bash
npx shadcn add @acme/button
```

Decentralised — no central registrar. Supports private registries with auth (bearer tokens, API keys, custom headers):

```json
{
  "registries": {
    "@internal": {
      "url": "https://registry.company.com/{name}.json",
      "headers": {
        "Authorization": "Bearer ${REGISTRY_TOKEN}"
      }
    }
  }
}
```

Env vars referenced with `${VAR_NAME}` syntax — set in `.env` or `.env.local`.

Components can depend on items from different registries; the CLI resolves and installs from the right sources automatically:

```json
{
  "registryDependencies": [
    "@shadcn/card",
    "@v0/chart",
    "@acme/data-table"
  ]
}
```

**Registry index** (Sep) — community registry index at `https://ui.shadcn.com/r/registries.json`. Install from indexed registries without configuring `components.json`:

```bash
npx shadcn add @ai-elements/prompt-input
```

**Registry directory** (Nov) — browsable UI at `https://ui.shadcn.com/docs/directory`. Built into the CLI, no config required.

### CLI 3.0 & Local Files

**Discovery commands** (Aug):

```bash
npx shadcn view @acme/component        # Preview code + deps before install
npx shadcn search @registry -q "dark"  # Search a registry
npx shadcn list @registry              # List all items in a registry
```

**Local file support** (Jul) — init and add from local JSON files, no remote registry needed:

```bash
npx shadcn init ./template.json
npx shadcn add ./block.json
```

Enables local testing of registry items before publishing, and agent/MCP workflows that generate and run registry items locally.

**Universal registry items** (Jul) — registry items that can distribute code, config, rules, or docs to any project.

**Error handling** (Aug) — the CLI reports unknown registries, missing env vars, and auth failures with actionable fix instructions (also surfaces custom error messages from registry authors).

### MCP Server

```bash
npx shadcn@latest mcp init
```

Works with all registries, zero config. One command to add to any MCP client. Supports multiple registries in the same project.

### Deprecations

**Toast** does not exist in current shadcn/ui — use **Sonner** for all toast/notification needs. Do not use `@/components/ui/toast` or `useToast` (they are no longer part of shadcn/ui).

### Calendar

The `Calendar` component uses React DayPicker. 30+ ready-made calendar blocks are available — browse at `/blocks/calendar` and install with `npx shadcn add`.

## CLI Quick Reference

```bash
# Initialisation
npx shadcn init                    # Standard init
npx shadcn create                  # Customised init with visual styles
npx shadcn init ./template.json    # From local file
npx shadcn init --preset <code>    # Init with preset (colors, fonts, theme, radius)
npx shadcn init --template next    # Scaffold full project template
npx shadcn init --template next --monorepo  # Monorepo setup

# Components
npx shadcn add button              # Add component
npx shadcn add @registry/component # From namespaced registry
npx shadcn add ./component.json    # From local file
npx shadcn add font-inter          # Add font from registry

# Inspection
npx shadcn add button --dry-run    # Preview registry payload
npx shadcn add button --diff       # Check for updates/changes
npx shadcn add button --view       # Review source code

# Discovery
npx shadcn view component          # Preview component
npx shadcn search -q "term"        # Search components
npx shadcn list                    # List available

# Info & Docs
npx shadcn info                    # Project status, installed components
npx shadcn docs <component>        # Get docs, code, examples

# MCP
npx shadcn@latest mcp init         # Add MCP server to project

# Skills (separate CLI, not shadcn)
npx skills add shadcn/ui            # Give coding agents shadcn/ui context
```
