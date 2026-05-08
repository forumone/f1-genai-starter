---
description: Run quality gates, push branch, open a PR, and transition the Jira ticket to review
argument-hint: [base-branch] [--no-pr] [--no-transition]
---

The user is finishing work on the Jira ticket associated with the current branch.

This command modifies shared state (pushes, opens PRs, transitions tickets). Confirm with the user before each shared-state step — not just at the end. Even in auto mode, treat steps 4, 5, and 6 as confirmation gates.

## 1. Identify ticket and branch

Run in parallel:
- `git branch --show-current`
- `git status --short`
- `git rev-parse --abbrev-ref --symbolic-full-name @{u}` (capture failure — means no upstream)

Then:
- Extract ticket ID from branch name with regex `^[A-Z][A-Z0-9_]+-\d+`. If the branch isn't named that way, ask the user for the ticket ID.
- If current branch is `main`, `master`, `develop`, or the repo's default branch, stop — `/finish-ticket` is for feature branches.
- If working tree isn't clean, list the dirty files and ask whether to commit, stash, or abort. Don't auto-commit.

## 2. Determine base branch

- If `$ARGUMENTS` includes a non-flag token, treat it as the base.
- Otherwise: detect the repo's default branch via `git symbolic-ref refs/remotes/origin/HEAD` (strip `refs/remotes/origin/`). Fall back to `main` if that fails.
- Run `git log <base>..HEAD --oneline` to preview the commits the PR will contain. If empty, stop — nothing to land.

## 3. Run quality gates

Determine what to run, in this order of precedence:
1. **Project `CLAUDE.md`** — look for sections like "Before Committing", "Lint", "Test", "Quality Gates". Run the listed commands.
2. **`package.json` scripts** — if it has `lint`, `typecheck`, `test`, run those (skip `test` if it has obvious side effects like hitting a real DB without a test config).
3. **`composer.json` scripts** — same idea.
4. **Nothing detected** — tell the user, ask whether to skip or run something specific. Don't invent a check.

For each gate, run it and surface the result. On failure, stop and let the user fix — don't push broken code.

## 4. Push the branch — CONFIRMATION GATE

Tell the user: "About to push `<branch>` → `origin`. Proceed?"

After confirmation:
- If no upstream: `git push -u origin <branch>`
- Otherwise: `git push`

## 5. Open the PR — CONFIRMATION GATE

Skip this step if `$ARGUMENTS` contains `--no-pr`.

**Gather context:**
- Call `mcp__atlassian__read_jira_issue` (or `mcp__claude_ai_Atlassian_Rovo__getJiraIssue` as fallback) for the ticket's summary, description, and acceptance criteria.
- Call `mcp__claude_ai_Atlassian_Rovo__getAccessibleAtlassianResources` once to get the workspace URL. Build the ticket link as `<workspace-url>/browse/<TICKET-ID>`.
- Get commit list for the PR body: `git log <base>..HEAD --oneline`.

**Draft the PR:**
- Title: `[<TICKET-ID>] <ticket summary>` (cap at 70 chars; truncate summary if needed)
- Body (heredoc, NOT a single line):
  ```
  ## Summary
  <1-3 bullets — what changed and why, derived from ticket + commits>

  ## Jira
  [<TICKET-ID>](<ticket-url>) — <ticket summary>

  ## Test plan
  - [ ] <each acceptance criteria item, if present in the ticket>
  - [ ] <fallbacks generated from the diff if no AC>
  ```

**Show the title and body to the user.** Wait for approval. Accept lightweight edits ("change the summary to X", "add Y to test plan") and revise.

After approval, run `gh pr create --base <base> --title "..." --body "$(cat <<'EOF' ... EOF)"` and capture the PR URL.

## 6. Transition the Jira ticket — CONFIRMATION GATE

Skip if `$ARGUMENTS` contains `--no-transition`.

- Call `mcp__claude_ai_Atlassian_Rovo__getTransitionsForJiraIssue` to list available transitions.
- Find the one matching (case-insensitive): `In Review`, `Code Review`, `Review`, `Ready for Review`, or `In Code Review`. If multiple match, ask which. If none, list all available transitions and ask the user to pick one (or skip).
- Tell the user: "About to transition `<TICKET-ID>` to `<transition name>`. Proceed?"
- After confirmation, call `mcp__claude_ai_Atlassian_Rovo__transitionJiraIssue` with the chosen ID.
- Then add a comment linking the PR via `mcp__claude_ai_Atlassian_Rovo__addCommentToJiraIssue`: `"PR opened: <pr-url>"`

## 7. Final report

Print a single block summarizing what happened:

```
✓ Quality gates: <passed | skipped — reason>
✓ Pushed:        <branch> → origin
✓ PR:            <pr-url>
✓ Ticket:        <TICKET-ID> → <new status>
```

Anything skipped should say so explicitly with the reason.

## Flags

- `--no-pr` — skip step 5 (push only)
- `--no-transition` — skip step 6 (push and PR but don't move the ticket)
- A non-flag token in `$ARGUMENTS` is treated as the base branch

## Notes

- Don't force-push. If `git push` fails because of upstream conflicts, surface the error and let the user resolve it.
- Don't run `gh pr create` with `--no-verify` or any hook-skipping flag. If a hook fails, fix the underlying issue.
- If the user has a global PR template (`.github/pull_request_template.md`), use it as the body skeleton and fill in the sections rather than overriding it.
- If a PR already exists for this branch, run `gh pr view --json url,state` and update the existing PR's description instead of failing.
