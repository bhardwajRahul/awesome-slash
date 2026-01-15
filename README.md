# Awesome Slash Commands

> Professional-grade workflow automation for AI coding assistants

A cross-platform plugin providing powerful, zero-configuration slash commands for development workflows. Works with **Claude Code**, **Codex CLI**, and **OpenCode**.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.0.0-blue)](https://github.com/avifenesh/awsome-slash/releases)
[![GitHub stars](https://img.shields.io/github/stars/avifenesh/awsome-slash?style=flat&color=yellow)](https://github.com/avifenesh/awsome-slash/stargazers)
[![Claude Code](https://img.shields.io/badge/Claude-Code%20Plugin-blue)](https://code.claude.com/)
[![Codex CLI](https://img.shields.io/badge/Codex-CLI%20Compatible-green)](https://developers.openai.com/codex/cli)
[![OpenCode](https://img.shields.io/badge/OpenCode-Compatible-orange)](https://opencode.ai)

## What's New in v2.0.0

- **Master Workflow Orchestrator** - `/next-task` now runs complete task-to-production workflows
- **State Management** - Resume interrupted workflows with `--resume`
- **8 Specialist Agents** - Opus for complex tasks, Sonnet for operations
- **Cross-Platform MCP Server** - Works with OpenCode and Codex CLI
- **Removed pr-merge** - Functionality absorbed into `/ship` and `/next-task`

---

## Installation

### Claude Code (Native)

```bash
# Option 1: Marketplace (recommended)
claude plugin marketplace add avifenesh/awsome-slash
claude plugin install next-task@awsome-slash ship@awsome-slash

# Option 2: Direct install
git clone https://github.com/avifenesh/awsome-slash.git
./scripts/install/claude.sh
```

### OpenCode

```bash
git clone https://github.com/avifenesh/awsome-slash.git
cd awsome-slash
./scripts/install/opencode.sh
```

### Codex CLI

```bash
git clone https://github.com/avifenesh/awsome-slash.git
cd awsome-slash
./scripts/install/codex.sh
```

---

## Available Commands

### 📋 `/next-task` - Master Workflow Orchestrator

Complete task-to-production automation with state management and resume capability.

```bash
/next-task                   # Start new workflow with policy selection
/next-task --status          # Check current workflow state
/next-task --resume          # Resume from last checkpoint
/next-task --abort           # Cancel workflow and cleanup
/next-task bug               # Filter by task type
```

**17-Phase Workflow:**
1. Policy Selection → Ask user preferences via checkboxes
2. Task Discovery → Find and prioritize tasks from GitHub/Linear/PLAN.md
3. Worktree Setup → Create isolated development environment
4. Exploration → Deep codebase analysis (opus)
5. Planning → Design implementation plan (opus)
6. User Approval → Get plan approval before implementation
7. Implementation → Execute the plan with quality code (opus)
8. Review Loop → Multi-agent review until approved (opus)
9. Ship → PR creation, CI monitoring, merge
10. Cleanup → Remove worktree, update state

**Features:**
- Resume capability with `.claude/.workflow-state.json`
- 8 specialist agents with model optimization
- Policy-based stopping points (pr-created, merged, deployed, production)

---

### 🚀 `/ship` - Complete PR Workflow

Ship your code from commit to production with full validation and state integration.

```bash
/ship                        # Default workflow
/ship --strategy rebase      # Rebase before merge
/ship --dry-run              # Show plan without executing
/ship --state-file PATH      # Integrate with next-task workflow
```

**12-Phase Workflow:**
1. Pre-flight checks and platform detection
2. Commit with AI-generated message
3. Create PR with context
4. Wait for CI
5. Multi-agent review (code quality, silent failures, test coverage)
6. Merge PR
7. Deploy to development (if multi-branch)
8. Validate development
9. Deploy to production
10. Validate production
11. Cleanup
12. Completion report

**Platform Support:**
- **CI:** GitHub Actions, GitLab CI, CircleCI, Jenkins, Travis CI
- **Deployment:** Railway, Vercel, Netlify, Fly.io, Platform.sh, Render

---

### 🧹 `/deslop-around` - AI Slop Cleanup

Remove debugging code, old TODOs, and AI slop from your codebase.

```bash
/deslop-around               # Report mode - analyze only
/deslop-around apply         # Apply fixes with verification
/deslop-around apply src/ 10 # Fix up to 10 issues in src/
```

**Detects:**
- Console debugging (`console.log`, `print()`, `dbg!()`)
- Old TODOs and commented code
- Placeholder text, magic numbers
- Empty catch blocks, disabled linters

---

### 🔍 `/project-review` - Multi-Agent Code Review

Comprehensive code review with specialized agents that iterate until zero issues.

```bash
/project-review              # Full codebase review
/project-review --recent     # Only recent changes
/project-review --domain security
```

**8 Specialized Agents:**
Security · Performance · Architecture · Testing · Error Handling · Code Quality · Type Safety · Documentation

---

## Cross-Platform Integration

All platforms share the same workflow tools via MCP (Model Context Protocol):

| Tool | Description |
|------|-------------|
| `workflow_status` | Get current workflow state |
| `workflow_start` | Start a new workflow |
| `workflow_resume` | Resume from checkpoint |
| `workflow_abort` | Cancel and cleanup |
| `task_discover` | Find and prioritize tasks |
| `review_code` | Run multi-agent review |

See [docs/CROSS_PLATFORM.md](./docs/CROSS_PLATFORM.md) for details.

---

## Architecture

### State Management

Workflows persist state in `.claude/.workflow-state.json`:

```json
{
  "workflow": { "id": "...", "status": "in_progress" },
  "policy": { "taskSource": "gh-issues", "stoppingPoint": "merged" },
  "task": { "id": "142", "title": "Fix auth timeout" },
  "phases": { "current": "implementation", "history": [...] },
  "checkpoints": { "canResume": true, "resumeFrom": "implementation" }
}
```

### Specialist Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| policy-selector | Sonnet | Configure workflow policy |
| task-discoverer | Sonnet | Find and prioritize tasks |
| worktree-manager | Sonnet | Create isolated worktrees |
| ci-monitor | Sonnet | Monitor CI/PR status |
| exploration-agent | **Opus** | Deep codebase analysis |
| planning-agent | **Opus** | Design implementation plans |
| implementation-agent | **Opus** | Execute plans with quality |
| review-orchestrator | **Opus** | Multi-agent code review |

---

## Repository Structure

```
awsome-slash/
├── .claude-plugin/
│   └── marketplace.json      # Claude Code marketplace manifest
├── plugins/
│   ├── next-task/           # Master workflow orchestrator
│   │   ├── commands/
│   │   └── agents/          # 8 specialist agents
│   ├── ship/                # PR workflow
│   ├── deslop-around/       # AI slop cleanup
│   └── project-review/      # Multi-agent review
├── lib/
│   ├── state/               # Workflow state management
│   ├── platform/            # Auto-detection
│   └── patterns/            # Code analysis patterns
├── mcp-server/              # Cross-platform MCP server
├── scripts/install/         # Platform installers
└── docs/
```

---

## Requirements

**Required:**
- Git
- Node.js 18+
- GitHub CLI (`gh`) with authentication

**For Claude Code:**
- Claude Code CLI

**For OpenCode:**
- OpenCode CLI (`opencode`)

**For Codex CLI:**
- Codex CLI (`codex`)

---

## Contributing

Contributions welcome! See [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

MIT © [Avi Fenesh](https://github.com/avifenesh)

## Support

- **Issues:** https://github.com/avifenesh/awsome-slash/issues
- **Discussions:** https://github.com/avifenesh/awsome-slash/discussions

---

Made with ❤️ for the AI coding community
