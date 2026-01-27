# Gesso Drupal Theme

## Project Overview
- Drupal 10/11 theme
- Sass
- Storybook
- ESLint
- Stylelint

## Build Commands

```bash
ddev gesso install                  # Install dependencies
ddev gesso watch                    # Build, start Storybook (localhost:6006), and watch for changes
ddev gesso build                    # Production build only (no watch)
ddev gesso deploy                   # Build Storybook to static directory
ddev gesso npm run component        # Generate boilerplate for a new component (interactive)
ddev gesso stylelint                # Lint SCSS files
ddev gesso eslint                   # Lint JS files
```

**Important:** Restart `ddev gesso watch` when adding new SCSS or JS files - webpack won't pick them up automatically.

**Important:** All relative paths (e.g. `source/`) are relative to the root of the theme directory.

## Source Directory Structure (`source/`)
- `00-config/` - Design tokens (`config.design-tokens.yml`), Sass functions, mixins
- `01-global/` - Base HTML element styles, typography, colors, spacing
- `02-layouts/` - Page layout components (use `l-` CSS prefix)
- `03-components/` - Reusable UI components (use `c-` CSS prefix)
- `04-templates/` - Page-level template compositions
- `05-pages/` - Full page examples for Storybook
- `06-utility/` - Utility classes
- `07-react/` - React components (compiled separately)

### Twig Namespaces
Configured in `gesso.info.yml` and `.storybook/main.js`:
- `@global` → `source/01-global`
- `@layouts` → `source/02-layouts`
- `@components` → `source/03-components`
- `@templates` → `source/04-templates`

## Design Tokens
Read `/docs/design_tokens.md` when you need to work with theme design tokens.

## Sass Conventions
Read `/docs/sass_conventions.md` when you need to work with Sass files.

## JavaScript Conventions
Read `/docs/drupal_js_conventions.md` when you need to work with JavaScript or TypeScript.

## Storybook Conventions
Read `/docs/storybook_drupal.md` when you need to work with Storybook stories.


