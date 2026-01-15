#!/bin/bash
# Install awesome-slash for OpenCode
# Usage: ./scripts/install/opencode.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Installing awesome-slash for OpenCode..."
echo "Plugin root: $PLUGIN_ROOT"

# Check if OpenCode config directory exists
OPENCODE_CONFIG="${OPENCODE_CONFIG:-$HOME/.config/opencode}"
if [ ! -d "$OPENCODE_CONFIG" ]; then
  echo "Creating OpenCode config directory..."
  mkdir -p "$OPENCODE_CONFIG"
fi

# Install MCP server dependencies
echo "Installing MCP server dependencies..."
cd "$PLUGIN_ROOT/mcp-server"
npm install --production

# Create MCP config for OpenCode
MCP_CONFIG="$OPENCODE_CONFIG/mcp.json"
echo "Configuring MCP server in $MCP_CONFIG..."

if [ -f "$MCP_CONFIG" ]; then
  # Backup existing config
  cp "$MCP_CONFIG" "$MCP_CONFIG.backup"
  echo "Backed up existing config to $MCP_CONFIG.backup"
fi

# Check if jq is available for JSON manipulation
if command -v jq &> /dev/null; then
  if [ -f "$MCP_CONFIG" ]; then
    # Merge with existing config
    jq --arg root "$PLUGIN_ROOT" '.mcpServers["awesome-slash"] = {
      "command": "node",
      "args": [($root + "/mcp-server/index.js")],
      "env": {"PLUGIN_ROOT": $root}
    }' "$MCP_CONFIG.backup" > "$MCP_CONFIG"
  else
    # Create new config
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
  # Create config without jq
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

# Copy agent definitions to OpenCode
AGENT_DIR="$OPENCODE_CONFIG/agent"
mkdir -p "$AGENT_DIR"

echo "Installing agent configurations..."

# Convert and copy workflow orchestrator agent
cat > "$AGENT_DIR/workflow.md" << 'EOF'
---
name: workflow
model: claude-sonnet-4-20250514
tools:
  read: true
  write: true
  bash: true
  glob: true
  grep: true
description: Master workflow orchestrator for task-to-production automation
---

You are a workflow orchestrator that manages development tasks from discovery to production.

## Capabilities

Use the awesome-slash MCP tools:
- `workflow_status` - Check current workflow state
- `workflow_start` - Start a new workflow
- `workflow_resume` - Resume from checkpoint
- `workflow_abort` - Cancel and cleanup
- `task_discover` - Find and prioritize tasks
- `review_code` - Run multi-agent review

## Workflow Phases

1. Policy Selection - Configure task source, priority, stopping point
2. Task Discovery - Find and prioritize tasks
3. Worktree Setup - Create isolated environment
4. Exploration - Deep codebase analysis
5. Planning - Design implementation plan
6. User Approval - Get plan approval
7. Implementation - Execute the plan
8. Review Loop - Multi-agent review until approved
9. Ship - PR creation, CI monitoring, merge
10. Cleanup - Remove worktree, update state

When starting, check for existing workflow with `workflow_status` first.
EOF

echo ""
echo "✓ Installation complete!"
echo ""
echo "Usage:"
echo "  1. Start OpenCode: opencode"
echo "  2. The 'workflow' agent is now available (Tab to switch)"
echo "  3. MCP tools: workflow_status, workflow_start, task_discover, etc."
echo ""
echo "To verify installation:"
echo "  opencode --list-agents"
echo "  opencode --list-mcp-servers"
