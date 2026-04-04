---
name: nextjs-shadcn-ui
description: Best practices for building UIs with shadcn/ui components (Radix UI + Tailwind CSS). Use when adding and customising components, or architecting component structures in Next.js. Covers modifying components/ui/ primitives, CVA variants, reusable compositions, a customisation decision framework, and recent summarised changelog for new functionality.
user-invocable: true
disable-model-invocation: false
allowed-tools:
  - Glob
  - Grep
  - Read
  - mcp__Ref__read_url
  - mcp__Ref__search_documentation
---

# shadcn/ui Skill

shadcn/ui is a collection of beautifully-designed, accessible components and a code distribution platform built with TypeScript, Tailwind CSS, and Radix UI primitives.

## Important Changes (post May 2025)

**Current practices:**

- OKLCH colours (not HSL)
- `data-slot` attributes on primitives
- Forms: `<Field />` + TanStack Form + Zod
- Radix imports: `import { Dialog } from "radix-ui"` (not `@radix-ui/react-dialog`)

**Deprecated:**

- Toast → use **Sonner**
- `<Form />` → use `<Field />` pattern

**Added:**

| Component | Purpose |
| :-------- | :------ |
| `<Spinner />` | Loading state indicator |
| `<Kbd />` | Keyboard key display (with KbdGroup for combinations) |
| `<ButtonGroup />` | Related buttons, split button support |
| `<InputGroup />` | Icons, buttons, labels around inputs |
| `<Item />` | Flex container for lists/cards (with ItemMedia, ItemContent, ItemTitle) |
| `<Empty />` | Empty state component (with EmptyMedia, EmptyTitle, EmptyDescription) |

## CLI Commands

Commands for an already-initialised project.

```bash
npx shadcn@latest --help                  # CLI help
npx shadcn@latest list @shadcn            # List all available components
npx shadcn@latest search @shadcn -q "nav" # Search components by query
npx shadcn@latest view button card        # Preview code before installing
npx shadcn@latest add <component>         # Add component to project
npx shadcn@latest add button --overwrite  # Overwrite existing component
npx shadcn@latest add @v0/<block>         # Add from v0.dev registry
npx shadcn@latest diff                    # Check for upstream registry updates
```

## Best Practices

### Styling & Theming

Apply Tailwind mobile-first and utility-first design.

- Utility classes for layout (margin, padding, flex, grid, etc)
- **Variants** for visual styling (colours, borders, shadows)
- Never hardcode colours — use semantic tokens (`bg-primary`, not `bg-blue-600`)
- Centralised tokens in `app/globals.css`
- Minimise custom CSS — prefer Tailwind utilities for maintainability and visual consistency
- Light/dark mode implemented with `next-themes`

**Good:** `<Button variant="secondary" className="w-full gap-2">`
**Avoid:** `<Button className="bg-blue-600 text-white">`

### Extending with Variants

Add variants directly via CVA with semantic tokens:

```tsx
const buttonVariants = cva("inline-flex items-center justify-center ...", {
  variants: {
    variant: {
      default: "bg-primary text-primary-foreground hover:bg-primary/90",
      soft: "bg-card text-card-foreground hover:opacity-90", // Custom
    },
  },
});
```

**Key:** Variants belong in component files via CVA, not as className logic at call sites.

### Composition Pattern

Use compound components (Radix style). Build UI by composing primitives together:

```tsx
<DropdownMenu>
  <DropdownMenuTrigger>Open</DropdownMenuTrigger>
  <DropdownMenuContent>
    <DropdownMenuItem>Profile</DropdownMenuItem>
  </DropdownMenuContent>
</DropdownMenu>
```

### Pure UI Components

UI components handle rendering only. Keep API calls and business logic in hooks or server actions.

### Server Components

Interactive shadcn/ui components include `"use client"` automatically. Push client boundaries down — wrap only the interactive parts.

**Interleave server content inside client wrappers:**

```tsx
// page.tsx (Server Component)
export default async function Page() {
  const user = await getUser();
  return (
    <Sheet>
      <SheetContent>
        <UserProfile user={user} /> {/* Server-rendered */}
      </SheetContent>
    </Sheet>
  );
}
```

Children passed to client components can still be server-rendered.

**Config:** `"rsc": true` in `components.json` (default).

### Forms

Use `<Field />` component + TanStack Form + Zod for validation

## Customisation Hierarchy

When customising shadcn components, prefer approaches higher in this list:

1. **className** — One-off layout/spacing; check `globals.css` for existing variables first
2. **Existing props/variants** — Use what the primitive already offers
3. **New props on primitive** — When exposing internal configuration (e.g., CSS variables) cleanly
4. **New variants (CVA)** — When you need reusable predefined options
5. **CSS variables in globals.css** — Only for values used across multiple components

## Component Architecture

shadcn/ui uses a two-layer model: **primitives** define mechanisms, **compositions** provide values. Understanding this separation prevents common mistakes.

```text
components/
  ui/                      ← Primitives (shadcn installs here)
    button.tsx                 Add variants, props, default styles
    sidebar.tsx                Expose internal config (e.g., width prop)
    card.tsx                   Adjust spacing, borders, semantic tokens

  navigation/              ← Compositions (you create these)
    left-sidebar.tsx           Uses Sidebar with width="13rem", app menu items
    mobile-nav.tsx             Uses Sheet + NavigationMenu

  auth/                    ← Compositions (you create these)
    login-form.tsx             Uses Button, Input, Card with app logic
```

### Organisation Philosophy

Pragmatic atomic design — focus on composability without strict categorisation:

- `ui/` — shadcn primitives (atoms/molecules, rarely touched)
- `{feature}/` — feature-specific compositions
- `shared/` — cross-feature compositions (only when genuinely reused)
- Root — occasional one-off files that don't fit elsewhere

**Avoid premature abstraction.** Don't create `components/molecules/` or `components/organisms/` folders. If a composition is only used in one feature, keep it there. Move to `shared/` only when a second feature needs it.

### Primitives (`components/ui/`)

Installed by shadcn CLI. **Modify directly** for general-purpose improvements.

**✅ Modify when:**

- Adding props that ANY usage would benefit from
- Adding reusable variants via CVA
- Exposing internal CSS variables as typed props
- Adapting to the project's design system

**❌ Don't modify for:**

- App-specific content (menu items, labels, icons)
- Hardcoded values only one component needs
- Business logic or data fetching

### Compositions (`components/{feature}/`)

YOUR components that USE primitives. App-specific content and configuration lives here.

**✅ Create when:**

- Combining primitives with app-specific content
- Configuring primitives for a specific use case (passing specific prop values)
- Adding business logic around UI

**❌ Don't create thin wrappers** that just pass props through — modify the primitive instead.

```tsx
// ❌ Thin wrapper — just adds indirection
function AppSidebar(props) {
  return <Sidebar {...props} />
}

// ✅ Either modify the primitive, or create a meaningful composition
function LeftSidebar() {
  return (
    <Sidebar width="13rem" collapsible="icon">
      <SidebarHeader>...</SidebarHeader>
      <NavLinks />
    </Sidebar>
  )
}
```

## References

Read these when you need to look up component names, docs URLs, or recent API changes:

- **Component index** — all available components with docs URLs: `references/llms-txt.md`
- **Changelog summary** — CLI, registry, and component changes after May 2025 (beyond your training data): `references/changelog-summary.md`
