---
title: Storybook Conventions
description: Read when creating or editing stories
---

## Story File Structure

### Imports

```javascript
import parse from 'html-react-parser';
import { withGlobalWrapper } from '../../../.storybook/decorators';
import twigTemplate from './component-name.twig';
import globalData from '../../00-config/storybook.global-data.yml';
import data from './component-name.yml';
// For interactive components:
import './component-name.scss';  // Component library SCSS
import './component-name.es6';   // Drupal behavior
// For composition:
import ReactDOMServer from 'react-dom/server';
import { OtherComponent } from '../other-component/other-component.stories';
```

### Settings Object

```javascript
const settings = {
  title: 'Components/Component Name',  // Sidebar hierarchy
  decorators: [withGlobalWrapper],
  argTypes: { /* control definitions */ },
  parameters: {
    controls: {
      include: ['prop1', 'prop2'],  // Allowlist editable props
    },
  },
};

export default settings;
```

### Story Object

```javascript
const Default = {
  render: args => parse(twigTemplate(args)),
  args: { ...globalData, ...data },
};

export { Default };
```

## Title Hierarchy

```
title: 'Global/Typography/Fonts'     // 3 levels
title: 'Components/Form Item/Input'  // Nested under parent
title: 'Layouts/Grid'                // 2 levels
title: 'Templates/Page'
title: 'Pages/Article'
```

Sort order: Global, Layouts, Components, Templates, Pages (alphabetical within).

## Decorators

### withGlobalWrapper

Wraps component in `<div className="l-constrain u-spaced-4">`. Use for all component/layout/template stories.

```javascript
import { withGlobalWrapper } from '../../../.storybook/decorators';
decorators: [withGlobalWrapper],
```

## Story Variations

See [shared Storybook guidelines](../shared/front-end/storybook.md) for the general pattern.

In Drupal stories, variants also carry a `render` function:

```javascript
const Primary = {
  render: args => parse(twigTemplate(args)),
  args: { ...globalData, ...data },
};

const Secondary = {
  ...Primary,
  args: {
    ...Primary.args,
    modifier_classes: 'c-button--secondary',
  },
};
```

### Multiple Data Files

```javascript
import colorData from './form-item--color.yml';
import dateData from './form-item--date.yml';

const Color = { ...Text, args: { ...colorData } };
const Date = { ...Text, args: { ...dateData } };
```

## Complex Render Functions

### Composing Multiple Templates

```javascript
const Default = {
  render: args => {
    const accordionItems = args.accordion_data
      .map(item => accordionItemTemplate({ ...args, ...item }))
      .join('');

    return parse(
      accordionTemplate({
        accordion_items: accordionItems,
        ...args,
      })
    );
  },
  args: { ...globalData, ...data },
};
```

### Conditional Rendering

```javascript
const Primary = {
  render: ({ icon_name, icon_position, ...args }) => {
    const button_icon_before =
      icon_name && icon_position === 'before'
        ? ReactDOMServer.renderToStaticMarkup(
            Icon.render({
              ...Icon.args,
              icon_name,
              modifier_classes: 'c-button__icon is-spaced-after',
            })
          )
        : null;
    return parse(twigTemplate({ button_icon_before, ...args }));
  },
  args: { ...globalData, ...data },
};
```

## Story Composition

### Using Other Stories

```javascript
import { Icon } from '../icon/icon.stories';

// Access render function and args
Icon.render(Icon.args)
Icon.render({ ...Icon.args, icon_name: 'arrow' })
```

### Rendering to Static Markup

```javascript
import ReactDOMServer from 'react-dom/server';

const hero_image = ReactDOMServer.renderToStaticMarkup(
  HeroImage.render(HeroImage.args)
);
```

## Page Stories

Page stories do NOT use `withGlobalWrapper`. Use PageWrapper instead.

```javascript
import PageWrapper from './page-wrappers/default.jsx';
import { Page as Template } from '../04-templates/page/page.stories.jsx';

const pageContent = args =>
  ReactDOMServer.renderToStaticMarkup(
    Template.render({
      ...args,
      title: 'Page Title',
    })
  );

const Page = {
  render: args => <PageWrapper>{parse(pageContent(args))}</PageWrapper>,
  args: { ...globalData },
};
```

## ContentPlaceholder

For demo content areas in layout stories:

```javascript
import ContentPlaceholder from '../../01-global/content-placeholder/content-placeholder';

<ContentPlaceholder>Grid Item 1</ContentPlaceholder>
```

## Global Data

File: `source/00-config/storybook.global-data.yml`

## YAML Data Files

YAML data files provide most default args for Storybook stories. All files MUST
be valid YAML.

## Twig Extensions

Available Twig functions/filters in Storybook (registered in `.storybook/preview.js`):

| Function/Filter | Purpose |
|-----------------|---------|
| `add_attributes()` | Merge HTML attribute objects |
| `keysort` | Sort object keys alphabetically |
| `clean_unique_id()` | Generate unique element IDs |
| `field_value` | Stub for Drupal field values |
| `create_attribute()` | Create attribute string from object |

Drupal filters from `@forumone/twig-drupal-filters` are also registered.

## Twig Namespaces

Configured in `.storybook/main.js`:

| Namespace | Path |
|-----------|------|
| `@global` | `source/01-global` |
| `@layouts` | `source/02-layouts` |
| `@components` | `source/03-components` |
| `@templates` | `source/04-templates` |
| `@pages` | `source/05-pages` |

## Webpack Externals

`drupal`, `drupalSettings`, `once` are external (not bundled). Drupal stubs provide these in Storybook.
