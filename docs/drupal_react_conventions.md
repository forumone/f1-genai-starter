# React Components in Drupal

## Directory

`source/07-react/`

## File Structure

```
07-react/
├── index.tsx           # Entry point with lazy loading
├── constants.ts        # Shared constants
└── Example/
    ├── Example.tsx
    ├── Example.module.scss
    └── Example.stories.tsx
```

## Entry Point Pattern

`source/07-react/index.tsx` uses:
- `React.lazy()` for code-splitting
- `Suspense` for loading states
- `MutationObserver` to wait for BigPipe-rendered containers

```typescript
const Example = lazy(() => import('./Example/Example'));

waitForBlock('element-id').then(container => {
  if (container) {
    const root = ReactDOM.createRoot(container);
    root.render(
      <Suspense fallback={<div>Loading...</div>}>
        <Example />
      </Suspense>
    );
  }
});
```

## CSS Modules

```typescript
import styles from './Example.module.scss';
<div className={styles.blackBox}>
```
