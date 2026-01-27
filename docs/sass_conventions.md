# Sass Conventions

## File Naming and Compilation

| Type | Filename Pattern | Behavior | Example |
|------|-----------------|----------|---------|
| Global style | `_name.scss` | Added to aggregate, compiles into main CSS | `_card.scss` |
| Component library | `name.scss` (no underscore) | Compiles to separate CSS file | `accordion.scss` |

- All filenames must be unique across directories
- All SCSS files start with `@use '00-config' as *;`
- Use `@use 'sass:math';` when math operations needed

## CSS Class Conventions

| Type | Prefix | Example |
|------|--------|---------|
| Layout | `l-` | `l-grid`, `l-constrain` |
| Component | `c-` | `c-button`, `c-card` |
| Utility | `u-` | `u-align-center`, `u-spaced-2` |

### BEM Pattern

```scss
.c-card { }              // Block
.c-card__title { }       // Element
.c-card--feature { }     // Modifier
```

### Placeholder Classes

Use `%` prefix for extendable shared styles:

```scss
%c-button {
  @include button();
}

.c-button {
  @extend %c-button;
}
```

Do not use Sass `@extend` to extend non-placeholder classes.

## Aggregate Files

Each directory has `_index.scss` that imports all modules:

```scss
// 03-components/_index.scss
$wysiwyg: false !default;

@use 'button/button';
@use 'card/card';
// ...
```

When creating a new global style file, add it to the directory's `_index.scss`.

## Component File Structure

Standard pattern for component SCSS:

```scss
// Component: Card

@use '00-config' as *;

// Local variables
$card-padding: rem(gesso-spacing(3));
$card-border-color: gesso-color(ui, generic, accent);

.c-card {
  padding: $card-padding;
  border-block-end: 4px solid $card-border-color;
}

.c-card__title {
  margin-block-end: rem(gesso-spacing(1));
}

.c-card--feature {
  @include breakpoint(gesso-breakpoint(desktop)) {
    flex-direction: row;
  }
}
```

## Available Mixins

Location: `source/00-config/mixins/`

Any mixin in that directory can and should be used wherever needed.

### Unit Conversion

**Always** use `rem()` for sizing values:

```scss
padding: rem(gesso-spacing(2));
margin-block-end: rem(16px);
font-size: rem(gesso-font-size(3));
```

### Breakpoint Mixins

Location: `source/00-config/mixins/_breakpoint.scss`

Prefer breakpoint mixins to hard-coding media queries. Prefer using min-width
queries (mobile first) over max-width queries.

### Typography Mixin

Location: `source/00-config/mixins/_responsive-font-size.scss`

```scss
@include responsive-font-size($font-scale)  // Fluid typography using clamp()
```

## Logical Properties (RTL Support)

Use CSS logical properties instead of physical directions:

| Physical | Logical |
|----------|---------|
| `margin-top` | `margin-block-start` |
| `margin-bottom` | `margin-block-end` |
| `margin-left` | `margin-inline-start` |
| `margin-right` | `margin-inline-end` |
| `top` | `inset-block-start` |
| `left` | `inset-inline-start` |
| `text-align: left` | `text-align: start` |

## Design Token Access

See `/docs/design-tokens.md` for:
- Token accessor functions (`gesso-color()`, `gesso-spacing()`, etc.)
- Breakpoint values
- Typography tokens
- Color system

## Utility Class Generation

Pattern for generating utility classes from design tokens:

```scss
$sizes: 0.5, 1, 1.5, 2, 2.5, 3, 4, 5;

@each $size in $sizes {
  .u-spaced-#{escape-number($size)} {
    margin-block-end: #{rem(gesso-spacing($size))} !important;
  }
}
```
