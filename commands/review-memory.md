Interactively review and manage memory across the project. This covers the root CLAUDE.md, subdirectory CLAUDE.md files, .claude/rules/, and subagent definitions in .claude/agents/. The same set of actions is available everywhere — no matter which file you're reviewing.

## Step 0: Discover all memory files

Scan the project and list every memory file found, grouped by type:

```
## Memory Map

### Root memory
- ./CLAUDE.md (N lines)
- ./CLAUDE.local.md (N lines)        ← if present

### Subdirectory memory
- ./src/api/CLAUDE.md (N lines)
- ./src/ui/CLAUDE.md (N lines)
- ...

### Rules
- ./.claude/rules/general.md (N lines)
- ./.claude/rules/frontend/react.md (N lines)
- ...

### Subagents
- ./.claude/agents/code-reviewer.md (N lines)
- ./.claude/agents/test-writer.md (N lines)
- ...

Total: X files, Y total lines
```

Then ask me which scope to review:

- **all** — walk through every file in the order listed above
- **root** — only the root CLAUDE.md (and CLAUDE.local.md if present)
- **subdirs** — only subdirectory CLAUDE.md files
- **rules** — only .claude/rules/ files
- **agents** — only .claude/agents/ subagent files
- **pick** — I'll name specific files to review

Wait for my response before proceeding.

## Step 1: Parse sections

For each file in the selected scope, read it and break it into logical sections:
- A markdown heading (any level) and all content under it until the next heading of the same or higher level
- Any top-level content before the first heading counts as its own section
- For subagent files, treat the YAML frontmatter as its own section labeled `[frontmatter]`
- For rules files with `paths:` frontmatter, treat the frontmatter as its own section labeled `[scope]`

## Step 2: Walk through each section one at a time

When transitioning to a new file, show a file header:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📄 .claude/agents/code-reviewer.md (File 3 of 7)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

For each section within the file, present it in this format:

```
── Section N of M ──────────────────────────

[Full content of the section as it currently appears]

────────────────────────────────────────────
Status: [pinned / not pinned]
Lines: [number of lines]
File:  [relative path to the file]
```

Then ask me to choose one of:

- **keep** — leave it as-is, no changes
- **pin** — mark it with `<!-- pinned -->` / `<!-- /pinned -->` so future pruning preserves it
- **unpin** — remove existing pin markers if present
- **prune** — mark it for removal
- **edit** — I'll provide replacement text for this section
- **merge** — I'll name another section (in the same file) to merge this one into
- **move** — relocate this section to a different memory file. This triggers the /move-memory workflow inline for this section. I'll be asked to choose a destination (with shortcuts: `subdir <path>`, `rule <name>`, `agent <name>`, or any file path), where to place it in the destination, and what to leave behind in the source (remove, replace with @reference, or keep copy). The section preview and confirmation happen at the end of the full review in Step 4, not immediately.
- **skip** — come back to this section later

Additional commands available at any point during the walkthrough:

- **jump <filename>** — skip ahead to a specific file
- **speed up** — show remaining sections in the current file as a batch and let me annotate them all at once
- **pause** — stop the walkthrough and save progress so far (show the summary of decisions made up to this point)
- **status** — show a running tally of decisions made so far across all files

Wait for my response before moving to the next section. Do not batch multiple sections together unless I ask you to speed up.

## Step 3: Show summary

After walking through all selected files, present a summary grouped by file:

```
## Review Summary

### ./CLAUDE.md
- Keeping: N sections
- Pinning: N sections
- Pruning: N sections
- Editing: N sections
- Merging: [section A] + [section B] → [proposed heading]
- Moving: [section] → [destination file] ([remove / @reference / keep copy])

### .claude/agents/code-reviewer.md
- Keeping: N sections
- Pruning: N sections
- ...

### Overall
- Files reviewed: X
- Sections reviewed: Y
- Sections pruned: Z
- Sections moved: W
- Estimated line reduction: N lines (X% smaller)
```

## Step 4: Confirm and apply

Ask me: "Apply these changes to all affected files?"

- If I say yes, apply all changes across all files.
- If I say no or ask for adjustments, revise the plan accordingly.
- For moved sections:
  - Create the destination file if it doesn't exist.
  - If the destination is a new subagent, scaffold it with minimal YAML frontmatter (name and description derived from the moved section, tools set to Read only) and show the frontmatter for my approval before writing.
  - If the destination is a new rules file, ask whether to add a `paths:` scope in the frontmatter and suggest a sensible default based on the destination path.
  - Apply the source-side action I chose (remove, replace with @reference, or keep copy).
  - Preserve any pin markers — if a section was pinned in the source, it stays pinned in the destination.
- After applying, show a before/after line count per file so I can see the impact.

## Rules

- Present sections in the order they appear in each file.
- Process files in the order listed in the memory map (root → subdirs → rules → agents).
- If a section is already pinned, show that clearly in the status line.
- Never skip a section unless I tell you to.
- Never modify any file until I give final approval in Step 4.
- If a file has no clear heading structure, break it into logical chunks of ~5-10 lines each and treat those as sections.
- For subagent files, never remove or alter the YAML frontmatter (name, description, tools, model) unless I explicitly choose **edit** on the `[frontmatter]` section.
- For rules files, never remove the `paths:` frontmatter unless I explicitly choose **edit** on the `[scope]` section.

$ARGUMENTS
