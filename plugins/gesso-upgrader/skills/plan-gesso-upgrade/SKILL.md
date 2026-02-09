---
name: plan-gesso-upgrade
description: Plans update of theme to the next Gesso 5 release
allowed-tools: Bash(ls:*), Bash(curl:*), Bash(gh api:*), Plan 
context: fork
agent: gesso-upgrade-planner
disable-model-invocation: true
---
Create a plan to update Gesso to the next upstream release. Write the plan to a
Markdown file.

## 1. Generate the diff
Run the `get-gesso-diff.sh` script to get the full diff of changes between releases.
   ```bash
   bash ../scripts/get-gesso-diff.sh > ./gesso-upgrade-diff.md
   ```
## 2. Review the diff
Review the `gesso-upgrade-diff.md` file in full to understand what has changed.

## 3. Create the plan
Create a plan to apply all changes in the diff to the current theme. The plan 
will be executed by another subagent.

Your plan should account for:
- npm package changes
- additions or edits to code
- removal of code
- updating the version number in package.json

Your plan should also account for other changes in the theme that result from
the changes in the diff.
EXAMPLE: A renamed Twig function must be updated in every file that it is used,
including Twig files that are unique to this theme

If there are any changes in the diff that you will not implement, explicitly
note that in the plan.

Write the plan to `./gesso-upgrade-plan.md`.
