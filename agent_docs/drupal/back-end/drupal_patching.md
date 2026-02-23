---
title: Patching Contrib & Core Modules
description: Read when fixing bugs in contrib/core
---

## Critical Rule

**NEVER edit files in `web/core/` or `web/modules/contrib/` directly.**

These directories are managed by Composer. Your changes will be overwritten on
the next `composer install` or `composer update`.

## Preferred Alternatives

Before creating a patch, consider these approaches:

1. **Hooks** — Use `hook_form_alter`, `hook_entity_presave`, etc. in a custom module
2. **Event subscribers** — Subscribe to events to modify behavior
3. **Service decoration** — Extend or decorate services via `services.yml`
4. **Template overrides** — Override templates in your theme
5. **Module update** — Check if the issue is fixed in a newer version

## When to Patch

Create a patch only when:
- There's a confirmed bug with no workaround
- You need to modify core/contrib behavior that can't be altered via hooks
- An upstream patch exists but hasn't been released yet

## Creating a Patch

### From Local Changes

```bash
# Make your changes to the contrib module, then:
cd web/modules/contrib/module_name
git diff > ../../../patches/module_name-description-1234567.patch
```

### From a Drupal.org Issue

Download the patch directly from the issue:

```bash
# Save to patches directory
curl -o patches/module_name-description-1234567.patch \
  https://www.drupal.org/files/issues/2024-01-01/module_name-description-1234567.patch
```

## Registering the Patch

### 1. Ensure composer-patches is installed

```bash
ddev composer require cweagans/composer-patches
```

### 2. Create or update `composer.patches.json`

```json
{
  "patches": {
    "drupal/module_name": {
      "Issue #1234567: Brief description of the fix": "patches/module_name-description-1234567.patch"
    },
    "drupal/core": {
      "Issue #9876543: Core bug fix description": "patches/core-description-9876543.patch"
    }
  }
}
```

### 3. Configure composer.json to use the patches file

```json
{
  "extra": {
    "patches-file": "composer.patches.json"
  }
}
```

### 4. Apply the patch

```bash
# Reinstall to apply patches
ddev composer install

# Or reinstall a specific package
ddev composer reinstall drupal/module_name
```

## Verifying Patches Applied

Check Composer output during install — it will show:
```
  - Applying patches for drupal/module_name
    patches/module_name-description-1234567.patch (Issue #1234567: Brief description)
```

## Patch Maintenance

- **Document patches** — Include issue links and descriptions
- **Check regularly** — After updating a module, verify if the patch is still needed
- **Contribute upstream** — Submit patches to Drupal.org so everyone benefits
- **Remove when merged** — Once a fix is released, remove the patch and update the module

## Troubleshooting

### Patch Fails to Apply
- The module may have been updated and the patch no longer applies cleanly
- Download an updated patch from Drupal.org or recreate it

### Patch Not Being Applied
- Ensure `composer.patches.json` is valid JSON
- Check that `patches-file` is configured in `composer.json`
- Run `ddev composer install` (not just `update`)

### Reverting Direct Changes
After creating a patch, revert your direct changes:

```bash
cd web/modules/contrib/module_name
git checkout .
```

The patch will be applied automatically by Composer.
