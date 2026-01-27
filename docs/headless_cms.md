# Headless CMS Setup

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
