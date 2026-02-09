---
name: implement-gesso-upgrade
description: Executes update of theme to the next Gesso 5 release
context: fork
agent: gesso-upgrade-implementer
disable-model-invocation: true
---

## Plan
Review and implement the plan at `./gesso-upgrade-plan.md.` 

**IMPORTANT**: If the file does not exist, do not proceed. Wait for the user
to rerun the skill after creating the file.

## Implement
Create a to-do list to track your progress through each step.

## Test
1. Delete the old dependencies: `rm -rf node_modules package-lock.json`
2. Install the new dependencies: `ddev gesso npm install`
3. Test linting:
   `ddev gesso stylelint`
   `ddev gesso eslint`
   Fix any linting errors found.
4. Test theme build: `ddev gesso build`
5. Test Storybook build: `ddev gesso npm run build-storybook`

**IMPORTANT**: The task is not complete until linting, theme build, and 
Storybook build complete successfully without errors or warnings.

When work is complete, remind the user to delete the `./gesso-upgrade-plan.md`
file. Do not delete it yourself! The user may wish to run this task again.
