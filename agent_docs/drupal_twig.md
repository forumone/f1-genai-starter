# Drupal Twig Templates

## Naming Conventions

Templates follow Drupal's theme hook suggestion pattern:

```
[base-hook]--[suggestion].html.twig
```

Examples:
- `node--article.html.twig` — Article content type
- `node--article--teaser.html.twig` — Article in teaser view mode
- `field--node--body.html.twig` — Body field on nodes
- `block--system-branding-block.html.twig` — Specific block

More specific suggestions take priority over general ones.

## File Locations

| Location | Purpose |
|----------|---------|
| `web/themes/[theme]/templates/` | Theme template overrides |
| `web/modules/custom/[module]/templates/` | Module-provided templates |
| `web/core/modules/[module]/templates/` | Core defaults (don't edit) |

## Essential Variables

Always include these in templates:

```twig
{# Attributes on wrapper element #}
<article{{ attributes }}>

  {# Contextual links support #}
  {{ title_prefix }}
  <h2>{{ label }}</h2>
  {{ title_suffix }}

  {{ content }}
</article>
```

- `attributes` — HTML attributes object (classes, IDs, data attributes)
- `title_prefix` / `title_suffix` — Required for contextual links

## Attributes Object

```twig
{# Print all attributes #}
<div{{ attributes }}>

{# Add classes #}
<div{{ attributes.addClass('my-class', 'another-class') }}>

{# Set attribute #}
<div{{ attributes.setAttribute('role', 'navigation') }}>

{# Remove attribute #}
<div{{ attributes.removeAttribute('id') }}>

{# Create new attribute object #}
{% set my_attributes = create_attribute() %}
{% set my_attributes = my_attributes.addClass('custom') %}
<div{{ my_attributes }}>
```

## Including Templates

```twig
{# Basic include #}
{% include '@components/card/card.twig' %}

{# Include with variables #}
{% include '@components/card/card.twig' with {
  title: node.label,
  body: content.body,
} %}

{# Include with only specified variables #}
{% include '@components/card/card.twig' with {
  title: 'Hello',
} only %}
```

Use `include` unless you need to override blocks (then use `embed`).

## Twig Namespaces

When configured in the theme (check `*.info.yml`):

```twig
{% include '@components/button/button.twig' %}
{% include '@layouts/grid/grid.twig' %}
{% include '@global/icon/icon.twig' %}
```

## Common Patterns

### Conditional Classes

```twig
<div{{ attributes.addClass(
  'c-card',
  featured ? 'c-card--featured',
  image ? 'c-card--has-image'
) }}>
```

### Looping with Index

```twig
{% for item in items %}
  <div class="item item--{{ loop.index }}">
    {{ item }}
  </div>
{% endfor %}
```

### Rendering Fields

```twig
{# Render entire field with wrappers #}
{{ content.field_image }}

{# Render field value only #}
{{ content.field_image|render|striptags }}

{# Check if field has value #}
{% if content.field_image|render|striptags|trim %}
  {{ content.field_image }}
{% endif %}
```

### Trans for Translatable Strings

```twig
{% trans %}Submit{% endtrans %}

{% trans %}
  Hello {{ name }}
{% endtrans %}
```

## Debugging

Enable Twig debugging in `sites/development.services.yml`:

```yaml
parameters:
  twig.config:
    debug: true
    cache: false
```

Then clear cache: `ddev drush cache:rebuild`

Debug output shows:
- Template file path
- Available template suggestions
- Template variables

```twig
{# Dump a variable #}
{{ dump(content) }}

{# Dump all variables #}
{{ dump() }}
```

## Template Suggestions

With debugging enabled, view page source to see:

```html
<!-- THEME DEBUG -->
<!-- THEME HOOK: 'node' -->
<!-- FILE NAME SUGGESTIONS:
   * node--123--full.html.twig
   * node--123.html.twig
   * node--article--full.html.twig
   * node--article.html.twig
   x node--full.html.twig
   * node.html.twig
-->
<!-- BEGIN OUTPUT from 'themes/gesso/templates/node--full.html.twig' -->
```

The `x` marks the currently used template.
