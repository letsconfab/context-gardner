Review the CLAUDE.md file in this project and prune it to keep it focused and effective. Follow these steps:

## 1. Analyze the current file

Read the full CLAUDE.md and categorize every entry into one of these buckets:

- **Core**: Project identity, tech stack, architecture, coding standards, build/test/lint commands — things that are always relevant
- **Active**: Current workflows, recent decisions, in-progress conventions — things that matter right now
- **Stale**: References to completed tasks, old debugging notes, one-off fixes, outdated warnings, or context that no longer applies
- **Redundant**: Duplicate or near-duplicate entries, instructions that restate what's already obvious from the codebase
- **Vague**: Entries that are too generic to be actionable (e.g., "write clean code", "follow best practices")

## 2. Propose changes

Present a summary in this format:

```
### Keeping (N entries)
- [brief description of each kept entry and why]

### Removing (N entries)
- [brief description of each removed entry and why]

### Merging (N entries → M entries)
- [which entries are being consolidated and the proposed merged version]

### Rewording (N entries)
- [entries that are kept but sharpened for clarity]
```

## 3. Wait for confirmation

Do NOT modify the file until I explicitly approve the changes. If I ask you to keep something you proposed removing, adjust accordingly.

## 4. Apply changes

Once approved, rewrite the CLAUDE.md with these guidelines:

- Keep total length under 80 lines if possible (unless the project genuinely needs more)
- Use clear markdown headings to group related instructions
- Put the most important context (stack, commands, architecture) at the top
- Remove any conversational tone — every line should be a direct, actionable instruction or fact
- Preserve any entries marked with `<!-- pinned -->` regardless of other criteria

$ARGUMENTS
