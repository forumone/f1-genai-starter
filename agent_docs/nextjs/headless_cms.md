---
title: Headless CMS Setup
description: Read when told to set up the headless Drupal or headless Wordpress starter kit
---

## Drupal
```bash
ddev setup-drupal           # One-time setup
ddev frontend generate      # Regenerate GraphQL types after query changes
```

## WordPress
```bash
ddev setup-wp               # One-time setup
ddev frontend generate      # Regenerate GraphQL types
```

Both require `.env.local` configuration - see starterkit READMEs.
