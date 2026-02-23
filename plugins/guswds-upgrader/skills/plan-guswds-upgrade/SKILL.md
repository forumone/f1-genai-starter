---
name: plan-guswds-upgrade
description: Plans update of theme to the next Gesso USWDS (guswds) 5 release
allowed-tools: Bash(ls:*), Bash(cd:*), Bash(bash scripts/get-guswds-diff.sh), Plan, Write
disable-model-invocation: true
---
Create a plan to update the Gesso USWDS theme to the next upstream release. Write the complete
plan to one or more Markdown files.

## 1. Generate the diff
Run the `get-guswds-diff.sh` script to get the full diff of changes between
releases. Write the output of the script to a `guswds-upgrade-diff.diff` file.

The script lives in the `scripts/` directory next to this SKILL.md file. Locate
this SKILL.md using a glob search for `**/plan-guswds-upgrade/SKILL.md`, then
derive the script path from that location.

```bash
bash path/to/plan-guswds-upgrade/scripts/get-guswds-diff.sh > guswds-upgrade-diff.diff
```

## 2. Review the diff
Read `guswds-upgrade-diff.diff` in full to understand what has changed.

The changes may include:
- npm package version updates
- npm packages installed or removed
- additions or edits to code
- removal of code
- updated version number

## 3. Create the plan
Create a plan to apply all changes in the diff to the current theme. The plan
will be executed by another agent.

Your plan should also account for other changes in the theme that result from
the changes in the diff.

EXAMPLE: A renamed Twig function must be updated in every file that it is used,
including Twig files that are unique to this theme

### Requirements
1. Group related changes together and break the work into multiple phases.
2. Write a plan with to-do items for each phase of work to a Markdown file
3. If there are any changes in the diff that you will not implement, explicitly
   note that at the top of the plan.

### What Not to Include
Do not add or remove npm packages unless they are added, removed, or have
a version number change specifically in the diff. The theme's package.json does
not have to be identical to the upstream package.json.

If a file was **modified** in the diff, not added, and the file does not exist
in the theme, do not create it. Note that change as a change you will not
implement.

### Outcome
When finished, your Markdown files must include all the information another
agent needs to fully implement the changes.

You **must** tell the user where to find the plan files when finished.
