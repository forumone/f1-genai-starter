# React Component Conventions

This file provides information about a React component's file structure.

## Structure
Components follow this file structure:
```
source/03-components/ComponentName/
├── ComponentName.tsx           # React component
├── component-name.module.css   # CSS Module with cascade layer
├── ComponentName.stories.tsx   # Storybook story
└── componentNameArgs.ts        # Story mock data
```

## CSS
- Use CSS Modules (`.module.css` files)
- Wrap styles in cascade layers matching the source folder: `@layer components { ... }` for `03-components`, `@layer layouts { ... }` for `02-layouts`
- Import mixins with `@import 'mixins';` at the top only when mixins are used in the CSS file
- Use CSS custom properties for theming (defined in `00-config/`)
- Use `clsx` for conditional class composition
- Third-party CSS goes in the `vendor` layer: `@import "@package/styles.css" layer(vendor);`

Read `agent_docs/css_conventions.md` when you need a more detailed explanation of CSS in this project.

## TypeScript Patterns
- Components export named exports with Props types
- Use `ComponentProps<'element'>` for extending native element props
- Add `'use client';` directive at the top of the file when using:
    - Event handlers (onClick, onChange, etc.)
    - React hooks (useState, useEffect, useRef, etc.)
    - Browser APIs

### Props Examples
**For extending native HTML elements:**
```tsx
import { ComponentProps } from 'react';

interface ButtonProps extends GessoComponent, ComponentProps<'button'> {
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'small' | 'medium' | 'large';
}
```

**For components with children:**
```tsx
import { PropsWithChildren } from 'react';

interface CardProps extends GessoComponent, PropsWithChildren {
  title: string;
  imageUrl?: string;
}
```
