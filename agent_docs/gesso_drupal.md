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

## Reference Material
**IMPORTANT**: When working on features related to the topics below, ALWAYS read
the corresponding documentation in agent_docs/ for detailed context, implementation
patterns, and best practices.

| Topic | Document | Read before... |
|-------|----------|----------------|
| **Gesso Overview** | [agent_docs/gesso_drupal.md](agent_docs/gesso_drupal.md) | Any theme work |
| **Sass** | [agent_docs/sass_conventions.md](agent_docs/sass_conventions.md) | Writing SCSS files |
| **JavaScript** | [agent_docs/drupal_js_conventions.md](agent_docs/drupal_js_conventions.md) | Writing JS in theme |
| **Storybook** | [agent_docs/storybook_drupal.md](agent_docs/storybook_drupal.md) | Creating stories |
| **Design Tokens** | [agent_docs/design_tokens.md](agent_docs/design_tokens.md) | Working with colors, spacing, typography |
| **Twig** | [agent_docs/drupal_twig.md](agent_docs/drupal_twig.md) | Working with Twig or template fields |
