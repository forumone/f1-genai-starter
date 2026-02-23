# Drupal Twig Templates
This document covers Twig patterns **unique to the Gesso theme**. Standard Drupal Twig knowledge is assumed.

## Two-Layer Template Architecture

Drupal override templates in `templates/` are thin wrappers that delegate to component templates. The real markup lives in component files.

```twig
{# templates/block/block.html.twig — thin wrapper #}
{% embed 'gesso:block' with {
  'attributes': attributes.addClass(classes),
  'has_constrain': false,
} %}
  {% block content %}
    {{ content }}
  {% endblock %}
{% endembed %}
```

**Rule:** Never put significant markup in `templates/` files. They should only assemble variables and delegate to a component via `include` or `embed`.

## `add_attributes()` — The Core Attributes Rendering Function

Gesso replaces standard `{{ attributes }}` in component templates with a custom `add_attributes()` function (from `gesso_helper` module). It:

1. Merges caller-provided attributes with component-defined classes
2. **Consumes and clears** the attribute variable after use, preventing attribute trickle-down through nested includes

```twig
{# Basic — merges with 'attributes' context variable #}
<div {{ add_attributes({ 'class': classes }) }}>

{# Named — merges with a different attribute variable #}
<h2 {{ add_attributes({ 'class': title_classes }, 'title_attributes') }}>

{# Dot notation for nested paths #}
<span {{ add_attributes({ 'class': 'c-field__item' }, 'item.attributes') }}>
```

**Rule:** Use `add_attributes()` in all component templates. Only use raw `{{ attributes }}` in thin Drupal override templates.

## Translateable Strings
All hard-coded text must be translatable.

RIGHT
```twig
{# Using |t (most common) #}
<div>{{ 'Some hard-coded text'|t }}</div>

{# Using trans #}
<div>{% trans %}Some hard-coded text{% endtrans %}</div>
```

WRONG
```twig
<div>Some hard-coded text</div>
```

## Custom Twig Filters

| Filter | Source | Purpose | Example |
|--------|--------|---------|---------|
| `\|subheading_level` | `gesso_helper` | Returns next heading level (e.g., `'h2'` → `'h3'`, capped at `h6`) | `{{ title_element\|subheading_level }}` |
| `\|keysort` | `gesso_helper` | Sorts array by keys (PHP `ksort`) | `{{ items\|keysort }}` |

## `|field_value` and the `catch_cache` Pattern

Paragraph templates extract field values directly with `|field_value` and pass them to components. This bypasses Drupal's render pipeline, so cache metadata must be preserved manually:

```twig
{# 1. Extract values with conditional fallback to false #}
{% set card_title = content.field_title|field_value is not empty
  ? content.field_title|field_value : false %}

{# 2. Pass to component #}
{% include 'gesso:card' with { 'title': card_title } %}

{# 3. REQUIRED: Render remaining fields to capture cache metadata #}
{% set catch_cache = content|without('field_title', 'field_image')|render %}
```

**Rule:** Every paragraph template using `|field_value` must end with a `catch_cache` line. List all fields accessed via `|field_value` in the `|without()` call.

## `modifier_classes` Convention

Every component accepts a `modifier_classes` string for additional BEM modifiers. Classes are assembled as arrays, then joined:

```twig
{% set classes = [
  'c-card',
  has_image ? 'c-card--has-image' : '',
  modifier_classes ? modifier_classes : '',
]|join(' ')|trim %}
```

In Drupal override templates, build the string the same way:

```twig
{% set modifier_classes = [
  'c-form-item--id-' ~ name|clean_class,
  'js-form-item',
]|join(' ')|trim %}
```

## `has_constrain` Prop

Controls whether content is wrapped in an `l-constrain` div. Used in block, region, section, and paragraph components:

```twig
{% embed 'gesso:block' with { 'has_constrain': true } %}
```

## Dynamic Tag Names

Components accept variables like `title_element` or `element` to control heading hierarchy and semantic HTML:

```twig
<{{ title_element ?: 'h2' }} class="c-card__title">{{ title }}</{{ title_element ?: 'h2' }}>
```

Always pass `title_element` from Drupal templates to maintain proper heading hierarchy.

## Common Patterns
### Rendering Fields

```twig
{# Render entire field with wrappers #}
{{ content.field_image }}

{# Render field value only #}
{{ content.field_image|field_value }}

{# Check if field has value #}
{% if content.field_image|field_value is not empty ? content.field_image|field_value : null %}
```

### Rendering Links
If the URL and link text are extracted from the render array, you must ensure
that link attributes are not lost and that cache metadata is rendered, as
described above.

```twig
{% if content.field_links|field_value %}
  {% set links = content.field_links|field_value|map((value) => ({
    link_url: value['#url'],
    link_content: value['#title'],
    link_attributes: create_attribute(value['#url'].getOption('attributes')|default([])),
  })) %}
{% endif %}

{% include '@organisms/fifty-fifty/fifty-fifty.twig' with {
  title: content.field_header,
  description: content.field_description,
  links: links,
  featured_image: content.field_media|field_value ? content.field_media : null
} %}

{% set cache_catch = content|without('field_header', 'field_description', 'field_media') %}
```

## Template Inheritance Patterns

### `{% extends %}` for Variants

Field and media variants use single-line extends for specialization:

```twig
{# field--ordered-list.html.twig #}
{% extends "field.html.twig" %}
{% set field_items_wrapper_tag = 'ol' %}
{% set field_item_tag = 'li' %}
```

```twig
{# media--image.html.twig #}
{% extends "media--figure.html.twig" %}
```

### `{% embed %}` for Block Overrides

Used when the caller needs to fill named blocks inside a component:

```twig
{% embed 'gesso:section' with { 'modifier_classes': 'c-section--dark' } %}
  {% block content %}{{ rendered_content }}{% endblock %}
{% endembed %}
```

### Page Template Chain

`page.html.twig` extends `@layouts/site-container/site-container.twig`. Content-type pages extend `page.html.twig` and override `{% block main_content %}`.
