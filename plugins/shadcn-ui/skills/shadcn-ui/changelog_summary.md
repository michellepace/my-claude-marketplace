# shadcn/ui Changelog Summary (2025)

Post-knowledge-cutoff changes for Next.js apps. Most recent first.

## December 2025: `npx shadcn create`

New CLI command for full customisation:

- **5 visual styles**: Vega (classic), Nova (compact), Maia (soft/rounded), Lyra (boxy/sharp), Mira (dense)
- **Component library choice**: Radix UI or Base UI
- CLI rewrites component code to match config (fonts, spacing, structure)
- Works with Next.js, Vite, TanStack Start, v0

## November 2025: Registry Directory

- Browse registries at `https://ui.shadcn.com/docs/directory`
- No config required - built into CLI

## October 2025: New Components

Seven new components (library-agnostic):

| Component | Purpose | Key exports |
|-----------|---------|-------------|
| **Spinner** | Loading indicator | `Spinner` |
| **Kbd** | Keyboard key display | `Kbd`, `KbdGroup` |
| **ButtonGroup** | Group buttons, split buttons | `ButtonGroup`, `ButtonGroupSeparator`, `ButtonGroupText` |
| **InputGroup** | Icons/buttons/labels on inputs | `InputGroup`, `InputGroupAddon`, `InputGroupInput` |
| **Field** | Complete form fields | `Field`, `FieldLabel`, `FieldDescription`, `FieldError`, `FieldGroup`, `FieldSet`, `FieldLegend` |
| **Item** | Flex container for lists/cards | `Item`, `ItemMedia`, `ItemContent`, `ItemTitle`, `ItemDescription`, `ItemActions`, `ItemGroup` |
| **Empty** | Empty state placeholder | `Empty`, `EmptyMedia`, `EmptyTitle`, `EmptyDescription`, `EmptyContent` |

**Field component notes:**

- Works with React Hook Form, TanStack Form, Server Actions
- `orientation="responsive"` for responsive layouts
- Wrap in `FieldLabel` for choice card pattern

## September 2025: Registry Index

- Index of open-source community registries at `https://ui.shadcn.com/r/registries.json`
- Zero-config install: `npx shadcn add @ai-elements/prompt-input`
- Auto-added to `components.json` — no manual registry configuration needed

## August 2025: CLI 3.0 + MCP Server

**Namespaced registries:**

```json
{
  "registries": {
    "@acme": "https://acme.com/r/{name}.json",
    "@private": {
      "url": "https://registry.company.com/{name}",
      "headers": { "Authorization": "Bearer ${REGISTRY_TOKEN}" }
    }
  }
}
```

```bash
npx shadcn add @acme/button @private/auth-system
```

**New CLI commands:**

```bash
npx shadcn view @acme/component    # Preview before install
npx shadcn search @registry -q "dark"  # Search registry
npx shadcn list @registry          # List all items
npx shadcn@latest mcp init         # Add MCP server
```

## July 2025: Local File Support

```bash
npx shadcn init ./template.json
npx shadcn add ./block.json
```

## June 2025: radix-ui Migration

```bash
npx shadcn@latest migrate radix
```

Replaces `@radix-ui/react-*` imports with unified `radix-ui` package.

## June 2025: Calendar Upgrade

- Upgraded to latest React DayPicker
- 30+ calendar blocks at `/blocks/calendar`

## May 2025: Site Upgrade

- ui.shadcn.com now Next.js 15.3 + Tailwind v4
- Uses `new-york` style

## February 2025: Tailwind v4 + React 19

Critical changes:

| Change | Details |
|--------|---------|
| **Colours** | OKLCH format (not HSL) |
| **Styling** | `data-slot` attribute on every primitive |
| **Refs** | `forwardRef` removed |
| **Toast** | Deprecated, use Sonner |
| **Cursor** | Buttons use default cursor |
| **Style** | `default` deprecated, use `new-york` |
| **Theming** | `@theme` directive and `@theme inline` |

## CLI Quick Reference

```bash
# Initialisation
npx shadcn init                    # Standard init
npx shadcn create                  # Customised init (Dec 2025)
npx shadcn init ./template.json    # From local file

# Components
npx shadcn add button              # Add component
npx shadcn add @registry/component # From namespaced registry
npx shadcn add ./component.json    # From local file

# Discovery
npx shadcn view component          # Preview component
npx shadcn search -q "term"        # Search components
npx shadcn list                    # List available

# Migration
npx shadcn@latest migrate radix    # Migrate to radix-ui package

# MCP
npx shadcn@latest mcp init         # Add MCP server to project
```
