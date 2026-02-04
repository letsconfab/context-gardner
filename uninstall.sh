#!/usr/bin/env bash
set -euo pipefail

# ContextGardner Uninstaller
# Removes slash commands from Claude Code's commands directory.

SCOPE="${1:-global}"

if [ "$SCOPE" = "project" ]; then
    DEST=".claude/commands"
    echo "📂 Uninstalling ContextGardner commands from project: $DEST"
elif [ "$SCOPE" = "global" ]; then
    DEST="$HOME/.claude/commands"
    echo "🌍 Uninstalling ContextGardner commands globally: $DEST"
else
    echo "Usage: ./uninstall.sh [global|project]"
    echo ""
    echo "  global   Remove from ~/.claude/commands [default]"
    echo "  project  Remove from .claude/commands in the current directory"
    exit 1
fi

COMMANDS=(
    "review-memory.md"
    "prune-memory.md"
    "move-memory.md"
    "pin.md"
)

REMOVED=0

for cmd in "${COMMANDS[@]}"; do
    if [ -f "$DEST/$cmd" ]; then
        rm "$DEST/$cmd"
        echo "  🗑️  Removed $cmd"
        ((REMOVED++))
    fi
done

echo ""
if [ "$REMOVED" -eq 0 ]; then
    echo "No ContextGardner commands found in $DEST"
else
    echo "Done! $REMOVED command(s) removed."
fi
