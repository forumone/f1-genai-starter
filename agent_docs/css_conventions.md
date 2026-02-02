# CSS Conventions

This file provides information about the CSS architecture and usage.

## CSS Architecture

### PostCSS
PostCSS processes CSS with standard and custom plugins (see `postcss.config.js`).
Key Plugins:
- `postcss-advanced-variables` - Sass-like `@import`, `@mixin`, `@include`, `@if`, `@for`, `@each`
- `lib/iff.js` - Custom `iff()` function for conditional values
- `lib/responsive-font-size.js` - `responsive-font-size()` function for fluid typography
- `postcss-nesting` - CSS nesting support
- `postcss-preset-env` - Modern CSS features (custom media queries enabled)
- `postcss-rem` - Automatic px to rem conversion. Provides `rem-convert()` function

### CSS Variables
CSS variables are defined in `source/00-config/vars/` and organized by category:

#### Palette (`palette.css`)
Raw color values. These are not typically used directly—use semantic color tokens from `colors.css` instead.
- `--brand-{color}-{shade}` - Brand colors (e.g., `--brand-blue-base`, `--brand-blue-dark`)
- `--grayscale-{name}` - Grayscale (e.g., `--grayscale-white`, `--grayscale-gray-1` through `--grayscale-gray-7`)
- `--other-{color}-{shade}` - Utility colors (e.g., `--other-red-base`, `--other-yellow-light`)

#### Semantic Colors (`colors.css`)
Contextual color tokens that reference palette colors. Use these in components:
- `--background-{context}` - Background colors (e.g., `--background-site`)
- `--button-{property}-{state}` - Button colors (e.g., `--button-background-hover`)
- `--text-{context}` - Text colors (e.g., `--text-primary`, `--text-link`)
- `--ui-{context}` - UI elements (e.g., `--ui-accent`, `--ui-border`, `--ui-background`)
- `--form-{property}` - Form elements (e.g., `--form-background`, `--form-border`)
- `--table-{property}` - Table styles (e.g., `--table-background`, `--table-border`)
- `--selection-{property}`, `--mark-{property}` - Selection/highlight colors
 
You can add additional contextual color tokens where needed when creating or 
updating components.


#### Spacing (`spacing.css`)
- `--spacing-{n}` - Spacing scale: 0, 0-5, 1, 1-5, 2, 2-5, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15
- `--gutter-width` - Grid gutter width
- `--site-margins` - Site margins (responsive)

#### Typography (`typography.css`)
- `--font-family-{name}` - Font stacks (e.g., `--font-family-system`, `--font-family-monospace`)
- `--font-size-{n}` - Fixed font sizes (1-15)
- `--responsive-font-size-{n}` - Fluid font sizes (1-15), preferred for most text
- `--font-weight-{name}` - Weights: `light`, `regular`, `semibold`, `bold`
- `--letterspacing-{name}` - Letter spacing: `tight`, `normal`, `wide`
- `--line-height-{name}` - Line heights: `shortest`, `short`, `base`, `tall`, `taller`, `tallest`

#### Layout (`constrain.css`)
- `--constrain-{size}` - Max-width constraints: `sm`, `md`, `lg`

#### Animation (`duration.css`, `easing.css`)
- `--duration-{name}` - Durations: `shortest`, `short`, `standard`, `long`, `intro`, `outro`
- `--easing-{name}` - Easing: `ease-in-out`, `ease-out`, `ease-in`, `sharp`

#### Effects (`box-shadow.css`)
- `--box-shadow-{n}` - Elevation shadows (0-5, where 0 is none)

### Mixins
`postcss-advanced-variables` allows for Sass-like mixins. Mixins are located in `source/00-config/mixins/`.
Project configuration allows shorthand imports: `@import "mixins";` resolves to `/source/00-config/mixins.css`.

### Linting
- Stylelint enforces alphabetical property ordering.
- **IMPORTANT**: Linting with Stylelint must pass without errors or warnings for any CSS task to be considered complete

## CSS Styleguide
### Class naming
- Use **kebab-case** for CSS class names, NOT camelCase (even with CSS modules)
  - Example: `.content-type` NOT `.contentType`
- Variations use `--` between base class name and variant name
  - Example: `.component--variation`

### CSS Rules
- ALWAYS use CSS logical properties (e.g., `padding-inline`, `padding-block`) instead of directional properties
- When block-size and inline-size differ, write them separately (never use shorthand):
  ```css
  /* CORRECT */
  padding-block: var(--spacing-5);
  padding-inline: var(--spacing-2-5);

  /* INCORRECT */
  padding: var(--spacing-5) var(--spacing-2-5);
  ```
- Order CSS properties alphabetically. CSS custom properties/CSS variables are listed first, followed by all other CSS properties.
- Use existing CSS variables where possible

### Breakpoints
Defined in `source/00-config/vars/breakpoints.css` using custom media queries:
```css
@media (--mobile) {}      /* >= 320px */
@media (--mobile-lg) {}   /* >= 480px */
@media (--tablet) {}      /* >= 640px */
@media (--tablet-lg) {}   /* >= 880px */
@media (--desktop) {}     /* >= 1024px */
@media (--desktop-lg) {}  /* >= 1200px */
@media (--widescreen) {}  /* >= 1400px */
```
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
