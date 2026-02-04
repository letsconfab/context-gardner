#!/usr/bin/env bash
set -euo pipefail

# ContextGardner Installer
# Copies slash commands to Claude Code's global commands directory.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMANDS_SRC="$SCRIPT_DIR/commands"

# Determine install scope
SCOPE="${1:-global}"

if [ "$SCOPE" = "project" ]; then
    DEST=".claude/commands"
    echo "📂 Installing ContextGardner commands to project: $DEST"
elif [ "$SCOPE" = "global" ]; then
    DEST="$HOME/.claude/commands"
    echo "🌍 Installing ContextGardner commands globally: $DEST"
else
    echo "Usage: ./install.sh [global|project]"
    echo ""
    echo "  global   Install to ~/.claude/commands (available in all projects) [default]"
    echo "  project  Install to .claude/commands in the current directory"
    exit 1
fi

mkdir -p "$DEST"

COMMANDS=(
    "review-memory.md"
    "prune-memory.md"
    "move-memory.md"
    "pin.md"
)

INSTALLED=0
SKIPPED=0

for cmd in "${COMMANDS[@]}"; do
    if [ -f "$DEST/$cmd" ]; then
        read -r -p "  ⚠️  $cmd already exists. Overwrite? [y/N] " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            cp "$COMMANDS_SRC/$cmd" "$DEST/$cmd"
            echo "  ✅ Updated $cmd"
            ((INSTALLED++))
        else
            echo "  ⏭️  Skipped $cmd"
            ((SKIPPED++))
        fi
    else
        cp "$COMMANDS_SRC/$cmd" "$DEST/$cmd"
        echo "  ✅ Installed $cmd"
        ((INSTALLED++))
    fi
done

echo ""
echo "Done! $INSTALLED command(s) installed, $SKIPPED skipped."
echo ""
echo "Available commands:"
echo "  /review-memory  — Interactive walkthrough of all memory files"
echo "  /prune-memory   — Automated pruning with approval"
echo "  /move-memory    — Move sections between memory files"
echo "  /pin            — Pin a section to protect it from pruning"
echo ""
echo "🌱 Happy gardening!"
