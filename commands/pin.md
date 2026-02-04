Mark the specified entry or section in CLAUDE.md as pinned so it is preserved during pruning.

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

$ARGUMENTS
