Copy these to your `~/.claude/` or `path/to/project/.claude/`

## Atlassian MCP

```
claude mcp add --transport http atlassian https://mcp.atlassian.com/v1/mcp
```

### Example prompts

- `Summarize Jira ticket PROJ-1234 and list its open subtasks.`
- `Search Jira for open bugs assigned to me in the PROJ project.`
- `Create a Jira story in PROJ titled "Add CSV export to reports" with acceptance criteria for admin-only access.`
- `Add a comment to PROJ-1234 noting that the fix has been deployed to staging.`
- `Find the Confluence page about our deploy process and summarize the rollback steps.`

## Playwright MCP

```
claude mcp add playwright npx @playwright/mcp@latest
```

### Example prompts

- `Open https://example.com, take a screenshot, and describe the page.`
- `Navigate to the staging site, log in as the test user, and verify the dashboard loads without console errors.`
- `Fill out the contact form on /contact with sample data and confirm the success message appears.`
- `Click through the main navigation and report any links that 404.`
- `Reproduce the bug in PROJ-1234 by following the steps and capture screenshots of each state.`

---

## Commands

These slash commands implement a full Jira-to-PR workflow. Each command maps to a stage of the development lifecycle.

### `/create-jira [description]`

Converts a vague request or bug report into a structured Jira ticket (Bug or Story) with a preview before creating.

**Flow:**
1. Asks for input mode (guided or freeform) and issue type (Bug or Story)
2. Collects details — steps to reproduce / acceptance criteria depending on type
3. Asks for project key and sprint assignment
4. Shows a formatted preview and waits for confirmation
5. Creates the ticket and transitions it to "Ready for Development"

**Usage:**

```
/create-jira
/create-jira The login button is broken on mobile Safari
```

If you pass a description as an argument, it skips the input mode prompt and uses freeform mode automatically.

---

### `/start-ticket <TICKET-ID> [base-branch]`

Fetches a Jira ticket and creates a properly-named local branch for it.

**Flow:**
1. Reads the ticket from Jira (summary, type, status, assignee)
2. Checks git state — warns if there are uncommitted changes
3. Proposes a branch name derived from the ticket ID and summary slug
4. Shows a confirmation block and waits for approval
5. Creates the branch and prints the full ticket details as context

**Usage:**

```
/start-ticket HHMIDEV-2400
/start-ticket HHMIDEV-2400 develop
```

The base branch defaults to `main` if not specified. Use the second argument to stack onto a different branch.

---

### `/do-ticket <TICKET-ID>`

Autonomously implements a Jira ticket locally — research, branch, implement, validate with Playwright against the local dev environment, and transition to review. **Does not push to remote or deploy.**

**Flow:**
1. Fetches the ticket and researches the codebase
2. Presents a work plan (confirmation gate)
3. Creates the branch and claims the ticket (assigns + transitions to In Progress)
4. Implements the acceptance criteria with incremental commits
5. Validates each AC item against the local DDEV site using Playwright
6. Runs `phpcs` and `phpstan` quality gates
7. Transitions the ticket to Tech Lead Review and posts a review comment
8. Prints a final summary with per-AC validation results

**Usage:**

```
/do-ticket HHMIDEV-2400
```

Run `/finish-ticket` after this to push the branch and open a PR.

---

### `/do-ticket-workflow <TICKET-ID>`

Like `/do-ticket` but goes further — pushes to GitHub and deploys to a remote review environment (Pantheon multidev or Upsun environment) for QA handoff.

**Flow:**
1–9. Same as `/do-ticket` (fetch, research, plan, branch, claim, implement, quality gates)
10. **(Pantheon only)** Patches `.buildkite/pipeline.yml` and `.buildkite/pipeline.deploy.yml` to route the branch to the multidev
11. Pushes the branch to origin (confirmation gate)
12. Creates the remote environment — Pantheon multidev or Upsun environment (confirmation gate)
13. Validates each AC item on the remote environment using Playwright
14. Transitions the ticket to Tech Lead Review and posts a review comment with the environment URL
15. Prints a final summary

**Platform detection:** Checks for `pantheon.yml` → Pantheon; `.upsun/config.yaml` / `.platform.app.yaml` → Upsun.

**Multidev naming:**
- Pantheon: `t-<number>` (e.g. `HHMIDEV-2381` → `t-2381`, max 11 chars)
- Upsun: environment name equals the full branch name

**Usage:**

```
/do-ticket-workflow HHMIDEV-2400
```

---

### `/finish-ticket [base-branch] [--no-pr] [--no-transition]`

Runs quality gates, pushes the current branch, opens a PR, and transitions the Jira ticket to review. **Each shared-state step is a confirmation gate.**

**Flow:**
1. Identifies the ticket from the branch name and checks git state
2. Determines the base branch
3. Runs quality gates (checks `CLAUDE.md`, `package.json`, `composer.json` in that order)
4. Pushes the branch to origin (confirmation gate)
5. Opens a PR with a title and body derived from the ticket + commits (confirmation gate)
6. Transitions the Jira ticket to a review state and adds a PR link comment (confirmation gate)
7. Prints a final summary

**Usage:**

```
/finish-ticket
/finish-ticket develop
/finish-ticket --no-pr
/finish-ticket --no-transition
```

**Flags:**
- `--no-pr` — push only, skip PR creation
- `--no-transition` — push and create PR, but don't move the Jira ticket

---

## Typical workflow

```
/create-jira          # Draft and file the ticket
/start-ticket PROJ-1  # Branch off main
  ... make changes manually ...
/finish-ticket        # Quality gates → push → PR → Jira transition
```

Or, for fully autonomous implementation:

```
/do-ticket PROJ-1            # Implement + local validation (no push)
/finish-ticket               # Push + PR + Jira transition

# Or in one shot with remote deploy:
/do-ticket-workflow PROJ-1   # Implement + push + deploy + Jira transition
```
