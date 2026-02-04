# 🌱 ContextGardner

**Keep your Claude Code memory lean, organized, and under control.**

ContextGardner is a set of slash commands for [Claude Code](https://claude.ai/code) that help you review, prune, reorganize, and protect your `CLAUDE.md` memory files — including subdirectory memory, `.claude/rules/`, and subagent definitions.

As you use Claude Code, your `CLAUDE.md` grows with project context, completed task notes, debugging breadcrumbs, and one-off instructions that quickly become stale. ContextGardner gives you the tools to tend that garden without leaving your terminal.

## The Problem

Claude Code's `CLAUDE.md` is a powerful persistent memory, but it has no built-in way to:

- Review what's accumulated and decide what still matters
- Protect critical entries from being lost during cleanup
- Move context from a bloated root file into the right subdirectory, rule, or subagent
- Prune stale, redundant, or vague entries systematically

The result? A file that grows until it wastes context tokens on things that no longer apply.

## Commands

| Command | What it does |
|---|---|
| `/review-memory` | Interactive walkthrough of **all** memory files (root, subdirs, rules, agents). Step through every section and choose: keep, pin, unpin, prune, edit, merge, move, or skip. |
| `/prune-memory` | Automated analysis that categorizes entries as core, active, stale, redundant, or vague — then proposes changes for your approval. |
| `/move-memory` | Move a section from one memory file to another (e.g., root `CLAUDE.md` → a subagent or subdirectory). Handles destination scaffolding, placement, and source cleanup. |
| `/pin` | Mark a section or line as pinned (`<!-- pinned -->`) so it's preserved during any pruning operation. |

## Installation

### Prerequisites

- [Claude Code](https://claude.ai/code) installed and working on your machine
- macOS, Linux, or WSL on Windows

### Quick Install (Global)

```bash
git clone https://github.com/YOUR_USERNAME/context-gardner.git
cd context-gardner
./install.sh
```

This copies the commands to `~/.claude/commands/`, making them available in **every project**.

### Project-Only Install

To install for a single project instead:

```bash
cd /path/to/your/project
/path/to/context-gardner/install.sh project
```

This copies the commands to `.claude/commands/` in your current directory.

### Manual Install

If you prefer, just copy the files yourself:

```bash
# Global
cp commands/*.md ~/.claude/commands/

# Or project-level
mkdir -p .claude/commands
cp commands/*.md .claude/commands/
```

### Uninstall

```bash
# Global
./uninstall.sh

# Project-level
./uninstall.sh project
```

## Usage

### Review all memory interactively

```
/review-memory
```

This scans your project for every memory file and presents a **memory map** showing root memory, subdirectory memory, rules, and subagents with line counts. You choose a scope (`all`, `root`, `subdirs`, `rules`, `agents`, or `pick`), then walk through each section one at a time.

For each section, you choose an action:

- **keep** — no changes
- **pin** — protect from future pruning
- **unpin** — remove pin protection
- **prune** — mark for removal
- **edit** — provide replacement text
- **merge** — combine with another section in the same file
- **move** — relocate to a different memory file (triggers the `/move-memory` workflow inline)
- **skip** — revisit later

Navigation shortcuts during the walkthrough:

- **jump \<filename\>** — skip to a specific file
- **speed up** — batch the remaining sections in the current file
- **pause** — save progress and show decisions so far
- **status** — running tally across all files

Nothing is modified until you give final approval.

### Auto-prune with oversight

```
/prune-memory
```

Claude analyzes your `CLAUDE.md`, categorizes every entry, and proposes what to keep, remove, merge, or reword. You approve before anything changes. Respects `<!-- pinned -->` markers.

### Move context where it belongs

```
/move-memory "API conventions" to agent api-developer
/move-memory "React patterns" to rule frontend/react
/move-memory "Testing standards" to subdir src/tests
```

Or run without arguments for an interactive walkthrough. You choose what happens to the original: remove it, replace it with an `@import` reference, or keep a copy in both places.

### Pin important entries

```
/pin the build commands section
/pin "Always use named exports"
```

Adds `<!-- pinned -->` markers so the entry survives any pruning operation.

## How Pinning Works

ContextGardner uses HTML comments as pin markers, which are invisible in rendered markdown but preserved in the raw file:

**Single line:**
```markdown
- Always use named exports <!-- pinned -->
```

**Full section:**
```markdown
<!-- pinned -->
## Build Commands
- `npm run build` — production build
- `npm run dev` — start dev server on port 3000
<!-- /pinned -->
```

Pinned entries are never removed by `/prune-memory` and are clearly labeled during `/review-memory` walkthroughs.

## How Memory Files Work in Claude Code

Claude Code supports a hierarchy of memory files. ContextGardner works with all of them:

| Location | Scope | Loaded |
|---|---|---|
| `~/.claude/CLAUDE.md` | All projects | At launch |
| `./CLAUDE.md` | Project root | At launch |
| `./CLAUDE.local.md` | Project root (personal, gitignored) | At launch |
| `./src/api/CLAUDE.md` | Subdirectory | When Claude accesses files in that subtree |
| `.claude/rules/*.md` | Path-scoped rules | At launch (filtered by `paths:` frontmatter) |
| `.claude/agents/*.md` | Subagent definitions | When subagent is invoked |

As your project grows, moving context from the root into subdirectory files, rules, and subagents keeps your token budget focused on what's relevant to the current task.

## Project Structure

```
context-gardner/
├── commands/
│   ├── review-memory.md    # Interactive memory review
│   ├── prune-memory.md     # Automated pruning
│   ├── move-memory.md      # Move sections between files
│   └── pin.md              # Pin entries
├── install.sh              # Installer script
├── uninstall.sh            # Uninstaller script
├── CLAUDE.md               # Project memory for ContextGardner itself
├── LICENSE                  # MIT License
└── README.md               # This file
```

## Roadmap

- [ ] `/audit-memory` — Show token cost estimates per memory file and flag oversized files
- [ ] `/diff-memory` — Show what changed in memory files since the last git commit
- [ ] `/archive-memory` — Move pruned sections to a dated archive file instead of deleting them
- [ ] Hooks integration — Auto-run `/prune-memory` suggestions after N sessions
- [ ] Support for `CLAUDE.local.md` personal memory management

## Contributing

Contributions are welcome! This project is a set of markdown slash commands — no compiled code, no dependencies. To contribute:

1. Fork the repo
2. Create a branch for your command or improvement
3. Test it by copying your modified `.md` file to `~/.claude/commands/` and running it in Claude Code
4. Submit a PR with a description of what the command does and an example session

## License

MIT — see [LICENSE](LICENSE) for details.
