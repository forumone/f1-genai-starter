# Sass Conventions

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

## Logical Properties

Always use CSS logical properties instead of physical directions.
