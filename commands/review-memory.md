Autonomously review and manage memory across the project. This covers the root CLAUDE.md, auto memory files (~/.claude/projects/.../memory/), subdirectory CLAUDE.md files, .claude/rules/, and subagent definitions in .claude/agents/.

**This command works autonomously.** You read everything, make your own decisions, present a single proposal, and wait for one approval before applying.

## Step 0a: Load state and determine filtering

1. Check whether `--all` or the bare word `all` appears anywhere in `$ARGUMENTS` (but not as part of the scope keyword). If found, strip it from the arguments and set the **all-files** flag.
2. Read `.claude/context-gardner-state.json`. If it does not exist, contains invalid JSON, or has an unknown `version`, treat this as a first run (equivalent to `--all`). Warn the user if the file was corrupt or had an unknown version.
3. Extract `last_invoked` from the state file.

## Step 0b: Determine scope

If `$ARGUMENTS` contains a scope keyword, use it:

- **all** — every memory file
- **root** — only the root CLAUDE.md (and CLAUDE.local.md if present)
- **memory** — only auto memory files (~/.claude/projects/.../memory/)
- **subdirs** — only subdirectory CLAUDE.md files
- **rules** — only .claude/rules/ files
- **agents** — only .claude/agents/ subagent files

If no scope keyword is provided, default to **all**.

## Step 1: Discover all memory files

Scan the project and list every memory file found, grouped by type. Never include `.claude/context-gardner-state.json` itself.

```
## Memory Map

### Root memory
- ./CLAUDE.md (N lines)
- ./CLAUDE.local.md (N lines)        ← if present

### Auto memory
- ~/.claude/projects/.../memory/MEMORY.md (N lines)
- ~/.claude/projects/.../memory/other.md (N lines)   ← if any

### Subdirectory memory
- ./src/api/CLAUDE.md (N lines)
- ...

### Rules
- ./.claude/rules/general.md (N lines)
- ...

### Subagents
- ./.claude/agents/code-reviewer.md (N lines)
- ...

Total: X files, Y total lines
```

For each file in the memory map, compare its filesystem mtime (use `stat`) against `last_invoked`:
- Annotate each file as `[changed]`, `[new]` (not in state `files` map), or `[unchanged]`.
- Unless the **all-files** flag is set, only include `[changed]` and `[new]` files in the review scope.
- After the memory map, show a filter summary:
  ```
  Reviewing N changed files (M unchanged hidden — use --all to include them).
  ```
- If zero files are changed/new and `--all` was not used, print:
  ```
  No memory files have changed since the last run.
  Use --all to review all files regardless.
  ```
  Do NOT update `last_invoked`. Stop here.

## Step 2: Autonomous analysis

For each file in scope, read it and break it into logical sections:
- A markdown heading (any level) and all content under it until the next heading of the same or higher level
- Any top-level content before the first heading counts as its own section
- For subagent files, treat the YAML frontmatter as its own section labeled `[frontmatter]`
- For rules files with `paths:` frontmatter, treat the frontmatter as its own section labeled `[scope]`

**Autonomously decide** what to do with each section using these criteria:

| Decision | When to use |
|----------|-------------|
| **keep** | Accurate, useful, not duplicated, still relevant |
| **prune** | Outdated, factually wrong, stale task references, one-off debugging notes, or content that no longer applies |
| **edit** | Mostly correct but needs updating (outdated values, missing new info, could be sharper) |
| **merge** | Two or more sections in the same file cover the same topic |
| **move** | Section belongs in a more specific file (e.g., detailed API notes → subdirectory CLAUDE.md) |
| **pin** | Critical instructions that must never be pruned |

**Decision guidelines:**
- Cross-reference facts against the actual codebase — read key files to verify claims
- Remove entries that duplicate what's obvious from the code
- Remove generic advice ("write clean code", "follow best practices")
- Preserve build/test/lint commands, architecture decisions, and project-specific conventions
- Never prune or edit `<!-- pinned -->` sections (keep them as-is)
- Never remove or alter subagent YAML frontmatter unless it contains errors
- Never remove rules file `paths:` frontmatter unless it's wrong

**Do NOT ask the user any questions during analysis.** Make your best judgment call on every section.

## Step 3: Present proposal

Present a single summary grouped by file:

```
## Review Proposal

### ./CLAUDE.md
| # | Section | Decision | Reason |
|---|---------|----------|--------|
| 1 | Project Overview | keep | Accurate and essential |
| 2 | Build Commands | keep | Core reference |
| 3 | Old Debug Notes | prune | One-off fix, no longer relevant |
| 4 | API Conventions | edit | Missing new endpoint added last week |

#### Edits
**Section 4 — API Conventions**
```diff
- Supports 3 endpoints: /members, /visits, /admin
+ Supports 4 endpoints: /members, /visits, /admin, /events (SSE)
```

### ~/.claude/projects/.../memory/MEMORY.md
| # | Section | Decision | Reason |
|---|---------|----------|--------|
| 1 | User Preferences | keep | Active preference |
| 2 | Old Workaround | prune | Bug was fixed |

### Overall
- Files reviewed: X
- Sections reviewed: Y
- Keeping: N sections
- Pruning: N sections (estimated -M lines)
- Editing: N sections
```

For edits, show a clear diff or before/after of what will change.
For merges, show the proposed merged section.
For moves, show source → destination.

Then ask: **"Apply these changes?"**

## Step 4: Apply changes

- If the user says yes (or any affirmative), apply all changes across all files.
- If the user says no or asks for adjustments, revise the proposal accordingly and re-present only the changed parts.
- For moved sections:
  - Create the destination file if it doesn't exist.
  - If the destination is a new subagent, scaffold it with minimal YAML frontmatter.
  - If the destination is a new rules file, add a `paths:` scope based on the destination path.
  - Preserve any pin markers.
- After applying, show a before/after line count per file.

## Step 5: Update state

After applying approved changes:

1. Read `.claude/context-gardner-state.json` (or start with `{ "version": 1, "files": {} }` if missing).
2. Set `last_invoked` to the current ISO 8601 UTC timestamp.
3. For each file that was modified during this run:
   - If the path is not in `files`, add it with `created_at` and `updated_at` both set to the current timestamp, and `updated_by` set to `"review-memory"`.
   - If the path already exists, update `updated_at` to the current timestamp and set `updated_by` to `"review-memory"`.
4. Remove any entries in `files` whose paths no longer exist on disk.
5. Write the updated JSON to `.claude/context-gardner-state.json`.

## Rules

- **Never ask the user questions during analysis.** All decisions are autonomous.
- **The only user interaction is approving or rejecting the final proposal.**
- Process files in the order listed in the memory map (root → auto memory → subdirs → rules → agents).
- If a section is already pinned, always keep it — never prune or edit pinned sections.
- Never modify any file until the user gives final approval in Step 4.
- If a file has no clear heading structure, break it into logical chunks of ~5-10 lines each.
- For subagent files, never remove or alter the YAML frontmatter unless it contains factual errors.
- For rules files, never remove the `paths:` frontmatter unless it's wrong.
- When invoked directly (not via the dispatcher), handle `--all` parsing and state updates independently.
- Never show `.claude/context-gardner-state.json` as a memory file.

$ARGUMENTS
