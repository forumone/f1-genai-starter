# Drupal Commands Reference

Quick reference for common drush and ddev commands.

## DDEV Environment

```bash
ddev start                              # Start environment
ddev stop                               # Stop environment
ddev restart                            # Restart services
ddev ssh                                # SSH into container
ddev logs                               # View container logs
ddev logs -f                            # Follow container logs
ddev export-db --file=dump.sql.gz       # Export database
ddev import-db --file=dump.sql.gz       # Import database
```

## Cache & Status

```bash
ddev drush cache:rebuild                # Clear all caches (cr)
ddev drush status                       # Show site status
ddev drush cron                         # Run cron
```

## Modules

```bash
ddev composer require drupal/[name]     # Download a module
ddev drush en [name]                    # Enable a module
ddev drush pm:uninstall [name]          # Uninstall a module
ddev drush pm:list                      # List all modules
ddev drush pm:list --status=enabled     # List enabled modules
ddev drush pm:list --filter=FILTER      # Filter module list
```

## Configuration

```bash
ddev drush config:export -y             # Export config (cex)
ddev drush config:import -y             # Import config (cim)
ddev drush config:export --diff         # Show pending changes
ddev drush config:get [name]            # View config value
ddev drush config:set [name] [key] [val] # Set config value
ddev drush status --field=config-sync   # Get config sync directory
ddev drush config:import --partial --source=[path] # Partial import
```

## Logs & Debugging

```bash
ddev drush watchdog:show --count=20     # Show recent logs
ddev drush watchdog:show --severity=Error --count=20  # Show errors only
ddev drush watchdog:delete all          # Clear logs
ddev drush uli                          # Generate admin login link
```

## Entities & Fields

```bash
ddev drush field:info [entity] [bundle] # View fields on entity
ddev drush entity:updates               # List pending entity updates
ddev drush entity:updates --run         # Apply entity schema updates
```

## Search API

```bash
ddev drush search-api:list              # List indexes
ddev drush search-api:status            # Check index status
ddev drush search-api:reset-tracker [index] # Reset tracker
ddev drush search-api:index [index]     # Index items
ddev drush search-api:clear [index]     # Clear index
```

## Multilingual

```bash
ddev drush locale:check                 # Check for translation updates
ddev drush locale:update                # Download translation updates
```
