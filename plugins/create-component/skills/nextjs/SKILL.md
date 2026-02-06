---
name: nextjs
description: Creates a new UI component with scaffolding and customization. Use when user wants to add a new component with specific props, types, styling requirements, or Figma reference.
---

# Component Creation Skill

This skill guides you through creating a new UI component with proper scaffolding and customization based on user requirements.

## Prerequisites

The user should provide:
- **Component name** (required)
- **Props and their types** (optional but recommended)
- **Styling notes** (optional)
- **Figma link** (optional)
- **Component location** (optional, defaults to `03-components`)

## Step 1: Check Environment

Determine if ddev is running:

```bash
ddev describe 2>/dev/null
```

- If the command succeeds (exit code 0), use `ddev frontend component`
- If the command fails, use `npm run component`

## Step 2: Run Component Generator

Run the appropriate command based on Step 1, using non-interactive mode with command-line arguments.

### Command Format

```bash
# With ddev
ddev frontend component -- --name <ComponentName> --folder <folder> [options]

# Without ddev
npm run component -- --name <ComponentName> --folder <folder> [options]
```

### Required Arguments

- `--name <name>` - Component name (will be converted to PascalCase)
- `--folder <folder>` - Component location, one of:
  - `01-global` - Base styles, typography, icons
  - `02-layouts` - Layout components
  - `03-components` - Reusable UI components (default choice)
  - `04-templates` - Page-level templates

### Optional Arguments

- `--title <title>` - Human-readable title for Storybook (defaults to Capital Case of name)
- `--subfolder <name>` - Subfolder within the component location (will be converted to PascalCase)
- `--no-story` - Skip Storybook story generation

### Examples

```bash
# Basic component in 03-components
npm run component -- --name Card --folder 03-components

# Component with custom title
npm run component -- --name Card --folder 03-components --title "Product Card"

# Component in a subfolder
npm run component -- --name Button --folder 03-components --subfolder Forms

# Component without Storybook story
npm run component -- --name ApiHelper --folder 06-utility --no-story

# With ddev
ddev frontend component -- --name Card --folder 03-components --subfolder Cards
```

## Step 3: Modify Generated Files

After scaffolding completes, modify the generated files to match user requirements.

### 3a. Update Component Props (ComponentName.tsx)

The generated component has a basic props interface:

```tsx
interface ComponentNameProps extends GessoComponent {}
```

Modify it to include the user-specified props. Read `agent_docs/component_conventions.md`
and follow all patterns specified in that file.


### 3b. Implement Component JSX

Replace the placeholder `<div>` with appropriate markup based on:
- The props interface
- User styling requirements
- Figma design (if provided)

Use `clsx` for conditional class composition:
```tsx
import clsx from 'clsx';

<div className={clsx(
  styles.wrapper,
  variant && styles[`wrapper--${variant}`],
  modifierClasses
)}>
```

### 3c. Update CSS Module (component-name.module.css)
Read `agent_docs/css_conventions.md` and follow all CSS guidelines in that file.

### 3d. Update Storybook Files (if created)
Read `agent_docs/storybook.md` and follow all guidelines in that file.

## Step 4: Handle Figma Reference

If the user provides a Figma link:

### 4a. Check for Figma MCP Server

First, check if the Figma MCP server is configured and available. You can verify this by checking if Figma-related MCP tools are accessible.

### 4b. If Figma MCP Server is Available

1. Use the MCP server to fetch design details from the Figma link
2. Extract styling information: colors, spacing, typography, layout
3. Map Figma values to existing CSS variables from `source/00-config/vars/`
4. Implement the component to match the Figma design

### 4c. If Figma MCP Server is NOT Available

**You must ask the user before proceeding.** Present these options:

1. **Skip Figma reference** - Continue creating the component without the Figma design. The user can provide styling details manually or update the component later.

2. **Stop and configure Figma MCP** - Pause the component creation. The user should configure the Figma MCP server first, then re-run the skill.

Do NOT proceed without the user's explicit choice. Example prompt:

> "I don't have access to Figma (the Figma MCP server is not configured). How would you like to proceed?
> 1. **Skip Figma** - I'll create the component without the design reference. You can describe the styling or we can update it later.
> 2. **Stop here** - Configure the Figma MCP server first, then re-run `/create-component` to create with the design reference."

## Step 5: Verify Quality

Run quality checks:

```bash
npm run lint        # ESLint + Stylelint
npm run tsc         # TypeScript check
npm run prettier    # Formatting check
```

Or with ddev:
```bash
ddev frontend lint
ddev frontend tsc
ddev frontend prettier
```

Fix any errors before completing.

## File Structure Reference

After completion, the component should have:
```
source/[location]/ComponentName/
├── ComponentName.tsx           # React component with props
├── component-name.module.css   # Styled CSS module
├── ComponentName.stories.tsx   # Storybook stories (if requested)
└── componentNameArgs.ts        # Story mock data (if requested)
```

## Example Usage

User request: "Create a Card component with title (string), description (string, optional), imageUrl (string, optional), and variant (default, featured). The featured variant should have a highlighted border."

1. Run generator for "Card" in `03-components`
2. Update CardProps with the specified props
3. Implement Card JSX with proper conditional styling
4. Add CSS for `.wrapper`, `.wrapper--featured`, `.title`, `.description`, `.image`
5. Create Default and Featured story variants
6. Run lint/tsc checks
