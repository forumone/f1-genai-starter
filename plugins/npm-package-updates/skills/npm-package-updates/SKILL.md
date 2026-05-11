---
name: npm-package-updates
description: Guides through npm package updates including minor/patch updates and major version updates. Use when user wants to update npm dependencies, handle breaking changes, manage package versions, or run npm outdated/update commands.
disable-model-invocation: true
allowed-tools:
  - Bash(ddev gesso npm ci:*)
  - Bash(ddev gesso npm outdated:*)
  - Bash(ddev gesso npm update:*)
  - Bash(ddev gesso npm run:*)
  - Bash(ddev gesso npm install:*)
  - WebFetch,
  - WebSearch,
  - Bash(npm info *),
  - Bash(npm show *),
---

# npm Package Updates

This skill guides you through the process of updating npm packages in this project, including minor/patch updates and major version updates.

**Execution model:** Begin Part 1 immediately — do not ask for confirmation or approval before starting. Complete all of Part 1 autonomously (prerequisites through commit). Only pause for user input at the explicit checkpoint in Part 2 Step 4, before applying any major version updates.

## Prerequisites

### Check Environment

Determine if ddev is running:

```bash
ddev describe 2>/dev/null
```

- If the command succeeds (exit code 0), prefix every npm command with `ddev gesso`. Example: `npm update --save` becomes `ddev gesso npm update --save`
- If the command fails, run `nvm use` to ensure the correct Node version

### Install packages
Run `npm ci` to ensure installed packages match package-lock.json

## Part 1: Minor and Patch Version Updates

Minor and patch updates follow semantic versioning and should not introduce breaking changes.

### Steps:

1. **Update packages:**
   ```bash
   npm update --save
   ```
   This updates packages to their latest minor and patch versions within the semver range specified in package.json.

2. **Fix any issues:**
- Address any linting errors and warnings (stylelint, eslint)
- Address any Sass deprecation warnings if relevant
- Fix any formatting issues (prettier)
- Resolve TypeScript errors if relevant
- Update deprecated code patterns

3. **Test the updates:**
   Run all three test suites to ensure everything still works:
   ```bash
   npm run build            # Build application or theme
   npm run test             # Run linting and TypeScript checks
   npm run build-storybook  # Build Storybook
   ```

4. **Commit the changes:**
   ```bash
   git add package.json package-lock.json [other modified files]
   git commit -m "Minor and patch version updates"
   ```

## Part 2: Major Version Updates

Major version updates may introduce breaking changes and require careful review. Unlike Part 1, Part 2 has an explicit pause at Step 4: present the research summary to the user and wait for their approval before installing anything.

### Steps:

1. **Identify packages with major updates:**
   ```bash
   npm outdated
   ```
   Look for packages where the "Latest" version has a different major version than "Current".

2. **Prioritize and filter updates:**
- Skip packages that have dedicated update branches
- Skip Node.js version updates if not ready for that version
- Prioritize dev dependencies over production dependencies
- Start with smaller, less critical packages first

3. **Research ALL major updates in parallel using subagents:**

   Launch one subagent per package simultaneously — do not research packages sequentially. Each subagent works independently, so all research completes in roughly the time it takes to research one package.

   For each package with a major update available, spawn an Agent tool call using:
   - `subagent_type`: `npm-package-updates:research-package-subagent`
   - `prompt`: the package inputs in this format:

   ```
   Package name: <package-name>
   Current version: <current-version>
   Latest version: <latest-version>
   ```

   Send all Agent calls in a single message so they run concurrently. Wait for all subagents to return before proceeding to step 4.

   Collect each subagent's structured findings report and consolidate them into a single summary for the user.

4. **Present summary to user and await decision:**
- Present all major update summaries in a clear format
- Include source links for documentation
- Ask the user which updates they want to proceed with
- **DO NOT proceed with any major updates until user explicitly approves**

5. **For each approved major update:**
   c. **Update the package:**
      ```bash
      # For dev dependencies
      npm install <package-name>@latest --save-dev

      # For production dependencies
      npm install <package-name>@latest --save
      ```

   d. **Test the update:**
   Run the full test suite:
      ```bash
      npm run build
      npm run test
      npm run build-storybook
      ```

   d. **Handle failures:**
- If tests fail, review the error messages
- Check if additional code changes are needed
- Rerun tests after fixes
- If unable to resolve, roll back and inform user

e. **Commit the update:**
```bash
git add package.json package-lock.json [other modified files]
git commit -m "Update <package-name> to v<version>"
```

## Testing Requirements

All updates must pass these tests before committing:

1. **Next.js Build** (`npm run build`)
- Compiles successfully
- No build errors
- Linting passes
- Type checking passes

2. **Test Suite** (`npm run test`)
- ESLint: No warnings or errors
- Stylelint: No CSS linting errors
- TypeScript: No type errors

3. **Storybook Build** (`npm run build-storybook`)
- Builds successfully
- All stories compile

## Commit Message Format

- Minor/patch updates: `"Minor and patch version updates"`
- Major updates: `"Update <package-name> to v<version>"`
- Include only the changes relevant to that commit

## Example: Major Update Workflow

For updating `@inquirer/prompts` from v7 to v8:

1. Check npm outdated → Found v8.0.1 available
2. Research breaking changes → Found 5 breaking changes
3. Check codebase usage → Used in `lib/create-component.mjs`
4. Verify no impact → None of the breaking changes affect our usage
5. Update: `npm install @inquirer/prompts@latest --save-dev`
6. Test: Run build, test, build-storybook
7. Commit: `"Update @inquirer/prompts to v8.0.1"`

## Notes

- Always test thoroughly before committing
- Pre-commit hooks will automatically run tests
- If pre-commit modifies files, verify changes and amend if safe
- Keep commits focused on specific updates for easier review and rollback
- Document any code changes required by updates in commit messages if significant
