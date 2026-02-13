---
name: implement-gesso-upgrade
description: Executes update of theme to the next Gesso 5 release
disable-model-invocation: true
---

## Plan
Review and implement the plan at $ARGUMENTS

**IMPORTANT**: If the file is not provided or does not exist, do not proceed.
Prompt the user to provide the plan file to you.

## Implement
For each phase of the plan, have a subagent implement that phase of work. Each
subagent is responsible for only one phase and does not need the entire plan.
Each subagent should report its success or failure to you upon finishing.
Subagents should **not** do any testing or validation. You are responsible for
updating the plan file as each phase is completed and prompting the next subagent.
When all changes are made and all phases are complete, move on to the next
section, "Test".

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
