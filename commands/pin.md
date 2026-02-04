Mark the specified entry or section in CLAUDE.md or auto memory files as pinned so it is preserved during pruning.

## How to pin

- If the target is a single line (a bullet point, a command, a note), append `<!-- pinned -->` to the end of that line.
- If the target is an entire section (a heading and everything under it), wrap it with `<!-- pinned -->` above the heading and `<!-- /pinned -->` after the last line of the section.

## Examples

Single line:
```
- Always use named exports <!-- pinned -->
```

Full section:
```
<!-- pinned -->
## Build Commands
- `npm run build` — production build
- `npm run dev` — start dev server on port 3000
<!-- /pinned -->
```

## Rules

- Do not modify the content of the entry — only add the pin markers.
- If the entry is already pinned, let me know and make no changes.
- After pinning, confirm what was pinned and show the updated lines.

## Update state

After pinning is complete and confirmed:

1. Read `.claude/context-gardner-state.json`. If it does not exist or contains invalid JSON, start with `{ "version": 1, "files": {} }`.
2. Set `last_invoked` to the current ISO 8601 UTC timestamp.
3. For the file that was modified:
   - If the path is not in `files`, add it with `created_at` and `updated_at` both set to the current timestamp, and `updated_by` set to `"pin"`.
   - If the path already exists, update `updated_at` to the current timestamp and set `updated_by` to `"pin"`.
4. Write the updated JSON to `.claude/context-gardner-state.json` (create `.claude/` directory if needed).

$ARGUMENTS
