# JavaScript Conventions

Prefer JavaScript unless editing a TypeScript file or TypeScript is specified.

## File Extensions

| Extension | Purpose | Build Output |
|-----------|---------|--------------|
| `.es6.js` | Drupal behaviors (JavaScript) | `dist/js/[name].es6.js` |
| `.es6.ts` | Drupal behaviors (TypeScript) | `dist/js/[name].es6.js` |
| `.tsx` | React components | `dist/js/react/` |

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

### Settings Access

Access theme settings via `settings.gesso`:

```typescript
const { imagePath, backToTopThreshold } = settings.gesso;
```

Available settings interface at `source/@types/drupal/index.d.ts`.

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

## Import Patterns

### Externals (not bundled)

```javascript
import Drupal from 'drupal';
import once from 'once';
```

These are provided by Drupal core at runtime.

### Design Tokens

```javascript
import { TRANSITIONS, BREAKPOINTS, COLORS } from '../../00-config/_GESSO.es6';
```

See `/agent_docs/design-tokens.md` for token structure and available exports.

### Utility Functions

```javascript
import { slideToggle, slideExpand, slideCollapse } from '../../06-utility/_slide.es6';
import KEYCODE from '../../00-config/_KEYCODE.es6';
```

### Internal Modules

```javascript
import Menu from './modules/_Menu.es6';
import MenuItem from './modules/_MenuItem.es6';
```

## Available Utilities
Location: `source/06-utility`

## TypeScript Configuration

### Type Definitions

Location: `source/@types/drupal/index.d.ts`

## React Components

Read `/agent_docs/drupal_react_conventions.md` if you are working with a React component
within the Drupal theme. (This is uncommon.)

## Webpack Externals

These modules are NOT bundled; Drupal provides them at runtime:
- `drupal`
- `drupalSettings`
- `once`

Ensure library dependencies include `core/drupal` and `core/once` in `gesso.libraries.yml`.

## Key Files

| Purpose | Path |
|---------|------|
| Type definitions | `source/@types/drupal/index.d.ts` |
| TypeScript config | `tsconfig.json` |
| ESLint config | `eslint.config.js` |
| ESLint dev config | `eslint.dev.config.js` |
| Webpack common | `webpack.common.js` |
| Webpack production | `webpack.production.js` |
| Webpack React | `webpack.react-config.js` |
| Design tokens (JS) | `source/00-config/_GESSO.es6.js` |
