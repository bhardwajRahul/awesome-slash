#!/usr/bin/env bash
# Sync shared lib/ to all plugins for local development/usage
# Run this after cloning or when lib/ files are updated

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Syncing lib/ to all plugins..."

PLUGINS=(
  "deslop-around"
  "next-task"
  "pr-merge"
  "project-review"
  "ship"
)

for plugin in "${PLUGINS[@]}"; do
  PLUGIN_LIB="$REPO_ROOT/plugins/$plugin/lib"
  
  # Create lib directory structure
  mkdir -p "$PLUGIN_LIB"/{platform,patterns,utils}
  
  # Copy all lib files
  cp -r "$REPO_ROOT/lib/"* "$PLUGIN_LIB/"
  
  echo "  ✓ $plugin"
done

echo ""
echo "Done! All plugins now have local lib/ copies."
