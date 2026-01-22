# Plugin Structure

## Overview

Claude Code plugins extend functionality through:

- **Commands** — User-invokable entry points (`/feature-forge`)
- **Skills** — Domain expertise loaded into main context
- **Agents** — Subagents with isolated context windows
- **Hooks** — Event handlers (PreToolUse, PostToolUse, Stop, etc.)

## Directory Structure

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata (required)
│
├── commands/                    # User-invokable commands
│   └── command-name.md          # /command-name entry point
│
├── skills/                      # Domain expertise packages
│   └── skill-name/
│       ├── SKILL.md             # Core instructions (required)
│       ├── scripts/             # Executable code (token-free)
│       ├── references/          # Loaded into context on demand
│       └── assets/              # Used in output (not loaded)
│
├── agents/                      # Subagent definitions
│   └── agent-name.md            # Agent system prompt
│
├── hooks/                       # Event handlers
│   ├── hooks.json               # Hook configuration
│   └── hook-script.sh           # Hook implementation
│
└── README.md
```

## Progressive Disclosure

Plugins use three-level loading to manage context:

| Level | Content | When Loaded | Token Cost |
|-------|---------|-------------|------------|
| **1. Metadata** | name + description | Always | ~100 words |
| **2. Body** | SKILL.md or command | When triggered | <5,000 words |
| **3. Resources** | scripts, references | As needed | Varies |

**Key insight:** Scripts execute without loading into context — they're token-free.

## Plugin Metadata

**plugin.json:**
```json
{
  "name": "feature-forge",
  "version": "1.0.0",
  "description": "Secure, human-stewarded feature development workflow",
  "author": {
    "name": "Author Name",
    "email": "author@example.com"
  }
}
```

## Commands

Commands are user-invokable entry points. They orchestrate workflows.

### Command Structure

```yaml
---
description: "Clear description of what this command does AND when to use it"
argument-hint: "Optional hint for arguments"
allowed-tools: ["Tool1", "Tool2"]          # Optional: restrict tools
hide-from-slash-command-tool: "true"        # Optional: hide from /skill list
---

# Command Title

Instructions that guide Claude's behavior when the command is invoked.

## Workflow Steps

1. First step
2. Second step
3. ...
```

### Command Best Practices

- **Description is critical** — It determines when/how the command appears
- **Include workflow phases** — Clear steps for Claude to follow
- **Reference agents** — Tell Claude which agents to spawn for which phases
- **Define checkpoints** — Where to pause for human input
- **Use $ARGUMENTS** — Access user-provided arguments

### Example: Orchestrator Command

```yaml
---
description: "Secure feature development with security analysis and human checkpoints"
argument-hint: "Feature description or 'resume'"
---

# Feature-Forge

## Initialization
1. Check for existing state.json
2. If resuming: read progress, continue from checkpoint
3. If new: create workspace, start Discovery phase

## Phase Execution
For each phase:
1. Update state.json to in_progress
2. Launch appropriate agent
3. Agent writes outputs to files
4. Check if human checkpoint needed
5. Update state.json to complete

## Agents
- Discovery, Exploration, Clarification: context-builder agent
- Audit, Threat, Triage: security-analyst agent
- Architecture, Hardening: architect agent
- Implementation: implementer agent (Ralph-compatible)
- Review: reviewer agent
- Remediation: remediator agent (Ralph-compatible)
```

## Skills

Skills package domain-specific knowledge and workflows.

### SKILL.md Structure

```yaml
---
name: skill-name                    # Required: lowercase, hyphens, ≤64 chars
description: "What it does AND when to use it"  # Required: ≤1024 chars
---

# Skill Title

## Quick Start
[Brief example or entry point]

## Workflow
[Step-by-step instructions]

## Decision Trees
[Conditional logic for different scenarios]

## References
[Links to reference files for detailed information]
```

### Skill Best Practices

**DO:**
- Use imperative form ("Extract text", "Validate output")
- Provide concrete examples over verbose explanations
- Include code samples for technical skills
- Add decision trees for complex workflows
- Reference bundled files with clear guidance

**DON'T:**
- Include "When to Use" in body (already in description)
- Duplicate info between SKILL.md and references
- Exceed ~500 lines (use references for more)
- Add unnecessary files (README, CHANGELOG)

### Scripts Directory

Scripts execute without loading into context — they're token-free.

**When to include:**
- Code that would be repeatedly rewritten
- Operations requiring deterministic reliability
- State management, JSON manipulation

**Example:**
```python
#!/usr/bin/env python3
"""
state-manager.py - Manage Feature-Forge workflow state

Usage:
    python state-manager.py get <key>
    python state-manager.py set <key> <value>
    python state-manager.py transition <phase> <status>
"""
```

### References Directory

Detailed documentation loaded into context when needed.

**When to include:**
- Detailed phase instructions
- API specifications, schemas
- Domain knowledge too large for SKILL.md

**Best practices:**
- Keep info in ONE place (SKILL.md OR references, not both)
- Include table of contents for files >100 lines
- Avoid deep nesting — link directly from SKILL.md
- Use clear filenames indicating content

## Agents (Subagents)

Agents are specialized mini-agents with:
- **Own system prompt** — Custom instructions
- **Isolated context window** — Prevents context pollution
- **Configurable tools** — Restricted or expanded access

### Agent Structure

```yaml
---
name: agent-name                   # Required: kebab-case
description: "MUST BE USED for..."  # Required: triggers auto-routing
tools: Read, Grep, Glob            # Optional: restricts tools
model: sonnet                      # Optional: sonnet, opus, haiku
color: blue                        # Optional: UI indicator
---

