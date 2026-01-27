# Design Tokens

## Source of Truth

`source/00-config/config.design-tokens.yml` - Single YAML file with all tokens under `gesso` root key.

### Token Categories

- `palette` - Brand colors (blue, ocean-blue, grayscale, etc.)
- `colors` - Semantic color mappings (text, background, buttons, forms, UI states)
- `breakpoints` - Responsive breakpoints (mobile, tablet, desktop, etc.)
- `typography` - Font families, sizes, weights, line-heights, display styles
- `spacing` - Size scale (0-15 plus fractional values like 0.5, 1.5)
- `box-shadow` - Shadow definitions (0-5 levels)
- `constrains` - Container width constraints (sm, md, lg)
- `transitions` - Easing curves and durations
- `z-index` - Layering values
- `gutter-width`, `site-margins` - Layout spacing

### Reference System

Semantic colors can reference palette colors:
```yaml
colors:
  link: brand.blue.base  # Resolves to palette.brand.blue.base value
```

## Build Pipeline

```
config.design-tokens.yml
  → lib/configLoader.cjs (Webpack loader)
    → lib/readSource.cjs (Parse YAML with custom tags)
    → lib/transform.cjs (Resolve references)
    → lib/renderSass.cjs → source/00-config/_design-tokens.artifact.scss
    → lib/renderJs.cjs → source/00-config/_GESSO.es6.js
```

Webpack configs: `webpack.theme-config.js`, `.storybook/main.js`

Build commands:
- `ddev gesso build` - Compile once
- `ddev gesso watch` - Watch and recompile

## Sass Access

Generated artifact: `source/00-config/_design-tokens.artifact.scss` (contains `$gesso` map)

### Accessor Functions

Location: `source/00-config/functions/_gesso.scss`

```scss
gesso-color($keys...)        // gesso-color(text, primary)
gesso-spacing($keys...)      // gesso-spacing(2)
gesso-breakpoint($keys...)   // gesso-breakpoint(desktop)
gesso-font-family($ff-type)  // gesso-font-family(primary)
gesso-font-size($keys...)    // gesso-font-size(2)
gesso-font-weight($keys...)  // gesso-font-weight(bold)
gesso-line-height($keys...)  // gesso-line-height(base)
gesso-z-index($keys...)      // gesso-z-index(modal)
gesso-duration($keys...)     // gesso-duration(short)
gesso-easing($keys...)       // gesso-easing(ease-in-out)
gesso-box-shadow($keys...)   // gesso-box-shadow(1)
gesso-constrain($keys...)    // gesso-constrain(lg)
gesso-get-map($map-key, $keys...) // Generic accessor
map-deep-get($map, $keys...)      // Navigate nested maps
```

### Unit Conversion Functions

Location: `source/00-config/functions/_unit-convert.scss`

```scss
rem($value, $base: 16px)  // Convert to rem
em($value, $base: 16px)   // Convert to em
px($value, $base: 16px)   // Convert to px
```

### Breakpoint Mixins

Location: `source/00-config/mixins/_breakpoint.scss`

```scss
@include breakpoint(gesso-breakpoint(desktop)) { }           // min-width
@include breakpoint-max(gesso-breakpoint(mobile), true) { }  // max-width (true = -1px)
@include breakpoint-min-max($min, $max, $subtract: false) { }
```

### Container Query Mixins

```scss
@include container-query($width) { }
@include container-query-max($width) { }
@include container-query-min-max($min, $max) { }
```

### Typography Mixin

Location: `source/00-config/mixins/_responsive-font-size.scss`

```scss
@include responsive-font-size($font-scale)  // Fluid typography using clamp()
```

## JavaScript Access

Generated artifact: `source/00-config/_GESSO.es6.js`

Named exports for each category:
```javascript
import { BREAKPOINTS, COLORS, SPACING, TYPOGRAPHY, PALETTE, Z_INDEX, TRANSITIONS, BOX_SHADOW, CONSTRAINS, GUTTER_WIDTH, SITE_MARGINS } from '../00-config/_GESSO.es6';
```

## Special Features

### SassValue Tag

Inject raw Sass code with JS fallback:
```yaml
custom-value: !sass
  sass: 'custom-function(arg1, arg2)'
  fallback: '#ffffff'
```

### File Conventions

- All SCSS files start with `@use '00-config' as *;`
- Artifact files are gitignored and auto-generated
- Do not edit `_design-tokens.artifact.scss` or `_GESSO.es6.js` directly

## Key Files

| Purpose | Path |
|---------|------|
| Token definitions | `source/00-config/config.design-tokens.yml` |
| Webpack loader | `lib/configLoader.cjs` |
| YAML parser | `lib/readSource.cjs` |
| Reference resolver | `lib/transform.cjs` |
| Sass renderer | `lib/renderSass.cjs` |
| JS renderer | `lib/renderJs.cjs` |
| Sass artifact | `source/00-config/_design-tokens.artifact.scss` |
| JS artifact | `source/00-config/_GESSO.es6.js` |
| Sass functions | `source/00-config/functions/_gesso.scss` |
| Unit functions | `source/00-config/functions/_unit-convert.scss` |
| Breakpoint mixins | `source/00-config/mixins/_breakpoint.scss` |
