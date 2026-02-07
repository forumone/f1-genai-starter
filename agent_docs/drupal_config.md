# Drupal Configuration Management

## Key Concepts

- **Active configuration**: Stored in database, used by running site
- **Sync configuration**: YAML files in `config/sync/`, version controlled
- Configuration flows: Export (database → files) and Import (files → database)

## Common Commands

```bash
ddev drush config:export -y             # Export to files
ddev drush config:import -y             # Import from files
ddev drush config:export --diff         # Preview pending export
ddev drush config:get [config.name]     # View a config value
ddev drush config:set [name] [key] [val] # Set a config value
ddev drush status --field=config-sync   # Get sync directory path
```

## Workflow

### After Making UI Changes
1. Make changes in Drupal admin UI
2. Export: `ddev drush config:export -y`
3. Review: `git diff config/sync/`
4. Commit the config changes

### After Pulling Changes
1. Pull latest code: `git pull`
2. Import: `ddev drush config:import -y`
3. Clear cache: `ddev drush cache:rebuild`

### Reverting a Config Change
```bash
git checkout config/sync/[config.name].yml
ddev drush config:import -y
```

## Best Practices

1. **Always export after changes** — Any change made via UI or drush should be
   exported to keep config in sync.

2. **Review diffs before committing** — Check `git diff config/sync/` to ensure
   only intended changes are included.

3. **Check diffs before importing** — Use `ddev drush config:export --diff` to
   preview what will change.

4. **Module install config** — Default configuration for a module belongs in
   `config/install/`, not `hook_install()`.

5. **Omit UUIDs in config/install** — Drupal generates UUIDs on install. Including
   them causes conflicts.

6. **Sync config/install with active** — If updating a module's `config/install`
   files, also apply those changes to active configuration (export after).

## Partial Configuration Import

Import specific config from a module's install directory:

```bash
ddev drush config:import --partial --source=web/modules/custom/my_module/config/install
```

## File Locations

| Type | Path |
|------|------|
| Sync directory | `config/sync/` |
| Views | `config/sync/views.view.[view_id].yml` |
| Field config | `config/sync/field.field.[entity].[bundle].[field].yml` |
| Field storage | `config/sync/field.storage.[entity].[field].yml` |
| Module install config | `web/modules/custom/[module]/config/install/` |
| Module config schema | `web/modules/custom/[module]/config/schema/` |

## Troubleshooting

### Configuration Import Fails
- **UUID mismatch**: Remove UUID from the file or check for conflicts
- **Missing dependency**: Ensure required modules are enabled first
- **Schema validation**: Check config schema in `config/schema/`

### Configuration Not Exporting
- Ensure you have write permissions to `config/sync/`
- Check that the sync directory is configured in `settings.php`
