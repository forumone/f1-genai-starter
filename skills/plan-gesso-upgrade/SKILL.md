---
name: plan-gesso-upgrade
description: Plans update of theme to the next Gesso 5 release
allowed-tools: Bash(ls:*), WebFetch(domain:raw.githubusercontent.com), Bash(curl:*), Bash(gh release list:*), Bash(gh api:*), mcp__github__list_releases, mcp__github__get_commit, mcp__github__list_commits, mcp__github__get_file_contents
context: fork
agent: gesso-upgrade-planner
---
Create a plan to update Gesso to the next upstream release. Write the plan to a
Markdown file.

1. Identify the current Gesso version in `package.json`
2. Identify the next Gesso release from `forumone/gesso`:
   ```bash
   gh release list -R forumone/gesso -L 10
   ```
3. Examine the diff between the upstream release that matches the current version and the next one
4. Create a plan to apply all changes in the diff to the current theme

Your plan should account for:
- npm package changes
- additions or edits to code
- removal of code
- updating the version number in package.json

If there are any changes in the upstream that cannot be applied cleanly, ask the
user if they should be included.

If the current Gesso version is not included in the 10 most recent releases,
ask the user what version number to update to.

When finished, report the name of the plan file.
