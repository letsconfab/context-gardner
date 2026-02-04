# ContextGardner

A set of Claude Code slash commands for managing CLAUDE.md memory files. No compiled code — just markdown command definitions and shell scripts.

## Project Structure

- `commands/` — Slash command definitions (markdown files with $ARGUMENTS placeholders)
- `install.sh` — Copies commands to ~/.claude/commands/ or .claude/commands/
- `uninstall.sh` — Removes installed commands
- `README.md` — User-facing documentation
- `CLAUDE.md` — This file

## Commands

Four slash commands, each a standalone markdown file:

- `review-memory.md` — Interactive section-by-section walkthrough of all memory files (root CLAUDE.md, subdirectory CLAUDE.md files, .claude/rules/, .claude/agents/). Supports scoping (all, root, subdirs, rules, agents, pick). Actions per section: keep, pin, unpin, prune, edit, merge, move, skip. Navigation: jump, speed up, pause, status. All changes batched and applied only after final confirmation.
- `prune-memory.md` — Automated analysis that categorizes entries as core, active, stale, redundant, or vague. Proposes changes, waits for approval. Respects `<!-- pinned -->` markers. Targets under 80 lines when possible.
- `move-memory.md` — Moves a section from one memory file to another. Supports shortcuts (subdir, rule, agent, new). Handles destination scaffolding (subagent frontmatter, rules path scope). Three source options: remove, replace with @reference, keep copy. Preview before applying.
- `pin.md` — Adds `<!-- pinned -->` / `<!-- /pinned -->` markers to entries or sections. Single-line and block pinning. Does not modify content, only adds markers.

## Conventions

- Every command must wait for user confirmation before modifying any file.
- Pin markers use HTML comments: `<!-- pinned -->` for single lines, `<!-- pinned -->` / `<!-- /pinned -->` wrapping for sections.
- Commands use `$ARGUMENTS` for pass-through arguments from the slash command invocation.
- All commands should work with the full Claude Code memory hierarchy: user-level (~/.claude/CLAUDE.md), project root (./CLAUDE.md), local (./CLAUDE.local.md), subdirectory CLAUDE.md files, .claude/rules/*.md, and .claude/agents/*.md.

## Writing Style for Commands

- Direct, imperative instructions — no conversational filler.
- Use markdown code blocks for any formatted output the command should produce.
- Structure as numbered steps with clear decision points.
- Always include a "Rules" section at the end with hard constraints.
- End with `$ARGUMENTS` on its own line.

## Testing Changes

To test a modified command, copy it to your global commands directory and run it:

```
cp commands/review-memory.md ~/.claude/commands/
```

Then open Claude Code in any project and run `/review-memory`.
