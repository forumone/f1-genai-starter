# AGENTS.md

## Project Overview
- Next.js 16 using the App Router with React Server Components
- Storybook
- TypeScript
- PostCSS with custom plugins
- ESLint
- Stylelint
- Prettier

## Common Commands

```bash
# Development (with ddev)
ddev start                        # Start local dev server
ddev frontend restart next        # Restart Next.js
ddev frontend restart storybook   # Restart Storybook

# Development (without ddev)
npm run dev                       # Start Next.js dev server
npm run storybook                 # Start Storybook on port 6006

# Quality checks (with ddev)
ddev frontend lint                # ESLint + Stylelint
ddev frontend prettier            # Check formatting
ddev frontend tsc                 # TypeScript check
ddev frontend prettier:write      # Fix formatting

# Quality checks (without ddev)
npm run lint                      # ESLint + Stylelint
npm run tsc                       # TypeScript check
npm run test                      # typegen + lint + tsc (runs on git commit via Husky)
npm run prettier                  # Check formatting
npm run prettier:write            # Fix formatting

# Build (with ddev)
ddev frontend build               # Production build

# Build (without ddev)
npm run build                     # Production build
npm run build-storybook           # Build Storybook

# Utilities (with ddev)
ddev frontend component           # Interactive component generator
ddev frontend icons               # Generate React components from SVGs in source/01-global/icon/svgs/

# Utilities (without ddev)
npm run component                 # Interactive component generator
npm run build-icons               # Generate React components from SVGs in source/01-global/icon/svgs/
```

## Project Structure

- `app/` - Next.js App Router pages and CMS integration code
- `source/` - UI components (CMS-agnostic, Storybook-displayable)
  - `00-config/` - CSS variables, mixins, breakpoints
  - `01-global/` - Base styles, typography, icons, HTML element styles
  - `02-layouts/` - Layout components (Constrain, Grid, Section, etc.)
  - `03-components/` - Reusable UI components
  - `04-templates/` - Page-level templates
  - `05-pages/` - Full page examples for Storybook
  - `06-utility/` - Frontend utilities and Storybook helpers
- `lib/` - Build scripts and custom PostCSS plugins
- `util/` - Runtime utility functions
- `starterkits/` - CMS-specific starter code (Drupal, WordPress)

## Reference Material
**IMPORTANT**: When working on features related to the topics below, ALWAYS read
the corresponding documentation in agent_docs/ for detailed context, implementation
patterns, and best practices.
