---
description: Convert a vague request or bug report into a structured Jira ticket (Bug or Story) with preview before creating.
argument-hint: [optional freeform description]
---

You are helping the user create a well-structured Jira ticket. Follow these steps in order. Never skip the preview and confirmation step.

---

## Step 1: Gather initial choices

Call `AskUserQuestion` with these two questions together in one call:

**Question 1** — header: "Input mode", question: "How would you like to provide the ticket details?", options:
- **Guided** — answer structured questions one group at a time
- **Freeform** — paste or describe the issue in your own words

**Question 2** — header: "Issue type", question: "What type of issue is this?", options:
- **Bug** — something is broken or behaving incorrectly
- **Story** — a new feature or user-facing capability

Wait for answers before continuing.

If `$ARGUMENTS` is non-empty, skip Step 1 entirely and treat the arguments as freeform input, inferring issue type from language ("broken", "error", "not working" → Bug; "add", "allow", "as a user" → Story; if ambiguous ask).

---

## Step 2: Gather description details

### Guided mode

Ask the questions below **in two separate groups**. Present each group together and wait for answers before moving on.

**Group 1 — Summary**
- One-sentence summary (this becomes the ticket title):

**Group 2 — Details** (tailor to issue type)

For a **Bug**, ask:
- What is the current (broken) behavior?
- What is the expected behavior?
- Steps to reproduce (numbered list, as detailed as possible)?
- Any relevant URLs, environments, or screenshots to note?

For a **Story**, ask:
- User story: "As a [user type], I want to [goal] so that [reason]."
- Acceptance criteria (list each criterion):
- Any technical notes or constraints?

Then proceed to Step 3.

### Freeform mode

Parse the freeform input to extract:
- A concise summary (title)
- Relevant details for the description

Ask in a single message for anything still missing or unclear (e.g., missing steps to reproduce, unclear expected behavior). Then proceed to Step 3.

---

## Step 3: Gather project and sprint

Call `AskUserQuestion` with these two questions together in one call:

**Question 1** — header: "Project key", question: "Which Jira project should this go in?", options:
- **HHMIDEV** — the main BioInteractive project
- **Other** — type your project key

**Question 2** — header: "Sprint", question: "Which sprint should this be assigned to?", options:
- **Active sprint** — assign to the current active sprint
- **Backlog** — leave unassigned to a sprint
- **Other** — specify a sprint name or number

If the user selects **Active sprint** or **Other** and needs sprint details, call `mcp__atlassian__list_agile_boards` to find the board, then `mcp__atlassian__list_sprints_for_board` filtered to active/future sprints. Present the results and ask the user to confirm.

---

## Step 4: Structure the description

Format the description using Jira wiki markup headings (`h2.`) for section labels. Do not use Markdown or other special syntax. Use blank lines between sections.

For a **Bug**:
```
h2. Summary
[one-line bug summary]

h2. Current Behavior
[what is happening now]

h2. Expected Behavior
[what should happen instead]

h2. Steps to Reproduce
1. [Step one]
2. [Step two]
3. [Continue as needed]

h2. Environment / Notes
[URLs, browser, environment, screenshots, or any other context — omit if none]
```

For a **Story**:
```
h2. User Story
As a [user type], I want to [goal] so that [reason].

h2. Acceptance Criteria
- [Criterion one]
- [Criterion two]
- [Add more as needed]

h2. Technical Notes
[Implementation notes, constraints, or dependencies — omit section if none]
```

Keep language clear and specific. Rewrite vague input into precise, actionable statements without inventing details.

---

## Step 5: Preview

Display the full ticket preview and wait for confirmation. Do not create the ticket yet.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TICKET PREVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Project:   [KEY]
Type:      [Bug | Story]
Summary:   [ticket title]
Sprint:    [sprint name, "Active sprint", or "Backlog"]

Description:
[formatted plain-text description as it will appear in Jira]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Ask: **"Does this look right? Type `yes` to create, or tell me what to change."**

If the user requests changes, apply them and show the updated preview again. Repeat until confirmed.

---

## Step 6: Create the ticket

Once confirmed, create the ticket using `mcp__atlassian__create_jira_issue`.

Pass:
- `projectKey`: the project key
- `summary`: the ticket title (keep under 80 characters)
- `description`: the plain-text description from Step 4
- `issueType`: `Bug` or `Story`
- `customFields`: include sprint assignment if applicable (e.g., `{"customfield_10020": <sprint_id>}`)

After creation, note the ticket key (e.g., `HHMIDEV-123`) and proceed immediately to Step 7.

---

## Step 7: Transition to "Ready for Development"

After the ticket is created, read it back with transitions expanded:

```
mcp__atlassian__read_jira_issue(issueKey: "<ticket_key>", expand: "fields,transitions")
```

Look in the `transitions` array for an entry whose `name` matches "Ready for Development" (case-insensitive). Extract its `id`.

**If the transition is found**, execute it via the Jira REST API using Bash:

```bash
curl -s -X POST \
  "https://forumone.atlassian.net/rest/api/3/issue/<ticket_key>/transitions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic $(echo -n '<email>:<api_token>' | base64)" \
  -d '{"transition": {"id": "<transition_id>"}}'
```

Substitute:
- `<ticket_key>` — the created issue key
- `<email>` — the user's Atlassian email (ask if unknown)
- `<api_token>` — the user's Jira API token (ask if unknown; never store it)
- `<transition_id>` — the ID found in the transitions list

A `204 No Content` response means success.

**If the transition is not found** (workflow differs or name is different), list the available transition names to the user and ask which one to use, then retry with the correct ID.

After the transition succeeds, display the ticket key, URL, and confirm it is now "Ready for Development".

---

## Notes

- Never invent details not provided by the user. If something is unclear, ask.
- Keep summaries under 80 characters — they appear in board columns and notifications.
- Use Jira wiki markup headings (`h2.`) for section labels in descriptions. Avoid other wiki markup (`*bold*`, `{{code}}`) and Markdown — these render as literal characters in Jira.
