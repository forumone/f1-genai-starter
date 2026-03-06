---
title: Drupal Troubleshooting
description: Read when debugging errors
---

## Debugging Workflow

1. **Check container logs**: `ddev logs -f`
2. **Check Drupal watchdog**: `ddev drush watchdog:show --count=50`
3. **Check errors only**: `ddev drush watchdog:show --severity=Error --count=20`
4. **Clear cache**: `ddev drush cache:rebuild`
5. **Enable verbose errors** (temporarily):
   Add to `settings.local.php`:
   ```php
   $config['system.logging']['error_level'] = 'verbose';
   ```
6. **Enable Twig debugging**:
   Edit `sites/development.services.yml`:
   ```yaml
   parameters:
     twig.config:
       debug: true
       cache: false
   ```

## Common Errors

### "Class not found" after adding a new class

**Cause**: Autoloader cache is stale.

**Solution**:
```bash
ddev drush cache:rebuild
# or
ddev composer dump-autoload
```

### Changes not appearing after code edit

**Cause**: Drupal caches aggressively.

**Solution**:
```bash
ddev drush cache:rebuild
```

Always clear cache after code changes.

### Configuration import fails

**Cause**: UUID mismatches or missing dependencies.

**Solution**:
1. Check the specific error in command output
2. Verify dependencies exist: `ddev drush config:get [config.name]`
3. Check for UUID conflicts in config files
4. Ensure required modules are enabled

### Permission denied errors

**Cause**: Role or permission misconfiguration.

**Solution**:
1. Check user roles: `ddev drush user:information [username]`
2. Review permissions: `/admin/people/permissions`
3. Clear cache: `ddev drush cache:rebuild`

### "The website encountered an unexpected error"

**Solution**:
1. Check recent logs: `ddev drush watchdog:show --severity=Error --count=10`
2. Check container logs: `ddev logs`
3. Enable verbose error display (see above)

### Entity schema out of sync

**Cause**: Entity field definitions changed but not applied.

**Solution**:
```bash
ddev drush entity:updates
ddev drush entity:updates --run
```

### Module won't enable

**Cause**: Missing dependencies or schema issues.

**Solution**:
1. Check requirements: `ddev drush pm:list --filter=[module]`
2. Ensure dependencies are installed: `ddev composer require drupal/[dep]`
3. Check for database issues: `ddev drush updatedb`

### Twig template not loading

**Solution**:
1. Verify template name matches suggestion exactly (case-sensitive)
2. Clear cache: `ddev drush cache:rebuild`
3. Enable Twig debugging to see which template is loading
4. Check theme's `templates/` directory structure

### CSS/JS not updating

**Solution**:
1. Clear Drupal cache: `ddev drush cache:rebuild`
2. Clear browser cache (hard refresh)
3. Check for aggregate CSS/JS: disable in development
4. If using theme build: `ddev gesso build`

### "SQLSTATE: Integrity constraint violation"

**Cause**: Database constraint error (duplicate key, null in required field).

**Solution**:
1. Check the full error in logs
2. Identify the entity/field causing the issue
3. Fix the data or code creating invalid data

### Ajax/form submission fails silently

**Solution**:
1. Check browser console for JavaScript errors
2. Check network tab for failed requests
3. Check Drupal logs: `ddev drush watchdog:show --count=20`
4. Check PHP logs: `ddev logs`

## Debug Mode Settings

### settings.local.php

```php
<?php

// Error display
$config['system.logging']['error_level'] = 'verbose';

// Disable CSS/JS aggregation
$config['system.performance']['css']['preprocess'] = FALSE;
$config['system.performance']['js']['preprocess'] = FALSE;

// Disable render cache
$settings['cache']['bins']['render'] = 'cache.backend.null';

// Disable dynamic page cache
$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
```

### development.services.yml

```yaml
parameters:
  http.response.debug_cacheability_headers: true
  twig.config:
    debug: true
    cache: false

services:
  cache.backend.null:
    class: Drupal\Core\Cache\NullBackendFactory
```

## Useful Debug Commands

```bash
# Show full stack traces
ddev drush watchdog:show --count=10 --extended

# Check specific module status
ddev drush pm:list --filter=my_module

# Verify route exists
ddev drush router:debug | grep my_route

# Check service exists
ddev drush devel:services | grep my_service

# Rebuild router
ddev drush router:rebuild
```
