---
title: Storybook Shared Guidelines
description: Read when creating or editing stories
---

## Story Variations

When a component has variants, create multiple named story exports. Reuse stories with the spread operator to avoid repetition (CSF 3 style).

Each variant spreads the base story and overrides only what differs:

```javascript
const Primary = {
  args: { ...baseArgs },
};

const Secondary = {
  ...Primary,
  args: {
    ...Primary.args,
    variant: 'secondary',
  },
};

export { Primary, Secondary };
```

See the [CSF spreadable story objects docs](https://storybook.js.org/docs/api/csf/index#spreadable-story-objects) for more detail.
