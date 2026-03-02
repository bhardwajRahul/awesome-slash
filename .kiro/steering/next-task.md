---
inclusion: manual
name: "next-task"
description: "Use when user asks to \"find next task\", \"what should I work on\", \"automate workflow\", \"implement and ship\", \"run next-task\". Orchestrates complete task-to-production workflow: discovery, implementation, review, and delivery."
---

# /next-task - Master Workflow Orchestrator

Discover what to work on next and execute the complete implementation workflow.

---

<no-shortcuts-policy>
## No Shortcuts Policy

This workflow exists because each step serves a purpose. Taking shortcuts defeats the purpose of automation.

| Step | Purpose | What Happens If Skipped |
|------|---------|------------------------|
| Worktree creation | Parallel task isolation | Conflicts, lost work |
| Review loop (5 iterations, stall-safe) | Catches bugs humans miss | Bugs ship to production |
| 3-minute CI wait | Auto-reviewers need time | Miss critical feedback |
| Address all PR comments | Quality gate | Merge blocked, trust lost |

### Enforcement Rules

1. Every step is mandatory - not suggestions, not guidelines, requirements
2. Use the specified agents - do not substitute with manual commands
3. Output verification blocks - prove each step completed
4. If you think a step is unnecessary, review the "What Happens If Skipped" column above

### Forbidden Shortcuts

- `git checkout -b` or `git branch` instead of `worktree-manager` agent
- Single CI check instead of monitoring loop
- Rationalizing skips ("it's faster", "not needed this time")
</no-shortcuts-policy>

---

## Workflow Overview

**Phases 1-6 (User Interaction):**
1. Policy Selection
2. Task Discovery
3. Worktree Setup
4. Exploration
5. Planning
6. User Approval

**Phases 7-12 (Autonomous):**
7. Implementation
8. Pre-Review Gates
9. Review Loop
10. Delivery Validation
11. Docs Update
12. `ship`

**Human interaction points (ONLY THESE):**
1. Policy selection via checkboxes
2. Task selection from ranked list
3. Plan approval (EnterPlanMode/ExitPlanMode)

<workflow-gates>
## Workflow Gates

Each phase must complete before the next starts:

| Gate | Requirement |
|------|-------------|
| Implementation | Agent completes all plan steps |
| Pre-Review | deslop-agent + test-coverage-checker (parallel) |
| Review Loop | Must approve (no open issues or override) |
| Delivery | Tests pass, build passes |
| Docs | Documentation updated |
| Ship | Explicit `ship` invocation (plugin command) |

**Forbidden actions for agents:**
- No agent may create PRs or push to remote (only ship)
- No agent may skip Phase 9, delivery-validator, or docs update
</workflow-gates>

## Arguments

Parse from $ARGUMENTS:
- `--status`: Show current workflow state and exit
- `--resume [task/branch/worktree]`: Continue from last checkpoint
- `--abort`: Cancel workflow and cleanup
- `--implement`: Skip to implementation after task selection
- `[filter]`: Task filter (bug, feature, security, test)

### Resume Syntax

```
/next-task --resume                     # Resume active worktree (if only one)
/next-task --resume 123                 # Resume by task ID
/next-task --resume feature/my-task-123 # Resume by branch name
/next-task --resume ../worktrees/my-task-123  # Resume by worktree path
```

## Default Behavior (No Arguments)

1. Goes to Phase 1: Policy Selection
2. Policy selector checks for existing tasks in `{stateDir}/tasks.json`
3. If existing tasks found, **ASKS USER** what to do
4. Then continues with normal policy configuration

The workflow never auto-resumes. It always asks first.

<opencode-constraint>
## OpenCode Label Limit

All AskUserQuestion option labels must be ≤30 characters. Put details in `description`, not `label`.
</opencode-constraint>

## State Management

Uses `lib/state/workflow-state.js` for all state operations:

| File | Location | Purpose |
|------|----------|---------|
| `tasks.json` | Main repo `{stateDir}/` | Active task registry |
| `flow.json` | Worktree `{stateDir}/` | Workflow progress |

Key functions:
- `workflowState.startPhase(phase)` - Begin a phase
- `workflowState.completePhase(result)` - Complete and advance
- `workflowState.updateFlow(updates)` - Partial state updates
- `workflowState.hasActiveTask()` - Check for existing work
- `workflowState.canResume()` - Check if resumable

## Pre-flight: Handle Arguments

```javascript


const pluginRoot = getPluginRoot('next-task');
);
const args = '$ARGUMENTS'.split(' ').filter(Boolean);

// No flags → Phase 1 (Policy Selection asks about existing tasks)
if (args.length === 0) {
  console.log("Starting Phase 1 (Policy Selection)");
}

// Handle --status, --abort, --resume via workflowState functions
if (args.includes('--status')) {
  const summary = workflowState.getFlowSummary();
  console.log(summary ? `Phase: ${summary.phase} | Task: ${summary.task}` : "No active workflow.");
  return;
}

if (args.includes('--abort')) {
  workflowState.abortWorkflow('User requested abort');
  return;
}

if (args.includes('--resume')) {
  // Use lib functions to find worktree and resume from last phase
  const flow = workflowState.readFlow();
  if (flow && workflowState.canResume()) {
    console.log(`Resuming from phase: ${flow.phase}`);
  }
}
```

