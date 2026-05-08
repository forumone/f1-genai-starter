Copy these to your ~/.claude/ or path/to/project/.claude/

## Atlassian MCP

`claude mcp add --transport http atlassian https://mcp.atlassian.com/v1/mcp`

### Example prompts

- `Summarize Jira ticket PROJ-1234 and list its open subtasks.`
- `Search Jira for open bugs assigned to me in the PROJ project.`
- `Create a Jira story in PROJ titled "Add CSV export to reports" with acceptance criteria for admin-only access.`
- `Add a comment to PROJ-1234 noting that the fix has been deployed to staging.`
- `Find the Confluence page about our deploy process and summarize the rollback steps.`

## Playwright MCP

`claude mcp add playwright npx @playwright/mcp@latest`

### Example prompts

- `Open https://example.com, take a screenshot, and describe the page.`
- `Navigate to the staging site, log in as the test user, and verify the dashboard loads without console errors.`
- `Fill out the contact form on /contact with sample data and confirm the success message appears.`
- `Click through the main navigation and report any links that 404.`
- `Reproduce the bug in PROJ-1234 by following the steps and capture screenshots of each state.`
