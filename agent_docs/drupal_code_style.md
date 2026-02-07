# Drupal Code Style Guidelines

## General Rules

- **PHP Version**: 8.3+ compatibility required
- **Coding Standard**: Drupal coding standards (Drupal + DrupalPractice)
- **Indentation**: 2 spaces, no tabs
- **Line Length**: 80 characters for comments, 120 characters for code

## Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Classes | CamelCase | `MyServiceClass` |
| Methods | camelCase | `getNodeTitle()` |
| Properties | camelCase | `$nodeStorage` |
| Variables | snake_case | `$node_ids` |
| Constants | ALL_CAPS | `MY_CONSTANT` |
| Hook functions | snake_case | `mymodule_form_alter()` |
| Module names | snake_case | `my_custom_module` |

## Namespaces

- PSR-4 standard: `Drupal\{module_name}\{SubNamespace}`
- Match directory structure: `src/Service/MyService.php` → `Drupal\my_module\Service\MyService`

## Types & PHP 8 Features

Use modern PHP 8 features:
- Strict typing with type declarations
- Union types when needed: `function example(int|string $value)`
- Named arguments for clarity
- Enums for fixed value sets
- Readonly properties where appropriate
- Constructor property promotion

## Documentation

PHPDoc required for:
- All classes (description of purpose)
- All public methods (description, @param, @return, @throws)
- Complex private methods

```php
/**
 * Loads nodes by their status.
 *
 * @param string $status
 *   The publication status to filter by.
 *
 * @return \Drupal\node\NodeInterface[]
 *   An array of matching node entities.
 *
 * @throws \InvalidArgumentException
 *   If the status is not valid.
 */
public function loadByStatus(string $status): array {
```

## Class Structure

1. Constants
2. Properties (static first, then instance)
3. Constructor
4. Public methods
5. Protected methods
6. Private methods

Dependency injection via constructor:

```php
public function __construct(
  protected EntityTypeManagerInterface $entityTypeManager,
  protected LoggerInterface $logger,
) {}
```

## Plugins

Use PHP attributes for plugin definitions (Drupal 10.2+):

```php
#[Block(
  id: 'my_block',
  admin_label: new TranslatableMarkup('My Block'),
)]
class MyBlock extends BlockBase {
```

## Services

Register in `[module_name].services.yml`:

```yaml
services:
  my_module.my_service:
    class: Drupal\my_module\Service\MyService
    arguments: ['@entity_type.manager', '@logger.factory']
```

## Hooks

Place in `[module_name].module` file.

For Drupal 11+ with Hook attribute system, hooks can also be placed in
dedicated hook classes in `src/Hook/`.

## Best Practices

- Prefer contrib modules over custom code when functionality exists
- Use dependency injection, avoid `\Drupal::service()` in classes
- Use specific exception types with meaningful messages
- Keep methods focused and small
- Write self-documenting code with clear variable names
