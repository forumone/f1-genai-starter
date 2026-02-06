---
name: upgrade-gesso
description: Updates theme to the next Gesso 5 release
disable-model-invocation: true
---

1. Use the `plan-gesso-upgrade` skill to plan the update.
2. Use the `implement-gesso-upgrade` skill to implement the plan. Provide the name of the file created by `plan-gesso-upgrade` as an argument.
3. Delete the old dependencies: `rm -rf node_modules package-lock.json`
4. Install the new dependencies: `ddev gesso npm install`
5. Test linting:
   `ddev gesso stylelint`
   `ddev gesso eslint`
   Fix any linting errors found.
6. Test theme build: `ddev gesso build`
7. Delete the plan file after all changes are completed.
