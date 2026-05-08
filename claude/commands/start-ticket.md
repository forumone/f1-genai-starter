---
description: Fetch a Jira ticket and create a properly-named branch (e.g. /start-ticket PROJ-1234 [base-branch])
argument-hint: <TICKET-ID> [base-branch]
---

The user wants to start work on Jira ticket: **$ARGUMENTS**

Follow these steps. Don't skip the confirmation step — branch creation is a checkpoint, not a side effect.

## 1. Parse arguments

Extract from `$ARGUMENTS`:
- **Ticket ID** — must match `^[A-Z][A-Z0-9_]+-\d+$` (any Jira project key, e.g. `PROJ-123`, `HHMIDEV-2400`, `ABC1-45`). If missing or malformed, ask the user for a valid ticket ID and stop.
- **Base branch** (optional second token) — if absent, default to `main`. Only use the current branch as the base if the user explicitly passes it or asks to stack onto an in-flight branch.

## 2. Check git state

Run `git status --short` and `git rev-parse --abbrev-ref HEAD` in parallel.
- If there are uncommitted or staged changes, show them and ask whether to stash, commit, or abort before branching. Don't auto-stash.
- If not inside a git repo, report the error and stop.
- If the working tree is clean, proceed.

## 3. Fetch the Jira issue

Call `mcp__atlassian__read_jira_issue` with the ticket ID. Capture:
- Summary
- Description (full body, including acceptance criteria if present)
- Issue type (Bug, Story, Task, etc.)
- Status
- Assignee
- Priority

If the ticket doesn't exist or the call fails, report the error and stop. Don't create a branch.

## 4. Generate the branch name

Format: `<TICKET-ID>-<slug>` where `<slug>` is derived from the summary:
- Lowercase
- Replace non-alphanumerics with hyphens
- Collapse consecutive hyphens, trim leading/trailing
- Cap total branch name length at ~60 chars (truncate slug at word boundary)

Examples:
- `HHMIDEV-2381` + "Gray subnav for community pages" → `HHMIDEV-2381-gray-subnav-for-community-pages`
- `PROJ-42` + "Fix: login button broken on mobile" → `PROJ-42-fix-login-button-broken-on-mobile`

Before proposing the name, look at existing branches (`git branch -a | head -30`) for the project's slug style — some teams use lowercase ticket IDs, no ticket prefix, or `feature/` namespacing. If the existing convention differs from the default, follow it and mention the choice in the confirmation block.

If a branch with that name already exists locally (`git rev-parse --verify <name>`), ask whether to check out the existing branch instead of creating a new one.

## 5. Confirm with the user

Print this block and wait for approval:

```
Ticket:  [<TICKET-ID>] <Summary>
Type:    <type> · Status: <status> · Assignee: <name>
Branch:  <proposed-branch-name>
Base:    <base-branch>
```

Stop here until the user confirms. Accept lightweight confirmations ("yes", "go", "y") and treat anything else as a request to revise.

## 6. Create the branch

Run `git checkout -b <branch-name>` (or `git checkout -b <branch-name> <base>` if a base was specified and differs from the current branch).

If the base was specified, fetch first (`git fetch origin <base>`) so the branch starts from current upstream.

## 7. Surface ticket context

Print the ticket details so they're in the conversation context for the work that follows:

```
=== <TICKET-ID>: <Summary> ===
Type: <type>  |  Priority: <priority>  |  Status: <status>

<Full description body>

--- Acceptance Criteria ---
<extracted AC, if present in description>
```

Then ask: "Branch is ready. What's the first thing you want to tackle?"

## Notes

- Do NOT commit, push, or modify any files beyond the branch checkout.
- If `mcp__atlassian__read_jira_issue` is unavailable in the project, fall back to `mcp__claude_ai_Atlassian_Rovo__getJiraIssue`.
- If the ticket has linked issues or attachments, mention their existence but don't fetch them unless asked.