<phase-1>
## Phase 1: Policy Selection

No agent needed. Use AskUserQuestion tool with ALL 3 questions from `lib/sources/policy-questions.js`.

**MANDATORY - Ask ALL 3 Questions:**

| # | Header | Question | Options |
|---|--------|----------|---------|
| 1 | Source | Where should I look for tasks? | GitHub Issues, GitHub Projects, GitLab Issues, Local tasks.md, Custom, Other (+ cached if exists) |
| 2 | Priority | What type of tasks to prioritize? | All, Bugs, Security, Features |
| 3 | Stop Point | How far should I take this task? | Merged, PR Created, Implemented, Deployed, Production |

**Forbidden Actions:**
- Skipping any of the 3 questions
- Inventing your own questions instead of using the exact ones above
- Proceeding to Phase 2 without all 3 answers

```javascript
// Reference implementation - use ALL questions
);
const { questions, cachedPreference } = sources.getPolicyQuestions();
// questions array contains all 3 questions above
**Please choose:**

Reply in chat with your choice. // Pass all 3 questions

// Handle GitHub Projects follow-up
if (sources.needsProjectFollowUp(responses.source)) {
  const projectQs = sources.getProjectQuestions();
  const projectResponses = await AskUserQuestion(projectQs);
  responses.project = {
    number: projectResponses['Project Number'],
    owner: projectResponses['Project Owner']
  };
}

const policy = sources.parseAndCachePolicy(responses);
workflowState.updateFlow({ policy, phase: 'task-discovery' });
```
</phase-1>

<phase-2>
## Phase 2: Task Discovery

**Agent**: `task-discoverer` (sonnet)

```javascript
workflowState.startPhase('task-discovery');
Delegate to the `task-discoverer` subagent:
> Discover tasks from source: ${JSON.stringify(policy.taskSource)}. Filter: ${policy.priorityFilter}. Present top 5 for selection.
```
</phase-2>

<phase-3>
## Phase 3: Worktree Setup

**Blocking gate** - Cannot proceed to Phase 4 without completing this.

Spawn: `worktree-manager` (haiku)

```javascript
workflowState.startPhase('worktree-setup');

// Required - use this agent, not manual git commands
const worktreeResult = Delegate to the `worktree-manager` subagent:
> Create worktree for task #${state.task.id}. Anchor pwd to worktree.

// Verification - mandatory before proceeding
if (!worktreeResult.worktreePath) {
  throw new Error('[BLOCKED] Worktree creation failed - STOP');
}
console.log(`[VERIFIED] Worktree: ${worktreeResult.worktreePath}`);
```

### Forbidden Actions for Phase 3
- `git checkout -b <branch>` (use worktree-manager agent)
- `git branch <branch>` (use worktree-manager agent)
- Proceeding to Phase 4 without worktree verification output
- Skipping worktree "because branching is faster"
</phase-3>

<phase-4>
## Phase 4: Exploration

**Agent**: `exploration-agent` (opus)

```javascript
workflowState.startPhase('exploration');
Delegate to the `exploration-agent` subagent:
> Deep codebase analysis for task #${state.task.id}. Find key files, patterns, dependencies.
```
</phase-4>

<phase-5>
## Phase 5: Planning

**Agent**: `planning-agent` (opus)

```javascript
workflowState.startPhase('planning');
const planOutput = Delegate to the `planning-agent` subagent:
> Design implementation plan for task #${state.task.id}. Output structured JSON between === PLAN_START === and === PLAN_END === markers.
```
</phase-5>

<phase-6>
## Phase 6: User Approval (Plan Mode)

**Last human interaction point.** Present plan via EnterPlanMode/ExitPlanMode.

```javascript
EnterPlanMode();
// User reviews and approves via ExitPlanMode
workflowState.completePhase({ planApproved: true, plan });
```
</phase-6>

<phase-7>
## Phase 7: Implementation

**Agent**: `implementation-agent` (opus)

```javascript
workflowState.startPhase('implementation');
Delegate to the `implementation-agent` subagent:
> Execute approved plan for task #${state.task.id}. Commit changes incrementally.
// → SubagentStop hook triggers pre-review gates
```
</phase-7>

<phase-8>
## Phase 8: Pre-Review Gates

**Agents** (parallel): `deslop-agent` + `test-coverage-checker` (sonnet)

Delegate to the `deslop-agent` subagent:
> Scan for AI slop patterns.

Delegate to the `test-coverage-checker` subagent:
> Validate test coverage.

Delegate to the `simple-fixer` subagent:
> Apply these slop fixes:
</phase-8>

<phase-9>
## Phase 9: Review Loop

**Blocking gate** - Must run iterations before delivery validation.

```javascript
workflowState.startPhase('review-loop');
```

**CRITICAL**: You MUST spawn multiple parallel reviewer agents. Do NOT use a single generic reviewer.

### Step 1: Get Changed Files

