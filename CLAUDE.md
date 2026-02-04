# ContextGardner

A set of Claude Code slash commands for managing CLAUDE.md memory files. No compiled code — just markdown command definitions and shell scripts.

## Project Structure

- `commands/` — Slash command definitions (markdown files with $ARGUMENTS placeholders)
- `install.sh` — Copies commands to ~/.claude/commands/ or .claude/commands/
- `uninstall.sh` — Removes installed commands
- `README.md` — User-facing documentation
- `CLAUDE.md` — This file

## Commands

Five slash commands. `/context-gardner` is the unified entry point that dispatches to the others. Individual commands remain available for backward compatibility.

- `review-memory.md` — Interactive section-by-section walkthrough of all memory files (root CLAUDE.md, auto memory, subdirectory CLAUDE.md files, .claude/rules/, .claude/agents/). Supports scoping (all, root, memory, subdirs, rules, agents, pick). Actions per section: keep, pin, unpin, prune, edit, merge, move, skip. Navigation: jump, speed up, pause, status. All changes batched and applied only after final confirmation.
- `prune-memory.md` — Automated analysis of CLAUDE.md and auto memory files. Categorizes entries as core, active, stale, redundant, or vague. Proposes changes grouped by file, waits for approval. Respects `<!-- pinned -->` markers. Targets under 80 lines per file when possible.
- `move-memory.md` — Moves a section from one memory file to another. Supports shortcuts (subdir, rule, agent, memory, new). Handles destination scaffolding (subagent frontmatter, rules path scope). Three source options: remove, replace with @reference, keep copy. Preview before applying.
- `pin.md` — Adds `<!-- pinned -->` / `<!-- /pinned -->` markers to entries or sections in CLAUDE.md and auto memory files. Single-line and block pinning. Does not modify content, only adds markers.
- `context-gardner.md` — Dispatcher command. Parses the first word of its arguments as a subcommand (`review-memory`, `prune-memory`, `move-memory`, `pin`, `version`, `help`) with short aliases (`review`, `prune`, `move`, `-v`). Resolves the subcommand `.md` file from `.claude/commands/` or `~/.claude/commands/` and follows it.

## Conventions

- Every command must wait for user confirmation before modifying any file.
- Pin markers use HTML comments: `<!-- pinned -->` for single lines, `<!-- pinned -->` / `<!-- /pinned -->` wrapping for sections.
- Commands use `$ARGUMENTS` for pass-through arguments from the slash command invocation.
- All commands should work with the full Claude Code memory hierarchy: user-level (~/.claude/CLAUDE.md), project root (./CLAUDE.md), local (./CLAUDE.local.md), auto memory (~/.claude/projects/*/memory/), subdirectory CLAUDE.md files, .claude/rules/*.md, and .claude/agents/*.md.

## State Tracking

- Commands use a sidecar state file at `.claude/context-gardner-state.json` to track when they were last run and which files were modified.
- Schema: `{ "version": 1, "last_invoked": "<ISO 8601>", "files": { "<path>": { "created_at", "updated_at", "updated_by" } } }`.
- By default, `review-memory` and `prune-memory` only show memory files whose mtime is newer than `last_invoked`. First run (no state file) shows all files.
- `--all` flag bypasses change filtering and shows every file.
- `move-memory` annotates files as changed/new/unchanged but does not hide any (user may need unchanged files as destinations).
- The state file is never treated as a memory file by any command.
- Invalid or corrupt state JSON triggers a warning and is treated as a first run.

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
