# CSS Conventions

This file provides information about the CSS architecture and usage.

## CSS Architecture

### PostCSS
PostCSS processes CSS with standard and custom plugins (see `postcss.config.js`).
Key Plugins:
- `postcss-advanced-variables` - Sass-like `@import`, `@mixin`, `@include`, `@if`, `@for`, `@each`
- `lib/iff.js` - Custom `iff()` function for conditional values
- `lib/responsive-font-size.js` - `responsive-font-size()` function for fluid typography
- `postcss-preset-env` - Modern CSS features (custom media queries enabled)
- `postcss-rem` - Automatic px to rem conversion. Provides `rem-convert()` function

### CSS Variables
CSS variables are defined in `source/00-config/vars/` and organized by category:

#### Palette (`palette.css`)
Raw color values. These are not typically used directly—use semantic color tokens from `colors.css` instead.

#### Semantic Colors (`colors.css`)
Contextual color tokens that reference palette colors. Use these in components.
 
You can add additional contextual color tokens where needed when creating or 
updating components.

### Mixins
`postcss-advanced-variables` allows for Sass-like mixins. Mixins are located in `source/00-config/mixins/`.
Project configuration allows shorthand imports: `@import "mixins";` resolves to `/source/00-config/mixins.css`.

### Linting
**IMPORTANT**: Linting with Stylelint must pass without errors or warnings for any CSS task to be considered complete

## CSS Styleguide
### Class naming
- Use **kebab-case** for CSS class names, NOT camelCase (even with CSS modules)
  - Example: `.content-type` NOT `.contentType`
- Variations use `--` between base class name and variant name
  - Example: `.component--variation`

### CSS Rules
Always use CSS logical properties instead of physical directions.

### Breakpoints
Defined in `source/00-config/vars/breakpoints.css` using custom media queries
Max-width variants are also available (e.g., `--tablet-max`, `--desktop-max`).
Use existing media queries where relevant. Otherwise, use the modern breakpoint syntax:

BEST
```css
@media (--desktop) {}
```
ACCEPTABLE
```css
@media (width >= 1024px) {}
```
AVOID
```css
@media (min-width: 1024px) {}
```

## Example CSS Structure
```css
@layer components {
  .wrapper {
    --local-var: value;
    background-color: var(--ui-background);
    display: flex;
    padding-block: var(--spacing-2-5);
    padding-inline: var(--spacing-4);
  }

  .wrapper--primary {
    background-color: var(--ui-accent);
  }

  .title {
    color: var(--text-primary);
    font-size: var(--responsive-font-size-8);
  }
}
```
