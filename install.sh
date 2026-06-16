#!/usr/bin/env bash
# Install the km-installer Claude skill.
#   ./install.sh           -> global  (~/.claude/skills/km-installer)
#   ./install.sh .claude   -> project (./.claude/skills/km-installer)
set -euo pipefail

BASE="${1:-$HOME/.claude}"
SRC="$(cd "$(dirname "$0")" && pwd)/skills/km-installer/SKILL.md"
DEST="$BASE/skills/km-installer"

if [ ! -f "$SRC" ]; then
  echo "✗ Could not find $SRC — run this from a clone of the km-installer repo." >&2
  exit 1
fi

mkdir -p "$DEST"
cp "$SRC" "$DEST/SKILL.md"
echo "✓ km-installer installed to $DEST"
echo "  Restart Claude Code (or start a new session), then run /km-installer"
