---
inclusion: manual
name: "learn"
description: "Use when user asks to \"learn about topic\", \"research subject\", \"create learning guide\", \"build knowledge base\", \"study topic\". Gathers online sources and synthesizes comprehensive guide with RAG index."
---

# /learn - Learning Guide Generator

Research any topic by gathering online resources and synthesize into a comprehensive learning guide with RAG-optimized indexes.

## Depth Levels

| Level | Sources | Use Case |
|-------|---------|----------|
| `brief` | 10 | Quick overview, time-sensitive |
| `medium` | 20 | **Default** - balanced coverage |
| `deep` | 40 | Comprehensive, academic depth |

## Arguments

Parse from $ARGUMENTS:

- **topic**: The subject to learn about (required)
- **--depth**: `brief` (10 sources), `medium` (20, default), or `deep` (40)
- **--no-enhance**: Skip enhancement pass (default: enhance enabled)

## Execution

### Phase 1: Parse Arguments

```javascript
const args = '$ARGUMENTS';

// Extract depth flag
const depthMatch = args.match(/--depth=(brief|medium|deep)/);
const depth = depthMatch ? depthMatch[1] : 'medium';
const noEnhance = args.includes('--no-enhance');

// Extract topic (everything except flags)
const topic = args
  .replace(/--depth=(brief|medium|deep)/g, '')
  .replace(/--no-enhance/g, '')
  .trim();

if (!topic) {
  return 'Usage: /learn <topic> [--depth=brief|medium|deep]';
}

// Generate slug for filenames
const slug = topic
  .toLowerCase()
  .replace(/[^a-z0-9\s-]/g, '')
  .replace(/\s+/g, '-')
  .replace(/-+/g, '-')
  .replace(/^-|-$/g, '')
  .substring(0, 64);

// Source counts by depth
const sourceCounts = { brief: 10, medium: 20, deep: 40 };
const minSources = sourceCounts[depth];
```

### Phase 2: Check Existing Guide

```javascript
// Check if guide already exists
const existingGuide = await Glob({ pattern: `agent-knowledge/${slug}.md` });

if (existingGuide.length > 0) {
  // Ask user: update existing or create fresh?
  const choice = **A guide for **

1. **Update existing** - Add new sources and refresh content
2. **Create fresh** - Start over with new research

Reply with the number or name of your choice.

  if (choice === 'Create fresh') {
    // Will overwrite
  }
}
```

### Phase 3: Spawn Learn Agent

```javascript
const taskOutput = Delegate to the `learn-agent` subagent:
> Research and create a learning guide.
```

### Phase 4: Parse Results

```javascript
function parseLearnResult(output) {
  const match = output.match(/=== LEARN_RESULT ===[\s\S]*?({[\s\S]*?})[\s\S]*?=== END_RESULT ===/);
  return match ? JSON.parse(match[1]) : null;
}

const result = parseLearnResult(taskOutput);
```

### Phase 5: Present Results

```markdown
## Learning Guide Created

**Topic**: {topic}
**File**: agent-knowledge/{slug}.md
**Sources**: {sourceCount} resources analyzed

### Quality Assessment

| Metric | Rating |
|--------|--------|
| Coverage | {coverage}/10 |
| Source Diversity | {diversity}/10 |
| Example Quality | {examples}/10 |
| Confidence | {confidence}/10 |

### Source Breakdown

| Type | Count |
|------|-------|
| Official Docs | {n} |
| Tutorials | {n} |
| Q&A/Stack Overflow | {n} |
| Blog Posts | {n} |
| GitHub Examples | {n} |

### Next Steps

- [ ] Review the guide at `agent-knowledge/{slug}.md`
- [ ] Check source quality in `agent-knowledge/resources/{slug}-sources.json`
- [ ] Run `/learn {related-topic}` to expand your knowledge base
```

## Output Structure

Each `/learn` run creates/updates:

```
agent-knowledge/
  CLAUDE.md           # Master index (updated)
  AGENTS.md           # Master index for OpenCode/Codex (updated)
  {slug}.md           # Topic-specific guide (created)
  resources/
    {slug}-sources.json  # Source metadata (created)
```

## Error Handling

| Error | Action |
|-------|--------|
| No topic provided | Show usage help |
| WebSearch fails | Retry with alternative queries |
| Insufficient sources | Warn user, proceed with available |
| Enhancement fails | Skip enhancement, note in output |

## Example Usage

```bash
/learn recursion
/learn react hooks --depth=deep
/learn "kubernetes networking" --depth=brief
/learn python async --no-enhance
```