```bash
git diff --name-only main...HEAD
**Review phase (Kiro - max 4 agents, fallback to 2 sequential):**

Try delegating to these subagents (experimental parallel spawning):

Delegate to the `general-purpose` subagent:
> You are a code quality reviewer. Review these files: ${files.join(', ')}

Delegate to the `general-purpose` subagent:
> You are a security reviewer. Review these files: ${files.join(', ')}

Delegate to the `general-purpose` subagent:
> You are a performance reviewer. Review these files: ${files.join(', ')}

Delegate to the `general-purpose` subagent:
> You are a test coverage reviewer. Review these files: ${files.join(', ')}

If parallel spawning is unavailable, run 2 combined reviewers sequentially:
1. Delegate to the `reviewer-quality-security` subagent (code quality + security)
2. Then delegate to the `reviewer-perf-test` subagent (performance + test coverage)

Aggregate all findings from whichever execution path succeeded.

### Step 4: Aggregate Findings

Combine all reviewer findings, deduplicate by file+line+description, group by severity.

### Step 5: Fix Issues (severity order: critical -> high -> medium -> low)

For each finding, use Edit tool to apply the suggested fix. Commit after each batch.

### Step 6: Iterate Until Clean (max 5 iterations)

Repeat steps 3-5 until:
- `openCount === 0` (all issues resolved) -> approved
- Same findings hash for 2 consecutive iterations (stall detected) -> blocked
- 5 iterations reached (hard limit) -> blocked

### Review Iteration Rules
- MUST run at least 1 full iteration with ALL 4 core reviewers
- Do NOT use a single generic reviewer - spawn all specialists in parallel
- MUST continue while `openCount > 0`. Only stop on: openCount===0, stall detection, or 5-iteration hard limit
- Do not skip directly to delivery validation
- Do not claim "review passed" without spawning the reviewer agents

### Verification Output (MANDATORY)

After review loop completes, output:
```
[VERIFIED] Review Loop Complete
- Iterations: N
- Core reviewers spawned: code-quality, security, performance, test-coverage
- Conditional specialists: [list any that were added]
- Findings resolved: X critical, Y high, Z medium
- Status: approved | blocked
```

Then advance the workflow state:
```javascript
workflowState.completePhase({ approved, iterations, remaining });
```
</phase-9>

<phase-10>
## Phase 10: Delivery Validation

**Agent**: `delivery-validator` (sonnet)

```javascript
workflowState.startPhase('delivery-validation');
const result = Delegate to the `delivery-validator` subagent:
> Validate completion. Check: tests pass, build passes, requirements met.
if (!result.approved) {
  workflowState.failPhase(result.reason, { fixInstructions: result.fixInstructions });
  return; // Retries from implementation
}
```
</phase-10>

<phase-11>
## Phase 11: Docs Update

**Agent**: `sync-docs-agent` (sonnet)

Uses the unified sync-docs agent from the sync-docs plugin with `before-pr` scope.

```javascript
workflowState.startPhase('docs-update');

// Helper to parse sync-docs structured output
function parseSyncDocsResult(output) {
  const match = output.match(/=== SYNC_DOCS_RESULT ===[\s\S]*?({[\s\S]*?})[\s\S]*?=== END_RESULT ===/);
  return match ? JSON.parse(match[1]) : { issues: [], fixes: [], changelog: { status: 'ok' } };
}

// Run sync-docs with before-pr scope
const syncResult = Delegate to the `sync-docs-agent` subagent:
> Sync documentation with code state.

// Parse results from === SYNC_DOCS_RESULT === markers
const result = parseSyncDocsResult(syncResult);

// If fixes are needed, spawn simple-fixer
if (result.fixes && result.fixes.length > 0) {
  Delegate to the `simple-fixer` subagent:
> Apply these documentation fixes:
}

workflowState.completePhase({ docsUpdated: true, fixesApplied: result.fixes?.length || 0 });
```
</phase-11>

<phase-12>
## Phase 12: Handoff to ship

After docs update (sync-docs-agent) completes, invoke `ship` explicitly:

```javascript
workflowState.startPhase('shipping');
console.log(`Task #${state.task.id} passed all validation. Invoking ship...`);
const stateDir = workflowState.getStateDir(); // Returns platform-aware state directory
await Skill({ name: "ship", args: `--state-file "${stateDir}/flow.json"` });
```

**ship responsibilities:**
- Create PR, push branch
- Monitor CI and review comments
- Merge when approved
- Cleanup worktree and tasks.json
</phase-12>

## Error Handling

```javascript
try {
  // ... workflow phases ...
} catch (error) {
  workflowState.failPhase(error.message);
  console.log(`Workflow failed. Use --resume to retry or --abort to cancel.`);
}
```

## Success Criteria

- Policy selection via checkboxes
- Two-file state management (tasks.json + flow.json)
- Resume by task ID, branch, or worktree path
- Worktree isolation for parallel workflows
- Opus for complex tasks (explore, plan, implement)
- Sonnet for validation tasks (review, delivery)
- Haiku for simple tasks (worktree)
- Fully autonomous after plan approval
- Explicit ship handoff for PR workflow

Begin workflow now.
