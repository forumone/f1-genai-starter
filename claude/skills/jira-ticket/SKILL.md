---
name: jira-ticket
description: Create or update Jira tickets via MCP tools (mcp__jira__create_jira_issue, mcp__claude_ai_Atlassian_Rovo__editJiraIssue) so descriptions render with correct formatting. Use whenever the user asks to create a Jira ticket/issue, file a Jira task/bug/story, or update an existing Jira description. Prevents the common failure where wiki markup (h2., {{code}}, [text|url]) ends up as literal characters in the ticket.
---

# Creating Jira tickets with correctly formatted descriptions

## The core gotcha

`mcp__jira__create_jira_issue` accepts a `description` string and dumps it verbatim into a single ADF text node. **Wiki markup (`h2.`, `{{code}}`, `[label|url]`, `* bullet`) will render as literal characters, not formatting.** This is the #1 failure when filing tickets through MCP — always avoid it.

## Two reliable approaches

### Approach A — Create with plain text, then edit with markdown (preferred)

This is the most reliable path:

1. Create the issue with `mcp__jira__create_jira_issue`. Pass either:
   - a short plain-text description (no markup), or
   - omit `description` entirely and add it in step 2.
2. Immediately update the description with `mcp__claude_ai_Atlassian_Rovo__editJiraIssue`, passing:
   - `contentFormat: "markdown"`
   - `fields: { "description": "<markdown body>" }`

Markdown supports `## headings`, `**bold**`, `` `code` ``, `[label](url)`, fenced code blocks, and `- bullets` — all render correctly.

### Approach B — Create directly with ADF

If you must do it in one call, build the description as an Atlassian Document Format (ADF) JSON object with proper `heading`, `paragraph`, `bulletList`, `codeBlock`, and `inlineCard`/`link` nodes. More verbose; only use when a single round-trip matters.

## Other fields — tool reference

When the user asks to set non-default fields, you'll need IDs, not names. Look these up before editing:

- **Cloud ID** — `mcp__claude_ai_Atlassian_Rovo__getAccessibleAtlassianResources` (cache it for the session).
- **Assignee** — resolve with `mcp__claude_ai_Atlassian_Rovo__lookupJiraAccountId`. Set as `{ "accountId": "..." }`.
- **Sprint** — find sprint id via `mcp__jira__list_agile_boards` → `mcp__jira__list_sprints_for_board`. Set on `customfield_10007` as a numeric id (e.g. `5192`), not an array.
- **Story Points** — `customfield_10005`, numeric (e.g. `0.1`, `3`).
- **Fix version** — get id from project metadata (`mcp__claude_ai_Atlassian_Rovo__getJiraIssueTypeMetaWithFields` → `fixVersions.allowedValues`). Set as `[{ "id": "30500" }]`.
- **Custom field IDs vary by site.** When unsure, fetch the issue type metadata once and read `fields[].fieldId`.

Note: `customfield_10007` (Sprint) accepts a single id on edit; the field schema is array-typed but the API tolerates a single number for set operations on this site. If a single-number set fails, retry with `[5192]`.

## Workflow checklist

1. Confirm projectKey and issueType (default to `Task` unless user says Bug/Story/etc).
2. Create the issue (skip description or use plain text).
3. If the user gave a description, update it via `editJiraIssue` with `contentFormat: "markdown"`.
4. If the user specified sprint / story points / assignee / fix version, look up IDs and set them in the same `editJiraIssue` call when possible (one round-trip).
5. Report the issue key and `webUrl` back to the user.

## What NOT to do

- Do not paste Jira wiki markup into the `description` parameter of `create_jira_issue` — it will render as literal text.
- Do not guess account IDs, sprint IDs, or fix version IDs — always look them up.
- Do not pass `customfield_10007` as a string sprint name; it must be the numeric sprint id.
- Do not call `getJiraIssueTypeMetaWithFields` repeatedly in the same session — its output is large; cache the field IDs you need.