You are a specialized agent for [purpose].

## Context Discovery
When invoked, first read:
- Relevant state files
- Prior phase outputs
- Necessary context

## Process
1. Step one
2. Step two
3. ...

## Output Format
[Define expected output structure]

## Completion
[What to do when finished]
```

### Agent Tool Categories

| Agent Type | Recommended Tools |
|------------|-------------------|
| Read-only (reviewers) | Read, Grep, Glob |
| Research (analysts) | Read, Grep, Glob, WebFetch, WebSearch |
| Writers (developers) | Read, Write, Edit, Bash, Glob, Grep |
| Full access | Omit tools field (inherits parent) |

### Agent Best Practices

**DO:**
- Use "MUST BE USED for..." in description for auto-routing
- Include context discovery steps (agents start fresh)
- Define clear output format
- Specify completion behavior

**DON'T:**
- Create too many agents (routing confusion)
- Omit context gathering (agents don't inherit conversation)
- Use vague descriptions (won't trigger correctly)

## Hooks

Hooks respond to events during Claude Code execution.

### Hook Events

| Event | When Fired | Use Case |
|-------|------------|----------|
| **PreToolUse** | Before a tool executes | Validation, blocking |
| **PostToolUse** | After a tool executes | Logging, side effects |
| **Stop** | When session tries to exit | Ralph loops, cleanup |
| **SubagentStop** | When subagent completes | Result processing |
| **SessionStart** | Session begins | Initialization |
| **Notification** | Notifications sent | Alerts, logging |

### hooks.json Structure

```json
{
  "description": "Hook description",
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/stop-hook.sh"
          }
        ]
      }
    ]
  }
}
```

### Stop Hook for Ralph Loops

The Stop hook intercepts session exit to implement iterative loops:

```bash
#!/bin/bash
# Read state file
# Check completion criteria
# If not complete:
#   - Increment iteration
#   - Output JSON to block exit and feed prompt back
# If complete:
#   - Allow exit
```

**Output format to block and continue:**
```json
{
  "decision": "block",
  "reason": "The prompt to feed back",
  "systemMessage": "Iteration 5 | To complete: <promise>DONE</promise>"
}
```

## Feature-Forge Plugin Structure

```
feature-forge/
├── .claude-plugin/
│   └── plugin.json
│
├── commands/
│   └── feature-forge.md           # Main orchestrator
│
├── agents/
│   ├── context-builder.md         # Discovery, Exploration, Clarification
│   ├── security-analyst.md        # Audit, Threat, Triage
│   ├── architect.md               # Architecture, Hardening
│   ├── implementer.md             # Implementation (Ralph-compatible)
│   ├── reviewer.md                # Review
│   └── remediator.md              # Remediation (Ralph-compatible)
│
├── skills/
│   ├── audit-context/SKILL.md     # Wraps ToB audit-context-building
│   ├── threat-model/SKILL.md      # STRIDE methodology
│   ├── sharp-edges/SKILL.md       # Wraps ToB sharp-edges
│   ├── variant-hunt/SKILL.md      # Wraps ToB variant-analysis
│   └── fix-verify/SKILL.md        # Wraps ToB fix-review
│
├── scripts/
│   ├── init-workspace.sh          # Creates .claude/feature-forge/
│   ├── state-manager.py           # JSON state operations
│   ├── progress-tracker.py        # Session handoffs
│   └── archive-session.py         # Archive old progress
│
├── references/
│   ├── phase-discovery.md
│   ├── phase-exploration.md
│   ├── phase-audit.md
│   └── ...
│
├── hooks/
│   ├── hooks.json
│   └── ralph-stop-hook.sh         # For implementation/remediation loops
│
└── README.md
```

## Token Budget

| Component | Tokens | Notes |
|-----------|--------|-------|
| Plugin metadata | ~500 | Always loaded |
| Command body | ~1,000 | On invocation |
| Active agent | ~800 | One at a time |
| Phase reference | ~2,000 | On demand |
| Context files | ~3,000 | Varies |
| **Scripts** | **0** | Token-free |
| **Total per phase** | **~7,000** | Well under limits |

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Verbose explanations | Wastes context | Concise examples |
| "When to Use" in body | Already triggered | Put in description |
| Deeply nested references | Hard to navigate | One level deep |
| Too many agents | Routing confusion | Consolidate by phase-group |
| Vague descriptions | Won't auto-trigger | "MUST BE USED for..." |
| No context discovery | Agents start fresh | Include file reading steps |
