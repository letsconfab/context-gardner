Move a section of memory from one memory file to another. Typically used to push context down from the root CLAUDE.md into a subdirectory CLAUDE.md, a .claude/rules/ file, a subagent in .claude/agents/, or the project's auto memory (~/.claude/projects/.../memory/).

## Step 0: Load state

1. Check whether `--all` or the bare word `all` appears anywhere in `$ARGUMENTS`. If found, strip it from the arguments and set the **all-files** flag.
2. Read `.claude/context-gardner-state.json`. If it does not exist, contains invalid JSON, or has an unknown `version`, treat this as a first run (equivalent to `--all`). Warn the user if the file was corrupt or had an unknown version.
3. Extract `last_invoked` from the state file.
4. When building the memory map (if needed), compare each file's filesystem mtime against `last_invoked` and annotate files as `[changed]`, `[new]`, or `[unchanged]`. Do NOT hide unchanged files — the user may want to move a section to an unchanged file. Suggest changed files first as likely sources.

## Step 1: Identify the source

If $ARGUMENTS is provided, use it to locate the section and destination. Examples:
- `/move-memory "API error handling" to .claude/agents/api-developer.md`
- `/move-memory "Testing conventions" to src/tests/CLAUDE.md`
- `/move-memory "React patterns" to .claude/rules/frontend/react.md`

If $ARGUMENTS is empty or ambiguous, scan the project for all memory files and show the memory map:

```
## Memory Map

### Root memory
- ./CLAUDE.md (N lines)
- ./CLAUDE.local.md (N lines)

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
```

Then ask: "Which file do you want to move a section FROM?"

## Step 2: Select the section to move

Parse the source file into sections (a markdown heading and all content under it until the next heading of the same or higher level). Present a numbered list:

```
## Sections in ./CLAUDE.md

1. [Project Overview] (5 lines)
2. [Build Commands] (8 lines) 📌
3. [API Conventions] (12 lines)
4. [Testing Standards] (9 lines)
5. [React Patterns] (14 lines)
6. [Git Workflow] (6 lines)
```

Then ask: "Which section(s) do you want to move? (number, range like 3-5, or comma-separated like 3,5)"

## Step 3: Choose the destination

Ask: "Where should this section go?"

Offer these shortcuts alongside any file path:

- **subdir <path>** — move to a CLAUDE.md in the specified subdirectory (e.g., `subdir src/api` → `src/api/CLAUDE.md`)
- **rule <name>** — move to a rules file (e.g., `rule frontend/react` → `.claude/rules/frontend/react.md`)
- **agent <name>** — move to a subagent file (e.g., `agent code-reviewer` → `.claude/agents/code-reviewer.md`)
- **memory** — move to the project's auto memory file (`~/.claude/projects/.../memory/MEMORY.md`)
- **new <path>** — create a brand new file at the specified path

Or I can type any relative file path directly.

## Step 4: Choose placement within the destination

If the destination file already exists and has content, show its current section headings:

```
## Existing sections in .claude/agents/code-reviewer.md

1. [frontmatter]
2. [Review Checklist]
3. [Severity Levels]
```

Then ask: "Where should the moved section be placed?"

- **top** — after frontmatter (if any), before all other content
- **bottom** — at the end of the file
- **after <N>** — after a specific existing section (e.g., `after 2`)
- **replace <N>** — replace an existing section with the moved content

If the destination file does not exist, it will be created with the moved section as its initial content.

## Step 5: Handle the source

Ask: "What should happen to the original section in the source file?"

- **remove** — delete it entirely from the source
- **replace with reference** — replace it with an @import pointing to the destination (e.g., `See @src/api/CLAUDE.md for API conventions`)
- **keep copy** — leave the original in place (resulting in the section existing in both files)

## Step 6: Preview and confirm

Show a side-by-side preview:

```
## Move Preview

### Source: ./CLAUDE.md
BEFORE (lines 18-29):
  ## API Conventions
  - All endpoints return JSON
  - Use standard error envelope
  ...

AFTER:
  See @src/api/CLAUDE.md for API conventions

### Destination: ./src/api/CLAUDE.md
BEFORE: [new file] or [existing content summary]

AFTER:
  [existing content...]

  ## API Conventions
  - All endpoints return JSON
  - Use standard error envelope
  ...

### Impact
- Source: N lines → M lines (delta)
- Destination: N lines → M lines (delta)
```

Ask: "Apply this move?"

- If I say yes, apply the changes to both files.
- If I say no, ask what to adjust.
- After applying, confirm with the final line counts for both files.

## Rules

- Never modify any file until I give explicit approval in Step 6.
- If the destination directory doesn't exist, create it.
- If moving to a subagent that doesn't exist yet, scaffold the file with a minimal YAML frontmatter (name and description derived from the section being moved, tools set to Read only) and ask me to review the frontmatter before applying.
- If moving to a rules file, ask whether to add a `paths:` frontmatter scope. Suggest a sensible default based on the destination path.
- Preserve any pin markers on the section being moved — if it was pinned in the source, it stays pinned in the destination.
- If multiple sections are selected, process them as a single batch move (all go to the same destination, previewed together).
- After applying the move, update `.claude/context-gardner-state.json`: set `last_invoked` to the current ISO 8601 UTC timestamp, and update `files` entries for both the source and destination files (`updated_at` to now, `updated_by` to `"move-memory"`, add `created_at` for new entries). Remove entries for files that no longer exist on disk.
- Never show `.claude/context-gardner-state.json` as a memory file.

$ARGUMENTS
