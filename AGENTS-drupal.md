# AGENTS.md

## Project Overview
- Drupal 10/11
- Local development via DDEV
- PHP 8.3+
- Custom theme `gesso` (see [agent_docs/gesso_drupal.md](agent_docs/gesso_drupal.md))
<!-- TODO: Add project-specific details (e.g., "Multilingual site (English/Spanish)", "Headless CMS with Next.js frontend") -->

## Critical Rules

### Theme — Gesso
**IMPORTANT**: Before any work in the Gesso theme, you **MUST** read
[agent_docs/gesso_drupal.md](agent_docs/gesso_drupal.md).

### Contrib & Core — Do Not Modify
**NEVER edit files in `web/core/` or `web/modules/contrib/`.**
These are managed by Composer and will be overwritten.
See [agent_docs/drupal_patching.md](agent_docs/drupal_patching.md) for the patch workflow.

## Essential Commands

```bash
ddev start                              # Start environment
ddev drush cache:rebuild                # Clear cache (always after code changes)
ddev drush config:export -y             # Export config after UI changes
ddev drush config:import -y             # Import config after git pull
ddev drush uli                          # Admin login link
```

Full command reference: [agent_docs/drupal_commands.md](agent_docs/drupal_commands.md)

## File Locations

| Type | Location |
|------|----------|
| Custom modules | `web/modules/custom/` |
| Custom theme | `web/themes/gesso/` |
| Config sync | `config/sync/` |
| Contrib modules | `web/modules/contrib/` (do not edit) |
| Core | `web/core/` (do not edit) |

## Reference Documentation

**Read the relevant doc BEFORE starting work in that area.**

| Topic | Document | Read before... |
|-------|----------|----------------|
| **Commands** | [agent_docs/drupal_commands.md](agent_docs/drupal_commands.md) | Running drush or ddev commands |
| **Code Style** | [agent_docs/drupal_code_style.md](agent_docs/drupal_code_style.md) | Writing PHP code |
| **Configuration** | [agent_docs/drupal_config.md](agent_docs/drupal_config.md) | Exporting/importing config |
| **Custom Modules** | [agent_docs/drupal_custom_modules.md](agent_docs/drupal_custom_modules.md) | Creating or modifying modules |
| **Patching** | [agent_docs/drupal_patching.md](agent_docs/drupal_patching.md) | Fixing bugs in contrib/core |
| **Troubleshooting** | [agent_docs/drupal_troubleshooting.md](agent_docs/drupal_troubleshooting.md) | Debugging errors |
| **Testing** | [agent_docs/drupal_testing.md](agent_docs/drupal_testing.md) | Running phpcs, phpstan, phpunit |

### Theme Documentation (Gesso)

| Topic | Document | Read before... |
|-------|----------|----------------|
| **Gesso Overview** | [agent_docs/gesso_drupal.md](agent_docs/gesso_drupal.md) | Any theme work |
| **Sass** | [agent_docs/sass_conventions.md](agent_docs/sass_conventions.md) | Writing SCSS files |
| **JavaScript** | [agent_docs/drupal_js_conventions.md](agent_docs/drupal_js_conventions.md) | Writing JS in theme |
| **Storybook** | [agent_docs/storybook_drupal.md](agent_docs/storybook_drupal.md) | Creating stories |
| **Design Tokens** | [agent_docs/design_tokens.md](agent_docs/design_tokens.md) | Working with colors, spacing, typography |
| **Twig** | [agent_docs/drupal_twig.md](agent_docs/drupal_twig.md) | Working with Twig or template fields |

<!--
## Architectural Patterns

### Search API
- **Server**: [e.g., ddev_solr (Solr 8.x)]
- **Indexes**:
  - `content` — Main content search
  - `[index_name]` — [description]
- **Reindex**: `ddev drush search-api:reset-tracker [index] && ddev drush search-api:index [index]`
-->

<!--
## Multilingual Support
- Languages: [e.g., English, Spanish]
- Translation updates: `ddev drush locale:check && ddev drush locale:update`
-->

<!--
## Project Documentation

| Topic | Document | Read before... |
|-------|----------|----------------|
| Groups | `agent_docs/groups.md` | Working with groups or memberships |
| Notifications | `agent_docs/notifications.md` | Working with email notifications |
-->
