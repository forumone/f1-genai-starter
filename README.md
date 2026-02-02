# f1-genai-starter
Starter kit for generative AI skills for tools like Claude Code and Cursor

## Requirements
* [Node.js](https://nodejs.org/en/)
* `tiged` installed: `npm install -g tiged`

## Usage
Find the type of project you have below and follow the instructions.

## Drupal usage
1. Run this command from the root level of your repo:
   ```bash
   curl -o AGENTS.md https://raw.githubusercontent.com/forumone/f1-genai-starter/main/AGENTS-drupal.md && ln -s AGENTS.md CLAUDE.md
   ```
2. Download the `agent_docs` directory to the root level of your repo:
   ```bash
   degit forumone/f1-genai-starter/agent_docs agent_docs
   ```
3. If your site is not using **Gesso 5** as your theme, remove the Gesso theme section from the file.

## Next.js Usage
1. Run this command from the root level of your repo:
   ```bash
   curl -o AGENTS.md https://raw.githubusercontent.com/forumone/f1-genai-starter/main/AGENTS-nextjs.md && ln -s AGENTS.md CLAUDE.md
   ```
2. Download the `agent_docs` directory to the root level of your repo:
   ```bash
   degit forumone/f1-genai-starter/agent_docs agent_docs
   ```

## Adding Skills
1. If not already present, create `.claude` and `.cursor` directories in the root level of your repo.
2. Add a `skills` directory inside both (so you have `.claude/skills` and `.cursor/skills`)
3. Copy the directory for any skills you want to add into the `skills` directory for both agents. Note that you need to copy the entire directory with the `SKILLS.md` file, not just the Markdown file.

### Available Skills
- `create-component` (Next.js only) - Creates a new component. (See `Prerequistes` in the skill definition for what you should provide in the prompt). **Requires updated component.js script from nextjs-project**
- `npm-package-updates` (Any Gesso) - Updates npm packages
- `upgrade-gesso` (Gesso 5 for Drupal only) - Upgrades a theme to the next Gesso release. **Requires the GitHub CLI to be installed and the GitHub MCP server configured.**
   - `plan-gesso-upgrade` - Skill used by `upgrade-gesso`
   - `implement-gesso-upgrade` - Skill used by `upgrade-gesso`

## Adding Subagents
1. If not already present, create `.claude` and `.cursor` directories in the root level of your repo.
2. Add a `agents` directory inside both (so you have `.claude/agents` and `.cursor/agents`)
3. Copy the Markdown file for any agents you want to add into the `agents` directory for both agents.

### Available Agents
- `gesso-upgrade-implementer` - Install if using the `upgrade-gesso` skill with Claude Code
- `gesso-upgrade-planner` - Install if using the `upgrade-gesso` skill with Claude Code
