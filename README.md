# f1-genai-starter
Starter kit for generative AI skills for tools like Claude Code and Cursor

We are in the process of automating this. For now, setting up the starter kit
is a manual process. Find the type of project you have below and follow the
instructions.

## Next.js Usage
1. Copy `AGENTS-nextjs.md` to the root level of your repo and rename it to `AGENTS.md`
2. Symlink `AGENTS.md` to `CLAUDE.md`: `ln -s AGENTS.md CLAUDE.md`
3. Copy the `docs` directory to the root level of your repo

### Adding Skills
1. If not already present, create `.claude` and `.cursor` directories in the root level of your repo.
2. Add a `skills` directory inside both (so you have `.claude/skills` and `.cursor/skills`)
3. Copy the directory for any skills you want to add into the `skills` directory for both agents. Note that you need to copy the entire directory with the `SKILLS.md` file, not just the Markdown file.

