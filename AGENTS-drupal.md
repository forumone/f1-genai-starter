# AGENTS.md

## Project Overview
- Drupal 10/11
- Local development via DDEV
- PHP 8.3+
- Custom theme `gesso` (described in [agent_docs/gesso_drupal.md](agent_docs/gesso_drupal.md))
<!-- TODO: Add project-specific details (e.g., "Multilingual site (English/Spanish)", "Headless CMS with Next.js frontend") -->

### Theme — Gesso
**IMPORTANT**: Before doing any work in the Gesso custom theme, you **MUST**
reference [agent_docs/gesso_drupal.md](agent_docs/gesso_drupal.md).

## Build/Lint/Test Commands

### Build & Install
- **Install dependencies**: `ddev composer install`
- **Install site from config**: `ddev drush site:install --existing-config -y`
- **Clear cache**: `ddev drush cache:rebuild`

### Linting & Static Analysis
- **PHP CodeSniffer** (custom code):
  - If the project has a `/phpcs.xml` or `/phpcs.xml.dist`: `ddev exec phpcs`
  - Otherwise: `ddev exec phpcs --standard=Drupal,DrupalPractice web/modules/custom web/themes/custom`
  - **Auto-fix**: `ddev exec phpcbf web/modules/custom web/themes/custom`
- **PHPStan**:
  - If the project has a `/phpstan.neon` or `/phpstan.neon.dist`: `ddev exec phpstan`
  - Otherwise: `ddev exec phpstan analyse web/modules/custom --level 6`
- If phpcs, phpstan, or phpunit are not available, install them:
  `ddev composer require --dev drupal/core-dev phpstan/phpstan phpstan/phpstan-deprecation-rules`

### Testing
- **Run all custom module tests**: `ddev exec phpunit web/modules/custom/*/tests`
- **Run specific module tests**: `ddev exec phpunit web/modules/custom/[module_name]/tests`
- **Run single test**: `ddev exec phpunit --filter testMethodName`
- **Test configuration**:
  - If the project has `/phpunit.xml` or `/phpunit.xml.dist`, phpunit uses that automatically
  - Otherwise: `ddev exec phpunit -c web/core/phpunit.xml.dist --filter Test path/to/test`

### Before Committing
1. Run phpcs: `ddev exec phpcs web/modules/custom web/themes/custom`
2. Run phpstan: `ddev exec phpstan analyse web/modules/custom --level 6`
3. Run tests: `ddev exec phpunit web/modules/custom/*/tests`
4. Export config: `ddev drush config:export -y`
5. Review config diff: `git diff config/sync/`

## Configuration Management
- **Export configuration**: `ddev drush config:export -y`
- **Import configuration**: `ddev drush config:import -y`
- **Import partial configuration**: `ddev drush config:import --partial --source=[path-to-module]/config/install`
- **Verify pending changes**: `ddev drush config:export --diff`
- **View config value**: `ddev drush config:get [config.name]`
- **Set config value**: `ddev drush config:set [config.name] [key] [value]`
- **Get config sync directory**: `ddev drush status --field=config-sync`

### Configuration Best Practices
- Always export configuration after making changes via UI or drush.
- Check configuration diffs before importing.
- If making changes to a module's `config/install`, apply the same changes to active configuration.
- Module install configuration belongs in `config/install`, not `hook_install()`.
- UUIDs in `config/install` files should be omitted — Drupal generates them on install.

## Development Commands
- **List available modules**: `ddev drush pm:list [--filter=FILTER]`
- **List enabled modules**: `ddev drush pm:list --status=enabled [--filter=FILTER]`
- **Download a module**: `ddev composer require drupal/[module_name]`
- **Enable a module**: `ddev drush en [module_name]`
- **Uninstall a module**: `ddev drush pm:uninstall [module_name]`
- **Clear cache**: `ddev drush cache:rebuild`
- **Inspect logs**: `ddev drush watchdog:show --count=20`
- **Inspect error logs**: `ddev drush watchdog:show --severity=Error --count=20`
- **Delete logs**: `ddev drush watchdog:delete all`
- **Run cron**: `ddev drush cron`
- **Show site status**: `ddev drush status`
- **Login as admin**: `ddev drush uli`

### Entity & Field Inspection
- **View fields on entity**: `ddev drush field:info [entity_type] [bundle]`
- **List entity types**: `ddev drush entity:updates`
- **Update entity schema**: `ddev drush entity:updates --run`

## Environment Setup
- **Local Development**: DDEV (Docker-based)
- **PHP Version**: 8.3+
- **Drupal Version**: 10.x / 11.x
- **Database**: MySQL (via DDEV)
<!-- TODO: Add project-specific services (e.g., Solr, Redis, Elasticsearch) -->

