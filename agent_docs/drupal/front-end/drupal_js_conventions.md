---
title: JavaScript Conventions
description: Read when writing JavaScript or TypeScript
---

Prefer JavaScript unless editing a TypeScript file or TypeScript is specified.

## Drupal Behaviors

### Standard Pattern

```javascript
import Drupal from 'drupal';
import once from 'once';

Drupal.behaviors.behaviorName = {
  attach(context, settings) {
    const elements = once('behavior-id', '.c-component', context);
    elements.forEach(el => {
      // Initialize
    });
  }
};
```

## Module vs Library Files

| Prefix | Purpose | gesso.libraries.yml Entry |
|--------|---------|---------------------------|
| `_` (underscore) | Internal module, imported by others | No |
| None | Library, compiled to dist/ | Yes |

### Module Example

`source/03-components/dropdown-menu/modules/_Menu.es6.js`:

```javascript
class Menu {
  constructor(domNode, options = {}) {
    this.domNode = domNode;
  }
  init() { }
  destroy() { }
}
export default Menu;
```

### Library Example

`source/03-components/dropdown-menu/dropdown-menu.es6.js`:

```javascript
import Drupal from 'drupal';
import once from 'once';
import Menu from './modules/_Menu.es6';

Drupal.behaviors.dropdownMenu = {
  attach(context) {
    once('dropdown-menu', '.c-dropdown-menu', context).forEach(el => {
      new Menu(el).init();
    });
  }
};
```
## Design Tokens

```javascript
import { TRANSITIONS, BREAKPOINTS, COLORS } from '../../00-config/_GESSO.es6';
```

See [design-tokens.md](design_tokens.md) for token structure and available exports.

## Available Utilities
Location: `source/06-utility`

## Webpack Externals

These modules are NOT bundled; Drupal provides them at runtime:
- `drupal`
- `drupalSettings`
- `once`
