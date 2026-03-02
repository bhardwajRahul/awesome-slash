---
inclusion: manual
name: "repo-map"
description: "Use when user asks to \"create repo map\", \"generate repo map\", \"update repo map\", \"repo map status\", \"map symbols\". Builds and updates AST-based repo map using ast-grep."
---

# /repo-map - AST Repo Map

Generate a cached repository map of symbols and imports using ast-grep. This enables faster drift detection and more accurate code context.

## Arguments

Parse from `$ARGUMENTS`:

- **Action**: `init` | `update` | `status` | `rebuild` (default: `status`)
- `--force`: Force rebuild (for `init`)
- `--full`: Force full rebuild (for `update`)

Examples:

- `/repo-map init`
- `/repo-map update --full`
- `/repo-map status`

## Execution

### 1) Load Repo Map Module

```javascript

const pluginRoot = getPluginRoot('repo-map');
if (!pluginRoot) { console.error('Error: Could not locate repo-map plugin root'); process.exit(1); }

```

### 2) Parse Arguments

```javascript
const args = '$ARGUMENTS'.split(' ').filter(Boolean);
const action = (args[0] || 'status').toLowerCase();

const options = {
  force: args.includes('--force'),
  full: args.includes('--full')
};
```

### 3) Ensure ast-grep is Available

```javascript
const installed = await repoMap.checkAstGrepInstalled();
if (!installed.found || !repoMap.installer.meetsMinimumVersion(installed.version)) {
  const suggestion = repoMap.getInstallInstructions();
  const choice = **ast-grep is required for repo-map. Install now?**

1. **Install via npm** - Runs: npm install -g @ast-grep/cli
2. **Skip for now** - Show install instructions and exit

Reply with the number or name of your choice.

  if (choice?.[0] === 'Install via npm') {
    await Bash('npm install -g @ast-grep/cli');
  } else {
    console.log(suggestion);
    return;
  }
}
```

### 4) Run Action

```javascript
let result;

if (action === 'init' || action === 'rebuild') {
  result = await repoMap.init(process.cwd(), {
    force: action === 'rebuild' || options.force
  });
} else if (action === 'update') {
  result = await repoMap.update(process.cwd(), { full: options.full });
} else if (action === 'status') {
  result = repoMap.status(process.cwd());
} else {
  console.log('Unknown action. Use: init | update | status | rebuild');
  return;
}

if (result?.success === false) {
  console.log(result.error || 'Repo-map failed');
  if (result.installSuggestion) console.log(result.installSuggestion);
  return;
}

if (action === 'status' && !result.exists) {
  console.log('No repo-map found. Run /repo-map init to generate one.');
  return;
}
```

### 5) Validate Results (init/update only)

After `init` or `update`, run validation using the lightweight agent:

```javascript
if (action === 'init' || action === 'rebuild' || action === 'update') {
  const summary = result?.map?.stats || result?.summary || result?.changes || {};
  const validation = Delegate to the `map-validator` subagent:
> Validate repo-map results. Summary: ${JSON.stringify(summary)}
  console.log(validation);
}
```

## Output Format

```markdown
## Repo Map Result

**Action**: init|update|status
**Files**: <count>
**Symbols**: <count>
**Languages**: <list>
**Commit**: <hash>

### Notes
- <warnings or validation results>
```
