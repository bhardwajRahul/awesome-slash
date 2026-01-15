#!/bin/bash
# Install awesome-slash for Codex CLI
# Usage: ./scripts/install/codex.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Installing awesome-slash for Codex CLI..."
echo "Plugin root: $PLUGIN_ROOT"

# Check if Codex config directory exists
CODEX_CONFIG="${CODEX_CONFIG:-$HOME/.codex}"
if [ ! -d "$CODEX_CONFIG" ]; then
  echo "Creating Codex config directory..."
  mkdir -p "$CODEX_CONFIG"
fi

# Install MCP server dependencies
echo "Installing MCP server dependencies..."
cd "$PLUGIN_ROOT/mcp-server"
npm install --production

# Create MCP config for Codex
MCP_CONFIG="$CODEX_CONFIG/mcp.json"
echo "Configuring MCP server in $MCP_CONFIG..."

if [ -f "$MCP_CONFIG" ]; then
  cp "$MCP_CONFIG" "$MCP_CONFIG.backup"
  echo "Backed up existing config to $MCP_CONFIG.backup"
fi

# Check if jq is available
if command -v jq &> /dev/null; then
  if [ -f "$MCP_CONFIG.backup" ]; then
    jq --arg root "$PLUGIN_ROOT" '.mcpServers["awesome-slash"] = {
      "command": "node",
      "args": [($root + "/mcp-server/index.js")],
      "env": {"PLUGIN_ROOT": $root}
    }' "$MCP_CONFIG.backup" > "$MCP_CONFIG"
  else
    jq -n --arg root "$PLUGIN_ROOT" '{
      "mcpServers": {
        "awesome-slash": {
          "command": "node",
          "args": [($root + "/mcp-server/index.js")],
          "env": {"PLUGIN_ROOT": $root}
        }
      }
    }' > "$MCP_CONFIG"
  fi
else
  cat > "$MCP_CONFIG" << EOF
{
  "mcpServers": {
    "awesome-slash": {
      "command": "node",
      "args": ["$PLUGIN_ROOT/mcp-server/index.js"],
      "env": {
        "PLUGIN_ROOT": "$PLUGIN_ROOT"
      }
    }
  }
}
EOF
fi

# Create custom skills for Codex
SKILLS_DIR="$CODEX_CONFIG/skills"
mkdir -p "$SKILLS_DIR"

echo "Installing Codex skills..."

# Next-task skill
cat > "$SKILLS_DIR/next-task.yaml" << EOF
name: next-task
description: Find and implement the next priority task with full workflow automation
trigger: "next task|what should I work on|find task|prioritize"
tools:
  - awesome-slash:workflow_status
  - awesome-slash:workflow_start
  - awesome-slash:task_discover
instructions: |
  Use the awesome-slash MCP tools to manage workflow:
  1. Check workflow_status for existing workflow
  2. If none, use workflow_start to begin
  3. Use task_discover to find priority tasks
  4. Guide user through task selection and implementation
EOF

# Ship skill
cat > "$SKILLS_DIR/ship.yaml" << EOF
name: ship
description: Complete PR workflow from commit to production
trigger: "ship|create pr|merge|deploy"
tools:
  - awesome-slash:workflow_status
  - awesome-slash:review_code
instructions: |
  Use the awesome-slash MCP tools to ship code:
  1. Check workflow_status for current state
  2. Run review_code for multi-agent review
  3. Guide user through PR creation and merge
EOF

# Review skill
cat > "$SKILLS_DIR/review.yaml" << EOF
name: review
description: Run multi-agent code review on changes
trigger: "review code|check code|code review"
tools:
  - awesome-slash:review_code
instructions: |
  Use review_code to run multi-agent review:
  - Code quality analysis
  - Silent failure detection
  - Test coverage analysis
  Auto-fix critical and high issues, report medium/low.
EOF

echo ""
echo "✓ Installation complete!"
echo ""
echo "Usage:"
echo "  1. Start Codex: codex"
echo "  2. Skills available: /next-task, /ship, /review"
echo "  3. MCP tools: workflow_status, workflow_start, etc."
echo ""
echo "To verify installation:"
echo "  codex config list"
echo "  codex mcp list"
