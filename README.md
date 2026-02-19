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
   curl -o AGENTS.md https://raw.githubusercontent.com/forumone/f1-genai-starter/main/AGENTS-drupal.md && ln -s AGENTS.md CLAUDE.md && ln -s AGENTS.md GEMINI.md
   ```
2. Download the `agent_docs` directory to the root level of your repo:
   ```bash
   degit forumone/f1-genai-starter/agent_docs agent_docs
   ```
3. If your site is not using **Gesso 5** as your theme, remove the Gesso theme section from the file.

## Next.js Usage
1. Run this command from the root level of your repo:
   ```bash
   curl -o AGENTS.md https://raw.githubusercontent.com/forumone/f1-genai-starter/main/AGENTS-nextjs.md && ln -s AGENTS.md CLAUDE.md && ln -s AGENTS.md GEMINI.md
   ```
2. Download the `agent_docs` directory to the root level of your repo:
   ```bash
   degit forumone/f1-genai-starter/agent_docs agent_docs
   ```

## Adding Skills and Subagents

### Claude Code
1. Add the `f1-genai` marketplace: `/plugin marketplace add forumone/f1-genai-starter`
2. Install the plugin(s) you want: `/plugin plugin-name@f1-genai`.
3. Restart Claude Code

Alternately, after adding the marketplace, you can use `/plugin` command to open
the plugin manager and browse for or search for a plugin. (You may want to remove
the default Claude Code plugin marketplace if you're not using it, since it makes
the list quite long.) See [the Claude Code documentation](https://code.claude.com/docs/en/discover-plugins)
for the various ways you can install plugins and manage their scope.

**Note**: The documentation indicates that plugin skills are namespaced, so you
would run them as `/plugin-name:skill-name-here`. However, I found that I could
use them just like other skills `/skill-name-here`. So if it's not showing up
one way, try anohter.

### Cursor
1. If not already present, create a `.cursor` directory in the root level of your repo.
2. Create a `skills` directory and/or an `agents` inside the `.cursor` directory
3. Copy any skills or agents you want to use from this repo to the appropriate directory. Note that for skills, you need to copy the entire directory with the `SKILLS.md` file, not just the Markdown file.

### Available Skills
- `create-component` (Next.js only) - Creates a new component. (See `Prerequistes` in the skill definition for what you should provide in the prompt). **Requires updated component.js script from nextjs-project**
- `npm-package-updates` (Any Gesso) - Updates npm packages
- `upgrade-gesso` (Gesso 5 for Drupal only) - Upgrades a theme to the next Gesso release. **Requires the GitHub CLI to be installed and the GitHub MCP server configured.**
   - `plan-gesso-upgrade` - Skill used by `upgrade-gesso`
   - `implement-gesso-upgrade` - Skill used by `upgrade-gesso`
### Available Agents
- `gesso-upgrade-implementer` - Used with the `upgrade-gesso` skill in Claude Code
- `gesso-upgrade-planner` - Used with the `upgrade-gesso` skill in Claude Code
