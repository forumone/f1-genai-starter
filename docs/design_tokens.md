# Design Tokens

## Source of Truth

`source/00-config/config.design-tokens.yml` - Single YAML file with all tokens under `gesso` root key.

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

Always use accessor functions. Do not hard-code values that match a design token.

## JavaScript Access

Generated artifact: `source/00-config/_GESSO.es6.js`

Generates named exports for each category.

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
