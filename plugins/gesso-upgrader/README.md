# Gesso Upgrader

Upgrade Gesso for Drupal to the next minor release.

## Prerequisites
You must have the `gh` CLI tool installed. If you do not, first [install it](https://cli.github.com/)
and [log in to GitHub](https://cli.github.com/manual/).

## Usage
The plugin contains skills to plan and implement the plugin.

1. Use the `plan-gesso-upgrade` skill to have an agent plan the upgrade.
2. Review the `./gesso-upgrade-plan.md` file and make any edits needed. The full diff is also saved to an MD file for reference.
3. Use the `implement-gesso-upgrade` skill to implement the plan.
4. Once finished, delete the `./gesso-upgrade-plan.md` and `./gesso-upgrade-diff.md` files.
