---
description: Autonomously implement a Jira ticket end-to-end — research, branch, implement, test, and open a PR
argument-hint: <TICKET-ID>
---

The user wants to implement Jira ticket **$ARGUMENTS** from start to finish.

This command is fully autonomous. Work through every phase without stopping unless you hit a confirmation gate or a genuine ambiguity that can't be resolved by reading the code or the ticket. Do not ask unnecessary questions.

---

## Phase 0 — Project configuration

Before doing anything else, read the project's `CLAUDE.md` (and any linked docs) to determine:

| Setting | Where to look | Fallback |
|---|---|---|
| **Base branch** | `CLAUDE.md` (e.g. "default branch", "branch from") | `main` |
| **Quality gate commands** | `CLAUDE.md` sections like "Before Committing", "Lint", "Test" | detect from `package.json` / `composer.json` |
| **Deployment / review environment** | `CLAUDE.md` (e.g. "deploy to", "review env", "staging URL") | ask the user |

Surface what you found. If a review environment workflow is documented, follow it in Phase 11. If none is documented, ask the user once: "Does this project have a review environment or staging process? If so, describe it briefly (or type 'none' to skip the deploy phase)." Save the answer as `REVIEW_ENV`.

---

## Phase 1 — Parse & validate

Extract the ticket ID from `$ARGUMENTS`. It must match `^[A-Z][A-Z0-9_]+-\d+$`. If missing or malformed, stop and ask for a valid ID.

Run these in parallel:
- `git status --short`
- `git rev-parse --abbrev-ref HEAD`

If there are uncommitted or staged changes, list them and ask the user whether to stash, commit, or abort. Do not auto-stash. If the working tree is clean, continue.

---

## Phase 2 — Fetch the ticket