### Key DDEV Commands
- **Start environment**: `ddev start`
- **Stop environment**: `ddev stop`
- **SSH into container**: `ddev ssh`
- **Database export**: `ddev export-db --file=dump.sql.gz`
- **Database import**: `ddev import-db --file=dump.sql.gz`
- **View container logs**: `ddev logs` or `ddev logs -f` (follow)
- **Restart services**: `ddev restart`

## Code Style Guidelines
- **PHP Version**: 8.3+ compatibility required
- **Coding Standard**: Drupal coding standards (Drupal + DrupalPractice)
- **Indentation**: 2 spaces, no tabs
- **Line Length**: 80 characters for comments, 120 characters for code
- **Namespaces**: PSR-4 standard — `Drupal\{module_name}`
- **Types**: Use strict typing with PHP 8 features (union types, named arguments, enums, readonly properties)
- **Documentation**: PHPDoc required for classes and public methods
- **Class Structure**: Properties before methods, dependency injection via constructor
- **Naming**: CamelCase for classes/methods/properties, snake_case for hook functions and variables, ALL_CAPS for constants
- **Error Handling**: Use specific exception types with `@throws` annotations
- **Plugins**: Follow Drupal plugin conventions — use PHP attributes for plugin definitions (Drupal 10.2+)
- **Services**: Register in `[module_name].services.yml`, inject dependencies via constructor
- **Hooks**: Place in `[module_name].module` file. For Drupal 11+ projects using the Hook attribute system, hooks can also be placed in dedicated hook classes.
- **Prefer contrib modules** over replicating functionality in custom code

### Contrib & Core Modules — Do Not Modify Directly

**NEVER edit files in `web/core/` or `web/modules/contrib/`.** These directories
are managed by Composer and your changes will be overwritten on the next
`composer install` or `composer update`.

If you need to fix a bug or modify behavior in core or contrib:

1. **Create a patch file** with your changes:
   ```bash
   # From the module directory, after making changes:
   git diff > /path/to/patches/module_name-description.patch

   # Or create a patch from a specific file:
   diff -u web/modules/contrib/module_name/original.php web/modules/contrib/module_name/modified.php > patches/module_name-description.patch
   ```

2. **Register the patch in `composer.patches.json`** (using `cweagans/composer-patches`):
   ```json
   {
     "patches": {
       "drupal/module_name": {
         "Description of the fix": "patches/module_name-description.patch"
       }
     }
   }
   ```
   Ensure `composer.json` references this file:
   ```json
   {
     "extra": {
       "patches-file": "composer.patches.json"
     }
   }
   ```

3. **Apply the patch**:
   ```bash
   ddev composer install
   ```

4. **Revert your direct changes** to restore the clean contrib code — the patch
   will be applied automatically by Composer.

**Alternative approaches** (preferred when possible):
- Use hooks (`hook_form_alter`, `hook_entity_presave`, etc.) in a custom module
- Use event subscribers to modify behavior
- Extend or decorate services via `services.yml`
- Override templates in your theme
- Check if the issue is already fixed in a newer version of the module

## File Locations & Conventions

### Configuration
- **Sync directory**: `config/sync/` (version controlled)
- **Views**: `config/sync/views.view.[view_id].yml`
- **Field configs**: `config/sync/field.field.[entity_type].[bundle].[field_name].yml`
- **Field storage**: `config/sync/field.storage.[entity_type].[field_name].yml`

### Custom Code
- **Custom modules**: `web/modules/custom/[module_name]/`
- **Module hooks**: `[module_name].module`
- **Services**: `src/` directory within module
- **Plugins**: `src/Plugin/[PluginType]/`
- **Event Subscribers**: `src/EventSubscriber/`
- **Forms**: `src/Form/`
- **Controllers**: `src/Controller/`
- **Templates**: `templates/` directory within module
- **Tests**: `tests/src/Unit/`, `tests/src/Kernel/`, `tests/src/Functional/`

### Module File Structure
```
web/modules/custom/[module_name]/
├── [module_name].info.yml          # Module definition
├── [module_name].module            # Hook implementations
├── [module_name].services.yml      # Service definitions
├── [module_name].routing.yml       # Route definitions
├── [module_name].permissions.yml   # Permission definitions
├── [module_name].libraries.yml     # Asset library definitions
├── config/
│   ├── install/                    # Default configuration
│   └── schema/                     # Configuration schema
├── src/
│   ├── Controller/
│   ├── Form/
│   ├── Plugin/
│   │   ├── Block/
│   │   ├── Field/
│   │   └── views/
│   ├── EventSubscriber/
│   └── Service/
├── templates/                      # Twig templates
└── tests/
    └── src/
        ├── Unit/
        ├── Kernel/
        └── Functional/
```

