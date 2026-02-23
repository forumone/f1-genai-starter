# GUSWDS Upgrader

Upgrade the Gesso USWDS (guswds) theme to the next minor release.

## Usage
The plugin contains skills to plan and implement the upgrade.

1. Use the `plan-guswds-upgrade` skill to have an agent plan the upgrade.
2. Review the `./guswds-upgrade-plan.md` file and make any edits needed. The full diff is also saved for reference.
3. Use the `implement-guswds-upgrade @/path/to/the/guswds-upgrade-plan.md` skill to implement the plan.
4. Once finished, delete the `./guswds-upgrade-plan.md` and `./guswds-upgrade-diff.diff` files.
