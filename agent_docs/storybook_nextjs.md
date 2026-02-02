# Storybook in Next.js

This file provides information and guidelines about the Storybook integration with a Next.js site.

## Usage
Component documentation and visual testing.

## Structure
- Stories located alongside components (`.stories.tsx`)
- Storybook args in separate `.ts` files (can be `.tsx` if JSX is needed)

## Files
**ComponentName.stories.tsx:**
- Add multiple story variants if the component has variants
- Include controls for interactive props

**componentNameArgs.ts:**
- Add realistic mock data for props

## Example with variants
```tsx
const Default: Story = {
  args: {
    ...componentNameArgs,
  },
};

const Primary: Story = {
  args: {
    ...componentNameArgs,
    variant: 'primary',
  },
};

const Secondary: Story = {
  args: {
    ...componentNameArgs,
    variant: 'secondary',
  },
};

export default meta;
export { Default, Primary, Secondary };
```
