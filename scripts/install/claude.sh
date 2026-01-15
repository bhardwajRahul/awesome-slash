#!/bin/bash
# Install awesome-slash plugins for Claude Code
# Usage: ./scripts/install/claude.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Installing awesome-slash for Claude Code..."
echo "Plugin root: $PLUGIN_ROOT"

# Check if Claude Code is available
if ! command -v claude &> /dev/null; then
  echo "Error: Claude Code CLI not found"
  echo "Install from: https://claude.ai/code"
  exit 1
fi

# Install each plugin
echo ""
echo "Installing plugins..."

for plugin in next-task ship deslop-around project-review; do
  PLUGIN_PATH="$PLUGIN_ROOT/plugins/$plugin"
  if [ -d "$PLUGIN_PATH" ]; then
    echo "  Installing $plugin..."
    claude plugin add "$PLUGIN_PATH" 2>/dev/null || echo "    (already installed or error)"
  fi
done

# Install lib dependencies
echo ""
echo "Installing dependencies..."
cd "$PLUGIN_ROOT"
npm install --production

echo ""
echo "✓ Installation complete!"
echo ""
echo "Available commands:"
echo "  /next-task          - Master workflow orchestrator"
echo "  /next-task --status - Check workflow state"
echo "  /next-task --resume - Resume from checkpoint"
echo "  /ship               - Complete PR workflow"
echo "  /deslop-around      - AI slop cleanup"
echo "  /project-review     - Multi-agent code review"
echo ""
echo "To verify installation:"
echo "  claude plugin list"
