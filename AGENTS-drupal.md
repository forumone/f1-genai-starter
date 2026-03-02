# AGENTS.md

## Project Overview
- Drupal 10/11
- Local development via DDEV
- PHP 8.3+
- Custom theme `gesso` (see [agent_docs/gesso_drupal.md](agent_docs/drupal/front-end/overview.md))
<!-- TODO: Add project-specific details (e.g., "Multilingual site (English/Spanish)", "Headless CMS with Next.js frontend") -->

## Critical Rules

### Theme — Gesso
**IMPORTANT**: Before any work in the Gesso theme, you **MUST** read
[agent_docs/gesso_drupal.md](agent_docs/drupal/front-end/overview.md).

### Contrib & Core — Do Not Modify
**NEVER edit files in `web/core/` or `web/modules/contrib/`.**
These are managed by Composer and will be overwritten.
See [agent_docs/drupal_patching.md](agent_docs/drupal/back-end/drupal_patching.md) for the patch workflow.

## Essential Commands

```bash
ddev start                              # Start environment
ddev drush cache:rebuild                # Clear cache (always after code changes)
ddev drush config:export -y             # Export config after UI changes
ddev drush config:import -y             # Import config after git pull
ddev drush uli                          # Admin login link
```

Full command reference: [agent_docs/drupal_commands.md](agent_docs/drupal/back-end/drupal_commands.md)

## File Locations

| Type | Location |
|------|----------|
| Custom modules | `web/modules/custom/` |
| Custom theme | `web/themes/gesso/` |
| Config sync | `config/sync/` |
| Contrib modules | `web/modules/contrib/` (do not edit) |
| Core | `web/core/` (do not edit) |