## Common Workflows

### Creating a New Custom Module
1. Create directory: `web/modules/custom/[module_name]/`
2. Create `[module_name].info.yml`:
   ```yaml
   name: 'Module Name'
   type: module
   description: 'Description of the module.'
   core_version_requirement: ^10 || ^11
   package: Custom
   dependencies:
     - drupal:node
   ```
3. Create `.module` file if hooks are needed
4. Clear cache: `ddev drush cache:rebuild`
5. Enable: `ddev drush en [module_name]`
6. Export config: `ddev drush config:export -y`

### Working with Views
- **Find view config**: `config/sync/views.view.[view_id].yml`
- **Edit via UI**: `/admin/structure/views/view/[view_id]`
- **Export after changes**: `ddev drush config:export -y`
- **Test changes locally before committing**

### Working with Configuration Entities
- **Export after UI changes**: `ddev drush config:export -y`
- **Review changes**: `git diff config/sync/`
- **Revert a config change**: `git checkout config/sync/[config.name].yml && ddev drush config:import -y`

### Debugging Workflow
1. Check container logs: `ddev logs -f`
2. Check Drupal watchdog: `ddev drush watchdog:show --count=50`
3. Check recent errors only: `ddev drush watchdog:show --severity=Error --count=20`
4. Clear cache: `ddev drush cache:rebuild`
5. Enable verbose errors (temporarily): set `$config['system.logging']['error_level'] = 'verbose';` in `settings.local.php`
6. Enable Twig debugging: edit `sites/default/services.yml` or `sites/development.services.yml`

## Twig Templates

### Conventions
- Template files use `.html.twig` extension
- Follow Drupal's template naming conventions: `[theme-hook]--[suggestion].html.twig`
- Use Twig namespaces for includes when available (e.g., `@components/card/card.twig`)
- Prefer `include` over `embed` unless blocks need overriding
- Use `{{ attributes }}` to print the attributes object on the outermost wrapper element
- Use `{{ title_prefix }}` and `{{ title_suffix }}` around titles for contextual links

### Template Suggestions
- Enable Twig debugging to see available template suggestions in HTML comments
- Override templates by copying to theme's `templates/` directory with appropriate suggestion name
- More specific suggestions take priority (e.g., `node--article--teaser.html.twig` over `node--article.html.twig`)

## Troubleshooting

### Common Errors

#### Configuration import fails
- **Cause**: UUID mismatches or missing dependencies
- **Solution**:
  1. Check the specific config error in output
  2. Verify dependencies exist: `ddev drush config:get [config.name]`
  3. Check for UUID conflicts in config files

#### "Class not found" after adding a new class
- **Cause**: Autoloader cache is stale
- **Solution**: `ddev drush cache:rebuild` or `ddev composer dump-autoload`

#### Changes not appearing after code edit
- **Cause**: Drupal caches aggressively
- **Solution**: `ddev drush cache:rebuild` — always clear cache after code changes

<!-- ============================================================
     PROJECT-SPECIFIC SECTIONS
     Uncomment and fill in the sections below that apply to your project.
     ============================================================ -->


## Custom Module Responsibilities

| Module | Primary Responsibility | Documentation |
|--------|----------------------|---------------|
| `[module_name]` | Core utilities, shared services | - |
| `[module_name]` | User management and workflows | `agent_docs/[feature].md` |

### Adding Hooks
- **Views alterations**: Place in the module responsible for that entity/feature
- **Form alterations**: Place in the module that owns the form's entity type
- **Entity hooks**: Place in the module that primarily manages that entity type


<!--
## Architectural Patterns

### Search API
- **Server**: [e.g., ddev_solr (Solr 8.x)]
- **Indexes**:
  - `content` — Main content search
  - `[index_name]` — [description]
- **Reindex**: `ddev drush search-api:reset-tracker [index_name] && ddev drush search-api:index [index_name]`
- **Check status**: `ddev drush search-api:status`
-->

## Multilingual Support
- Languages: [e.g., English, Spanish]
- Translation updates: `ddev drush locale:check && ddev drush locale:update`
- Language-specific config: `config/install/language/[langcode]/`

## Context Documents

**IMPORTANT**: When working on features related to the topics below, ALWAYS read
the corresponding documentation for detailed context and best practices.

| Topic | Document | When to read |
|-------|----------|-------------|
| [Feature] | `agent_docs/[feature].md` | Working with [feature] functionality |