Call `mcp__claude_ai_Atlassian__getJiraIssue` with the ticket ID. Capture:
- Summary
- Description (full body)
- Acceptance criteria (if present — often in a specific AC field or embedded in description)
- Issue type, status, assignee, priority
- Linked issues (just note their existence; don't fetch unless the AC references them)
- Attachments (note existence)

If the ticket doesn't exist or the call fails, report and stop. Don't fall through to branch creation.

---

## Phase 3 — Codebase research

Launch up to 2 parallel Explore agents (subagent_type: Explore) with specific, non-overlapping scopes derived from the ticket description. For example:
- One agent to find existing implementations related to the ticket's feature area
- One agent to find tests, config, or views related to the feature

Read any `docs/` files relevant to the feature area before proposing a solution. Check `CLAUDE.md` for a map of which docs cover which features.

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

Print this block and wait for approval:

```
Ticket:   [TICKET-ID] Summary
Type:     Bug/Story/Task · Priority: P · Status: S

Proposed changes:
  • File/component 1 — what changes and why
  • File/component 2 — what changes and why
  ...

Branch:   TICKET-ID-slug-from-summary
Base:     <base branch from Phase 0>
Review:   <review environment URL, or "none">
```

Accept "yes", "go", "y", or minor corrections. Anything else is a request to revise.

---

## Phase 6 — Create the branch

```bash
git fetch origin <base>
git checkout -b <TICKET-ID>-<slug> origin/<base>
```

Branch slug rules:
- Lowercase, hyphens for non-alphanumeric, collapse consecutive hyphens
- Cap total branch name at ~60 chars

If the branch already exists locally, ask whether to check it out instead.

---

## Phase 7 — Claim the ticket

Run in parallel:
- `mcp__claude_ai_Atlassian__atlassianUserInfo` to get the current user's Jira account ID
- `mcp__claude_ai_Atlassian__getTransitionsForJiraIssue` to list available status transitions

Using the results:

**Assign to current user:** Call `mcp__claude_ai_Atlassian__editJiraIssue` with the `assignee` field set to the account ID retrieved above.

**Transition to In Progress:** Find the transition whose name matches (case-insensitive) `In Progress`, `In Development`, or `Development`. If multiple match, prefer the exact string `In Progress`. Call `mcp__claude_ai_Atlassian__transitionJiraIssue` with the matching transition ID.

If neither an assignee match nor an In Progress transition is found, log a warning and continue — don't stop the workflow.

---

## Phase 8 — Implement

Work through the acceptance criteria sequentially. For each AC item:
1. Make the code changes
2. Follow the project's coding standards (check `CLAUDE.md` or `.editorconfig`)
3. Reference any relevant docs before writing new code
4. Prefer extending existing patterns over introducing new abstractions

Commit incrementally as logical units complete (don't accumulate one giant commit). Use commit message format: `[TICKET-ID] Brief description of what this commit does`

---

## Phase 9 — Quality gates

Determine what to run, in this order of precedence:
1. **Project `CLAUDE.md`** — look for sections like "Before Committing", "Lint", "Test", "Quality Gates". Run the listed commands.
2. **`package.json` scripts** — if it has `lint`, `typecheck`, `test`, run those (skip `test` if it has obvious side effects like hitting a real DB without a test config).
3. **`composer.json` scripts** — same idea.
4. **Nothing detected** — tell the user, ask whether to skip or run something specific. Don't invent a check.

Run in sequence. Stop and fix before proceeding if any gate fails. After fixing, commit the fixes.

---

## Phase 10 — Push to GitHub (CONFIRMATION GATE)

Tell the user: "About to push `BRANCH-NAME` → origin. Proceed?"

After confirmation:
```bash
git push -u origin BRANCH-NAME
```

---

## Phase 11 — Deploy to review environment (CONFIRMATION GATE)

If `REVIEW_ENV` is "none" or wasn't provided in Phase 0, skip this phase and note that e2e validation (Phase 12) will also be skipped.

Otherwise, follow the deployment steps documented in `CLAUDE.md`. Summarize what you're about to do and ask the user to confirm before running any deploy commands.

After deployment completes, surface the review environment URL so the user can verify the build.

---

## Phase 12 — Playwright e2e validation

If no review environment URL is available (Phase 11 was skipped or failed), skip this phase.

Navigate to the review environment and test each acceptance criteria item using the Playwright MCP tools:

```
mcp__playwright__browser_navigate → <review-environment-url>
```

For each AC item:
- Use `mcp__playwright__browser_snapshot` to inspect the DOM/aria tree
- Use `mcp__playwright__browser_click`, `mcp__playwright__browser_fill_form`, `mcp__playwright__browser_press_key` to interact
- Use `mcp__playwright__browser_take_screenshot` to capture evidence of pass/fail
- Mark each AC item ✓ or ✗ with a brief note

If the site requires login, navigate to the login page and fill in credentials. Ask the user for credentials if you don't have them.

If a test fails, note it clearly and continue testing the remaining AC items. Do not abort e2e testing on first failure.

---

## Phase 13 — Transition to review (CONFIRMATION GATE)

Run in parallel:
- `mcp__claude_ai_Atlassian__getTransitionsForJiraIssue` to list available transitions
- `mcp__claude_ai_Atlassian__atlassianUserInfo` (if account ID wasn't cached from Phase 7)

**Assign to current user:** Call `mcp__claude_ai_Atlassian__editJiraIssue` with `assignee` set to the current user's account ID.

**Transition status:** Find the transition whose name matches (case-insensitive) `Tech Lead Review`, `TL Review`, `In Review`, `Code Review`, or `Ready for Review`. If none match, list available transitions and ask the user to confirm which one to use. Call `mcp__claude_ai_Atlassian__transitionJiraIssue` with the chosen transition ID.

**Add a review comment:** Call `mcp__claude_ai_Atlassian__addCommentToJiraIssue` with a comment structured as follows. Write it in Markdown. Populate each section from the actual work done — don't leave placeholder text.

```markdown
## Implementation complete — ready for review

**Review environment:** <url, or "no review environment configured">

---

### What was implemented

<1–3 sentence summary of the approach taken and why. Reference specific files or modules changed if relevant.>

**Files changed:**
- `path/to/file` — <what changed>
(list all meaningful changes)

---

### Steps for QA

1. Navigate to <review environment URL>
2. <Login instructions if authentication is required>
3. <Step-by-step instructions derived from each AC item — written as concrete actions a QA tester would take>
4. <Include specific URLs, user roles, or data conditions needed to reproduce each scenario>

**Expected results:**
- AC1: <what the tester should see/experience>
- AC2: <what the tester should see/experience>

---

### Steps for code review

1. Review the PR: <PR URL if available, otherwise note the branch name>
2. Key areas to inspect: <list the most important code decisions made, e.g. architectural choices, security considerations, config changes>

---

### e2e validation results

<List each AC item with ✓ or ✗ and the Playwright test outcome, or "e2e skipped — no review environment">
```

---

## Phase 14 — Final report

Print a summary:

```
✓ Branch:    TICKET-ID-slug → origin/<base>
✓ Quality:   <passed | skipped — reason>
✓ Review:    <url | skipped>
✓ Ticket:    TICKET-ID → <new status>
✓ Comment:   Review instructions posted to ticket

E2E Results:
  ✓ AC1: [description]
  ✗ AC2: [description] — FAILED: [brief note]
```

If any AC items failed e2e validation, surface the issues clearly so the user knows what needs attention before QA handoff.

---

## Notes

- **Never skip confirmation gates** at phases 5, 10, 11, and 13 — these touch shared systems.
- **Never force-push to the default or integration branches** — only push to the feature branch.
- If quality gate tools are not installed, note that and ask the user whether to install them or skip.
- Always resolve the Jira account ID at runtime via `mcp__claude_ai_Atlassian__atlassianUserInfo` rather than hardcoding it.
- If a Jira transition or assignment call fails, log the error clearly but do not abort the workflow — code delivery takes priority.
