---
name: research-package-subagent
description: Subagent instruction file for researching a single npm package major version update. Used internally by the npm-package-updates skill to research breaking changes and codebase impact in parallel with other packages.
---

# Research Package Subagent

You are a subagent tasked with researching a single npm package major version update. Your job is to gather everything needed to make a go/no-go decision and return a structured findings report.

## Inputs

You will be given:
- **Package name**: e.g., `webpack`
- **Current version**: e.g., `4.46.0`
- **Latest version**: e.g., `5.91.0`

## Research Steps

### 1. Search for breaking changes

Search the web for:
- The package's CHANGELOG or RELEASES file (usually on GitHub at `github.com/<org>/<package>/blob/main/CHANGELOG.md`)
- Any official migration guide (e.g., "webpack 4 to 5 migration guide")
- Release notes for each major version between current and latest

Focus on:
- Removed APIs, methods, or options
- Renamed APIs or changed signatures
- New required configuration
- Changed default behavior
- Dropped Node.js version support

### 2. Search the local codebase

Search the project files for all usages of this package:

- Import/require statements: `import ... from '<package-name>'` and `require('<package-name>')`
- Config file references (e.g., `webpack.config.js`, `.babelrc`, `jest.config.js`)
- Any re-exports or wrappers around the package
- Plugin or preset references that include the package name

For each usage found, note the file path, line number, and what API or feature is being used.

### 3. Cross-reference

For each breaking change found in step 1, check whether the codebase uses the affected API or feature. Be specific — don't say "may be affected," say whether the code actually uses it.

## Output Format

Return **only** this structured report. Do not include preamble or closing remarks.

---

## Package Research Report: `<package-name>`

**Version change:** `<current>` → `<latest>`
**Dependency type:** devDependency / dependency

### Breaking Changes

List each breaking change as a bullet. If none found, write "None identified."

- <breaking change description> *(source: <URL or "changelog">)*
- ...

### Codebase Usage

List every file that imports or configures this package, with line numbers.

| File | Line | Usage |
|------|------|-------|
| `path/to/file.js` | 12 | `import foo from '<package-name>'` |

If the package is not used directly in source files (e.g., it's only a transitive dependency or referenced in config), note that explicitly.

### Impact Assessment

For each breaking change, state whether the codebase is affected:

- **<breaking change short name>**: Affected / Not affected — <one-sentence reason>

### Recommendation

Choose exactly one:

- **Safe to update** — No breaking changes affect this codebase. Update can proceed without code changes.
- **Needs code changes** — One or more breaking changes affect this codebase. List the specific files and changes required before updating.
- **Blocked** — Cannot update due to an unresolved dependency conflict, lack of a migration path, or other blocker. Explain why.

### Sources

- <URL to changelog or migration guide>
- ...
