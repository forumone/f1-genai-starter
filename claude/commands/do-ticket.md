---
description: Autonomously implement a Jira ticket locally — research, branch, implement, validate with Playwright against local dev, and transition to review (no remote deploy)
argument-hint: <TICKET-ID>
---

The user wants to implement Jira ticket **$ARGUMENTS** from start to finish, locally. This command does NOT push to remote or deploy to a review environment — validation happens against the local DDEV/dev environment.

This command is fully autonomous. Work through every phase without stopping unless you hit a confirmation gate or a genuine ambiguity that can't be resolved by reading the code or the ticket. Do not ask unnecessary questions.

---

## Phase 1 — Parse & validate

Extract the ticket ID from `$ARGUMENTS`. It must match `^[A-Z][A-Z0-9_]+-\d+$`. If missing or malformed, stop and ask for a valid ID.

Run these in parallel:
- `git status --short`
- `git rev-parse --abbrev-ref HEAD`

If there are uncommitted or staged changes, list them and ask the user whether to stash, commit, or abort. Do not auto-stash. If the working tree is clean, continue.

---

## Phase 2 — Fetch the ticket

Call `mcp__atlassian__read_jira_issue` with the ticket ID. Capture:
- Summary
- Description (full body)
- Acceptance criteria (if present — often in a specific AC field or embedded in description)
- Issue type, status, assignee, priority
- Linked issues (just note their existence; don't fetch unless the AC references them)
- Attachments (note existence)

If the ticket doesn't exist or the call fails, report and stop. Don't fall through to branch creation.

Fallback if `mcp__atlassian__read_jira_issue` is unavailable: `mcp__claude_ai_Atlassian__getJiraIssue`.

---

## Phase 3 — Codebase research

Launch up to 2 parallel Explore agents (subagent_type: Explore) with specific, non-overlapping scopes derived from the ticket description. For example:
- One agent to find existing implementations related to the ticket's feature area
- One agent to find tests, config, or views related to the feature

Always read any `docs/` files in the current project root that are relevant to the feature area before proposing a solution. The CLAUDE.md lists which doc maps to which feature.

Use research findings to:
- Identify which files are likely to change
- Understand the existing patterns to follow
- Find any reusable utilities or hooks

---

## Phase 4 — Clarifying questions (only if needed)

If you found genuine ambiguities in Phase 2–3 — AC that is contradictory, technical decisions not inferable from the codebase, or scope questions — ask them now using AskUserQuestion. Maximum 3 questions. Skip this phase entirely if the ticket and codebase make the work unambiguous.

Do NOT ask about things you can determine by reading the code or the ticket.

---

## Phase 5 — Present work plan (CONFIRMATION GATE)

Print this block and wait for approval.

```
Ticket:   [TICKET-ID] Summary
Type:     Bug/Story/Task · Priority: P · Status: S

Proposed changes:
  • File/component 1 — what changes and why
  • File/component 2 — what changes and why
  ...

Branch:   TICKET-ID-slug-from-summary
Base:     main
Validation: Playwright against local DDEV environment
```

Accept "yes", "go", "y", or minor corrections. Anything else is a request to revise.

---

## Phase 6 — Create the branch

```bash
git fetch origin main
git checkout -b TICKET-ID-{slug} origin/main
```

Branch slug rules (same as /start-ticket):
- Lowercase, hyphens for non-alphanumeric, collapse consecutive hyphens
- Cap total branch name at ~60 chars

If the branch already exists locally, ask whether to check it out instead.

---

## Phase 7 — Claim the ticket

Run in parallel:
- `mcp__claude_ai_Atlassian__lookupJiraAccountId` with email `mwest@forumone.com` to get Matt West's Jira account ID
- `mcp__claude_ai_Atlassian__getTransitionsForJiraIssue` to list available status transitions

Using the results:

**Assign to Matt West:** Call `mcp__claude_ai_Atlassian__editJiraIssue` with the `assignee` field set to the account ID retrieved above.

**Transition to In Progress:** Find the transition whose name matches (case-insensitive) `In Progress`, `In Development`, or `Development`. If multiple match, prefer the exact string `In Progress`. Call `mcp__claude_ai_Atlassian__transitionJiraIssue` with the matching transition ID.

If neither an assignee match nor an In Progress transition is found, log a warning and continue — don't stop the workflow.

---

## Phase 8 — Implement

Work through the acceptance criteria sequentially. For each AC item:
1. Make the code changes
2. Follow Drupal coding standards (2-space indent, PHPDoc, 120-char line limit)
3. Reference the relevant docs/ file patterns before writing new code
4. Prefer existing contrib modules and hooks over new custom code

After any Drupal configuration changes:
```bash
ddev drush config:export -y
```

Commit incrementally as logical units complete (don't accumulate one giant commit). Use commit message format: `[TICKET-ID] Brief description of what this commit does`

### Playwright local validation

Once all code changes for the ticket are in place, validate the implementation against the local dev environment using Playwright before moving on to quality gates.

**Determine the local URL:**
```bash
ddev describe -j 2>/dev/null | jq -r '.raw.primary_url'
```

If `ddev describe -j` isn't available or the project isn't a DDEV project, fall back to:
- Reading the URL from `pantheon.yml` / `.ddev/config.yaml` / `.lando.yml`
- Asking the user for the local URL

**Make sure the site is up to date** before testing:
```bash
ddev drush deploy
ddev drush cr
```

**Navigate and test each AC item:**
```
mcp__playwright__browser_navigate → LOCAL_URL
```

For each acceptance criteria item:
- Use `mcp__playwright__browser_snapshot` to inspect the DOM/aria tree
- Use `mcp__playwright__browser_click`, `mcp__playwright__browser_fill_form`, `mcp__playwright__browser_press_key` to interact
- Use `mcp__playwright__browser_take_screenshot` to capture evidence of pass/fail
- Mark each AC item ✓ or ✗ with a brief note

**If the site requires login:** use `ddev drush uli` to generate a one-time login link, then navigate to it. Or ask the user for credentials if `drush uli` isn't available.

**If a test fails:** fix the underlying code, re-run any required `drush` commands (e.g. `cr`, `cim`), and re-test that AC item. Do not proceed to Phase 9 until all AC items pass locally — or, if a failure is genuinely out of scope, flag it clearly and ask the user before continuing.

Capture the validation results — they'll be included in the Phase 10 review comment.

---

## Phase 9 — Quality gates

Run in sequence. Stop and fix before proceeding if either fails.

```bash
phpcs web/modules/custom web/themes/gesso
```

```bash
phpstan analyse web/modules/custom --level 6
```

After fixing any issues, commit the fixes before moving to the next phase.

---

## Phase 10 — Transition to Tech Lead Review

Run in parallel:
- `mcp__claude_ai_Atlassian__getTransitionsForJiraIssue` to list available transitions
- `mcp__claude_ai_Atlassian__lookupJiraAccountId` with email `mwest@forumone.com` (if account ID wasn't cached from Phase 7)

**Assign to Matt West:** Call `mcp__claude_ai_Atlassian__editJiraIssue` with `assignee` set to Matt West's account ID.

**Transition status:** Find the transition whose name matches (case-insensitive) `Tech Lead Review`, `TL Review`, or `Lead Review`. If none match exactly, list available transitions and ask the user to confirm which one to use. Call `mcp__claude_ai_Atlassian__transitionJiraIssue` with the chosen transition ID.

**Add a review comment:** Call `mcp__claude_ai_Atlassian__addCommentToJiraIssue` with a comment structured as follows. Write it in Markdown. Populate each section from the actual work done — don't leave placeholder text.

```markdown
## Implementation complete — ready for Tech Lead Review

**Branch:** BRANCH-NAME (local — not yet pushed)

---

### What was implemented

<1–3 sentence summary of the approach taken and why. Reference specific files or modules changed if relevant.>

**Files changed:**
- `path/to/file.php` — <what changed>
- `config/sync/some.config.yml` — <what changed>
(list all meaningful changes)

---

### Steps for QA

1. Check out branch `BRANCH-NAME` locally and run the site (`ddev start`, `ddev drush deploy`)
2. <Login instructions if authentication is required>
3. <Step-by-step instructions derived from each AC item — written as concrete actions a QA tester would take>
4. <Include specific URLs, user roles, or data conditions needed to reproduce each scenario>

**Expected results:**
- AC1: <what the tester should see/experience>
- AC2: <what the tester should see/experience>

---

### Steps for Tech Lead review

1. Check out branch `BRANCH-NAME` locally
2. Key areas to inspect: <list the most important code decisions made, e.g. hook choice, config changes, security considerations>
3. Test the scenario manually if desired (see QA steps above)

---

### Local validation results

<List each AC item with ✓ or ✗ and the Playwright local-test outcome>
```

---

## Phase 11 — Final report

Print a summary:

```
✓ Branch:      TICKET-ID-slug (local — not pushed)
✓ phpcs:       passed
✓ phpstan:     passed
✓ Ticket:      TICKET-ID → Tech Lead Review (assigned: Matt West)
✓ Comment:     Review instructions posted to ticket

Local Validation Results:
  ✓ AC1: [description]
  ✓ AC2: [description]
  ✗ AC3: [description] — FAILED: [brief note]

Next steps:
  • Run /finish-ticket to push the branch and open a PR when ready
```

If any AC items failed validation, surface the issues clearly so the user knows what needs attention before QA handoff.

---

## Notes

- **Never skip the confirmation gate** at phase 5 — work plan needs approval before implementation.
- **This workflow stays local.** No `git push`, no Buildkite/Upsun deploy, no multidev creation. The branch is left checked out and ready for the user to push via `/finish-ticket` (or manually) when they're satisfied.
- If `phpcs` or `phpstan` is not available, install via `composer require --dev drupal/core-dev` and report that you did.
- Matt West's Jira email is `mwest@forumone.com`. Always resolve the account ID at runtime via `mcp__claude_ai_Atlassian__lookupJiraAccountId` rather than hardcoding it.
- If a Jira transition or assignment call fails, log the error clearly but do not abort the workflow — code delivery takes priority.
