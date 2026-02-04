Review the CLAUDE.md and auto memory files (~/.claude/projects/.../memory/) in this project and prune them to keep them focused and effective. Follow these steps:

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

$ARGUMENTS
