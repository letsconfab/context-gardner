Dispatch to a ContextGardner subcommand based on the first word of the arguments.

## Subcommand table

| Subcommand | Alias | Action |
|---|---|---|
| `review-memory` | `review` | Read and follow `review-memory.md` |
| `prune-memory` | `prune` | Read and follow `prune-memory.md` |
| `move-memory` | `move` | Read and follow `move-memory.md` |
| `pin` | — | Read and follow `pin.md` |
| `version` | `-v` | Print version from VERSION file |
| `help` | (none / empty) | Print usage summary |

## State tracking

Before dispatching, read `.claude/context-gardner-state.json`. If it does not exist, contains invalid JSON, or has an unknown `version`, note that this is a first run — the subcommand will handle it.

Check whether `--all` or the bare word `all` appears as a token anywhere in `$ARGUMENTS` (distinct from the subcommand or scope keywords). If found, strip it from the arguments and pass `--all` as the first token of the remaining arguments sent to the subcommand.

## Steps

1. Parse the first word of `$ARGUMENTS` as the subcommand. Everything after the first word becomes the remaining arguments to pass through to the subcommand. Also check for and strip `--all` as described in "State tracking" above.

2. Resolve aliases: `review` → `review-memory`, `prune` → `prune-memory`, `move` → `move-memory`, `-v` → `version`.

3. Route the subcommand:

   **If `version` or `-v`:** Read the `VERSION` file from the ContextGardner install directory (look for it alongside the command files — try `.claude/commands/../VERSION`, or the project root `VERSION` file). Print:
   ```
   ContextGardner v<version>
   ```

   **If `help` or no arguments provided:** Print the following usage summary and stop:
   ```
   ContextGardner — slash commands for managing Claude Code memory files.

   Usage: /context-gardner <command> [--all] [arguments]

   Commands:
     review-memory (review)  Interactive walkthrough of all memory files
     prune-memory  (prune)   Automated pruning with approval
     move-memory   (move)    Move sections between memory files
     pin                     Pin entries to protect from pruning
     version       (-v)      Show version
     help                    Show this message
   ```

   **If a known subcommand (`review-memory`, `prune-memory`, `move-memory`, `pin`):** Look for the matching `.md` file by checking these locations in order:
   - `.claude/commands/<subcommand>.md` (project-level)
   - `~/.claude/commands/<subcommand>.md` (global)

   Read the file, then follow its instructions exactly as if it were the current prompt. Treat the remaining arguments (everything after the subcommand) as that command's `$ARGUMENTS`. If `--all` was detected in the State tracking step, ensure it is included in the arguments passed to the subcommand.

   **If unrecognized:** Print:
   ```
   Unknown subcommand: "<word>"
   Run /context-gardner help for available commands.
   ```

4. After the subcommand finishes, update `.claude/context-gardner-state.json`: set `last_invoked` to the current ISO 8601 UTC timestamp. Write the file (create `.claude/` directory if needed). This ensures `last_invoked` is updated even if the subcommand made no changes.

## Rules

- Do not modify any files during dispatch — only the resolved subcommand may modify files (except the state file).
- If the subcommand file cannot be found in either location, tell the user and suggest running install.sh.
- Pass remaining arguments through verbatim — do not interpret them.
- When following a subcommand file, behave as if that file's instructions were given directly. Do not add extra confirmation steps beyond what the subcommand itself requires.
- Always update `last_invoked` in the state file after dispatch, even if the subcommand made no changes.

$ARGUMENTS
