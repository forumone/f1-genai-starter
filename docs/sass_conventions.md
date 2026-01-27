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

Any mixin in that directory can be used when needed. Below are examples of
some of the most-commonly used mixins. This is not a comprehensive list.

### Layout and Grid

```scss
@include css-fixed-grid($columns: 3, $gutter-width: gesso-get-map(gutter-width));
```

### Buttons and Links

```scss
@include button();           // Full button styles
@include text-button();      // Text-only button
@include link($link, $hover, $active, $visit);
```

### Focus States

```scss
@include focus($color: gesso-color(ui, generic, focus), $width: 2px, $offset: 2px);
```

### Lists

```scss
@include list-clean();       // Remove list styling
```

### Accessibility

```scss
@include visually-hidden();  // Screen reader only
```

### Typography

```scss
@include responsive-font-size($font-scale);  // Fluid typography with clamp()
@include display-text-style($style-name);
```

### Aspect Ratio

```scss
@include aspect-ratio($width, $height);
```

### Images

```scss
@include image-replace();
@include svg-background($svg-code);
@include svg-mask-image($svg-code);
```

### Responsive Breakpoints

```scss
@include breakpoint(gesso-breakpoint(desktop)) { }
@include breakpoint-max(gesso-breakpoint(mobile), true) { }
@include breakpoint-min-max(gesso-breakpoint(mobile), gesso-breakpoint(tablet), true) { }
```

### Container Queries

```scss
@include container-query($width) { }
@include container-query-max($width) { }
@include container-query-min-max($min, $max) { }
```

## Unit Conversion

**Always** use `rem()` for sizing values:

```scss
padding: rem(gesso-spacing(2));
margin-block-end: rem(16px);
font-size: rem(gesso-font-size(3));
```

Functions: `rem($value)`, `em($value)`, `px($value)`

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

## Config Settings

Available in `source/00-config/_config.settings.scss`:

```scss
$breakpoints-ems: true !default;      // Convert breakpoints to em
$container-queries-rems: true !default;
$support-for-rtl: true !default;      // Enable RTL support
$wysiwyg: false !default;             // WYSIWYG editor mode
```
