---
title: Design Tokens
description: Read when working with colors, spacing, typography
---

## Source of Truth

`source/00-config/config.design-tokens.yml`

### Reference System

Semantic colors can reference palette colors:
```yaml
colors:
  link: brand.blue.base  # Resolves to palette.brand.blue.base value
```

## Sass Access

Generated artifact: `source/00-config/_design-tokens.artifact.scss` (contains `$gesso` map)

### Accessor Functions

Location: `source/00-config/functions/_gesso.scss`

**Always** use accessor functions. Do not hard-code values that match a design token.

## JavaScript Access

Generated artifact: `source/00-config/_GESSO.es6.js`

Generates named exports for each category.

## Special Features

### SassValue Tag

Inject raw Sass code with CSS value fallback:
```yaml
custom-value: !sass
  sass: 'custom-function(arg1, arg2)'
  fallback: '#ffffff'
```
