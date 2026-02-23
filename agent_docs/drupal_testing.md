# Drupal Testing & Code Quality

## Quick Reference

```bash
# Linting
ddev exec phpcs web/modules/custom web/themes/custom
ddev exec phpcbf web/modules/custom web/themes/custom   # Auto-fix

# Static analysis
ddev exec phpstan analyse web/modules/custom --level 6

# Unit tests
ddev exec phpunit web/modules/custom/*/tests
```

## Before Committing Checklist

1. **Run phpcs**: `ddev exec phpcs web/modules/custom web/themes/custom`
2. **Run phpstan**: `ddev exec phpstan analyse web/modules/custom --level 6`
3. **Run tests**: `ddev exec phpunit web/modules/custom/*/tests`
4. **Export config**: `ddev drush config:export -y`
5. **Review config**: `git diff config/sync/`

## Installing Tools

If tools are missing:

```bash
ddev composer require --dev \
  drupal/core-dev \
  phpstan/phpstan \
  phpstan/phpstan-deprecation-rules \
  mglaman/phpstan-drupal
```

## PHP CodeSniffer (phpcs)

### Running

```bash
# If project has phpcs.xml or phpcs.xml.dist
ddev exec phpcs

# Otherwise, specify standards
ddev exec phpcs --standard=Drupal,DrupalPractice web/modules/custom

# Check specific file
ddev exec phpcs web/modules/custom/my_module/src/Service/MyService.php

# Auto-fix violations
ddev exec phpcbf web/modules/custom web/themes/custom
```

### Common Violations

| Error | Fix |
|-------|-----|
| Missing docblock | Add PHPDoc comment |
| Line too long | Break line at 80 (comments) or 120 (code) |
| Wrong indentation | Use 2 spaces, not tabs |
| Missing blank line | Add blank line after function/class opening |
| Trailing whitespace | Remove whitespace at end of lines |

## PHPStan

### Running

```bash
# If project has phpstan.neon or phpstan.neon.dist
ddev exec phpstan

# Otherwise, specify paths and level
ddev exec phpstan analyse web/modules/custom --level 6

# Specific module
ddev exec phpstan analyse web/modules/custom/my_module --level 6
```

### Levels

- Level 0-3: Basic checks
- Level 4-5: Moderate strictness
- Level 6: Recommended for Drupal (type checking)
- Level 7-9: Very strict

### Common Issues

| Error | Fix |
|-------|-----|
| Parameter type mismatch | Add/fix type hints |
| Undefined variable | Initialize variable before use |
| Call to undefined method | Check class has method, add `@method` annotation |
| Dead code | Remove unreachable code |

## PHPUnit

### Running Tests

```bash
# All custom module tests
ddev exec phpunit web/modules/custom/*/tests

# Specific module
ddev exec phpunit web/modules/custom/my_module/tests

# Specific test class
ddev exec phpunit web/modules/custom/my_module/tests/src/Unit/MyTest.php

# Specific test method
ddev exec phpunit --filter testMyMethod

# With verbose output
ddev exec phpunit --verbose web/modules/custom/my_module/tests
```

### Test Configuration

If project has `/phpunit.xml` or `/phpunit.xml.dist`, PHPUnit uses that.

Otherwise, use core config:
```bash
ddev exec phpunit -c web/core/phpunit.xml.dist web/modules/custom/*/tests
```

### Test Types

| Type | Location | Purpose |
|------|----------|---------|
| Unit | `tests/src/Unit/` | Test isolated classes, no Drupal bootstrap |
| Kernel | `tests/src/Kernel/` | Test with Drupal services, minimal bootstrap |
| Functional | `tests/src/Functional/` | Full browser tests |
| FunctionalJavascript | `tests/src/FunctionalJavascript/` | Tests requiring JS execution |

### Writing a Unit Test

```php
<?php

declare(strict_types=1);

namespace Drupal\Tests\my_module\Unit;

use Drupal\my_module\Service\Calculator;
use Drupal\Tests\UnitTestCase;

class CalculatorTest extends UnitTestCase {

  protected Calculator $calculator;

  protected function setUp(): void {
    parent::setUp();
    $this->calculator = new Calculator();
  }

  public function testAddition(): void {
    $result = $this->calculator->add(2, 3);
    $this->assertEquals(5, $result);
  }

}
```
