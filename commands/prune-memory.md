Review the CLAUDE.md and auto memory files (~/.claude/projects/.../memory/) in this project and prune them to keep them focused and effective. Follow these steps:

## 0. Load state and filter

1. Check whether `--all` or the bare word `all` appears anywhere in `$ARGUMENTS`. If found, strip it from the arguments and set the **all-files** flag.
2. Read `.claude/context-gardner-state.json`. If it does not exist, contains invalid JSON, or has an unknown `version`, treat this as a first run (equivalent to `--all`). Warn the user if the file was corrupt or had an unknown version.
3. Extract `last_invoked` from the state file.
4. For each memory file discovered, compare its filesystem mtime (use `stat`) against `last_invoked`:
   - Include the file if its mtime > `last_invoked`, or if the file path is not yet in the state `files` map.
   - If the **all-files** flag is set, include every file regardless.
5. If zero files qualify and `--all` was not used, print:
   ```
   No memory files have changed since the last run.
   Use --all to review all files regardless.
   ```
   Do NOT update `last_invoked`. Stop here.

## 1. Analyze all memory files

Discover and read the project's CLAUDE.md and any auto memory files (MEMORY.md and other .md files in ~/.claude/projects/.../memory/). Categorize every entry into one of these buckets:

- **Core**: Project identity, tech stack, architecture, coding standards, build/test/lint commands — things that are always relevant
- **Active**: Current workflows, recent decisions, in-progress conventions — things that matter right now
- **Stale**: References to completed tasks, old debugging notes, one-off fixes, outdated warnings, or context that no longer applies
- **Redundant**: Duplicate or near-duplicate entries, instructions that restate what's already obvious from the codebase
- **Vague**: Entries that are too generic to be actionable (e.g., "write clean code", "follow best practices")

## 2. Propose changes

When multiple files are in scope, group proposals by file. Present a summary in this format:

```
## ./CLAUDE.md

### Keeping (N entries)
- [brief description of each kept entry and why]

### Removing (N entries)
- [brief description of each removed entry and why]

### Merging (N entries → M entries)
- [which entries are being consolidated and the proposed merged version]

### Rewording (N entries)
- [entries that are kept but sharpened for clarity]

## ~/.claude/projects/.../memory/MEMORY.md

### Keeping (N entries)
- ...

### Removing (N entries)
- ...
```

If only one file is in scope, omit the file-level headings.

## 3. Wait for confirmation

Do NOT modify any file until I explicitly approve the changes. If I ask you to keep something you proposed removing, adjust accordingly.

## 4. Apply changes

Once approved, rewrite each affected file with these guidelines:

- Keep total length under 80 lines per file if possible (unless the project genuinely needs more)
- Use clear markdown headings to group related instructions
- Put the most important context (stack, commands, architecture) at the top
- Remove any conversational tone — every line should be a direct, actionable instruction or fact
- Preserve any entries marked with `<!-- pinned -->` regardless of other criteria

## 5. Update state

After applying approved changes:

1. Read `.claude/context-gardner-state.json` (or start with `{ "version": 1, "files": {} }` if missing).
2. Set `last_invoked` to the current ISO 8601 UTC timestamp.
3. For each file that was modified during this run:
   - If the path is not in `files`, add it with `created_at` and `updated_at` both set to the current timestamp, and `updated_by` set to `"prune-memory"`.
   - If the path already exists, update `updated_at` to the current timestamp and set `updated_by` to `"prune-memory"`.
4. Remove any entries in `files` whose paths no longer exist on disk.
5. Write the updated JSON to `.claude/context-gardner-state.json`.

$ARGUMENTS
