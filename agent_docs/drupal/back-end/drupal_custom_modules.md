---
title: Drupal custom modules
description: Read when creating or modifying modules
---

## File Structure

```
web/modules/custom/[module_name]/
├── [module_name].info.yml          # Required: Module definition
├── [module_name].module            # Hook implementations
├── [module_name].services.yml      # Service definitions
├── [module_name].routing.yml       # Route definitions
├── [module_name].permissions.yml   # Permission definitions
├── [module_name].libraries.yml     # Asset libraries (CSS/JS)
├── [module_name].install           # Install/update hooks
├── config/
│   ├── install/                    # Default configuration
│   └── schema/                     # Configuration schema
├── src/
│   ├── Controller/                 # Route controllers
│   ├── Form/                       # Form classes
│   ├── Plugin/                     # Plugin implementations
│   │   ├── Block/
│   │   ├── Field/
│   │   └── views/
│   ├── EventSubscriber/            # Event subscribers
│   └── Service/                    # Service classes
├── templates/                      # Twig templates
└── tests/
    └── src/
        ├── Unit/
        ├── Kernel/
        └── Functional/
```

## Creating a New Module

### 1. Create the info.yml file

`web/modules/custom/my_module/my_module.info.yml`:

```yaml
name: 'My Module'
type: module
description: 'Provides custom functionality for the site.'
core_version_requirement: ^10 || ^11
package: Custom
dependencies:
  - drupal:node
```

### 2. Create the .module file (if hooks needed)

`web/modules/custom/my_module/my_module.module`:

```php
<?php

/**
 * @file
 * Primary module hooks for My Module.
 */

declare(strict_types=1);

/**
 * Implements hook_theme().
 */
function my_module_theme(): array {
  return [
    'my_template' => [
      'variables' => [
        'items' => [],
      ],
    ],
  ];
}
```

### 3. Enable the module

```bash
ddev drush cache:rebuild
ddev drush en my_module
ddev drush config:export -y
```

## Adding a Service

`my_module.services.yml`:

```yaml
services:
  my_module.example_service:
    class: Drupal\my_module\Service\ExampleService
    arguments: ['@entity_type.manager', '@logger.factory']
```

`src/Service/ExampleService.php`:

```php
<?php

declare(strict_types=1);

namespace Drupal\my_module\Service;

use Drupal\Core\Entity\EntityTypeManagerInterface;
use Psr\Log\LoggerInterface;

class ExampleService {

  public function __construct(
    protected EntityTypeManagerInterface $entityTypeManager,
    protected LoggerInterface $logger,
  ) {}

}
```

## Adding a Route

`my_module.routing.yml`:

```yaml
my_module.example:
  path: '/my-module/example'
  defaults:
    _controller: '\Drupal\my_module\Controller\ExampleController::content'
    _title: 'Example Page'
  requirements:
    _permission: 'access content'
```

## Adding a Block Plugin

`src/Plugin/Block/ExampleBlock.php`:

```php
<?php

declare(strict_types=1);

namespace Drupal\my_module\Plugin\Block;

use Drupal\Core\Block\Attribute\Block;
use Drupal\Core\Block\BlockBase;
use Drupal\Core\StringTranslation\TranslatableMarkup;

#[Block(
  id: 'my_module_example_block',
  admin_label: new TranslatableMarkup('Example Block'),
  category: new TranslatableMarkup('Custom'),
)]
class ExampleBlock extends BlockBase {

  public function build(): array {
    return [
      '#markup' => $this->t('Hello, World!'),
    ];
  }

}
```

## Where to Place Hooks

| Hook Type | Location |
|-----------|----------|
| General hooks | `[module_name].module` |
| Install/update | `[module_name].install` |
| Views hooks | `[module_name].module` or `[module_name].views.inc` |
| Token hooks | `[module_name].tokens.inc` |
| Drupal 11 Hook classes | `src/Hook/` |

## Guidelines

- One module per feature/responsibility
- Use dependency injection in services and plugins
- Avoid `\Drupal::service()` in classes — inject dependencies instead
- Place business logic in services, not controllers
- Keep hooks thin — delegate to services
