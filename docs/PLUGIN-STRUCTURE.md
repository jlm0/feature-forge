# Plugin Structure

## Overview

Claude Code plugins extend functionality through:

- **Commands** — User-invokable entry points (`/feature-forge`)
- **Skills** — Methodologies that frame how agents think
- **Agents** — Specialized actors with isolated context windows
- **Hooks** — Event handlers (PreToolUse, PostToolUse, Stop, etc.)

## Directory Structure

```
feature-forge/
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata (required)
│
├── commands/
│   └── feature-forge.md         # Main orchestrator command
│
├── skills/                      # Methodologies for agents
│   └── skill-name/
│       ├── SKILL.md             # Core instructions (required)
│       ├── scripts/             # Executable code (token-free)
│       ├── references/          # Loaded into context on demand
│       └── assets/              # Used in output (not loaded)
│
├── agents/                      # Specialized actors
│   └── agent-name.md            # Agent system prompt with pre-loaded skills
│
├── hooks/                       # Event handlers
│   ├── hooks.json               # Hook configuration
│   └── ralph-stop-hook.sh       # Implementation/remediation loops
│
└── README.md
```

## Progressive Disclosure

Plugins use three-level loading to manage context:

| Level            | Content             | When Loaded    | Token Cost   |
| ---------------- | ------------------- | -------------- | ------------ |
| **1. Metadata**  | name + description  | Always         | ~100 words   |
| **2. Body**      | SKILL.md or command | When triggered | <5,000 words |
| **3. Resources** | scripts, references | As needed      | Varies       |

**Key insight:** Scripts execute without loading into context — they're token-free.

## Skills (16 Total)

Skills are **methodologies** that frame how agents think. They are pre-loaded into agents at spawn time.

### Skill = How (Methodology)

| Skill                       | Purpose                              | Methodology                                     |
| --------------------------- | ------------------------------------ | ----------------------------------------------- |
| **code-exploration**        | Trace code, map architecture         | Entry points → call chains → dependencies       |
| **docs-research**           | Read and digest external docs        | Identify sources → extract patterns → synthesize |
| **deep-context**            | Ultra-granular code analysis         | Line-by-line, First Principles, 5 Whys          |
| **threat-model**            | Security threat enumeration          | STRIDE, actor mapping, trust boundaries         |
| **footgun-detection**       | API misuse and dangerous defaults    | Adversary modeling, edge case probing           |
| **variant-hunt**            | Find similar issues                  | Start specific → generalize → stop at 50% FP    |
| **fix-verify**              | Verify fixes address root cause      | Differential analysis, regression detection     |
| **ui-ux-design**            | Visual design and UX                 | User flows, interaction patterns, accessibility |
| **frontend-engineering**    | Frontend technical implementation    | State management, components, data fetching     |
| **api-design**              | API contract design                  | REST/GraphQL conventions, versioning            |
| **data-modeling**           | Database and schema design           | Relationships, normalization, migrations        |
| **architecture-synthesis**  | System design from multiple inputs   | Trade-off analysis, blueprint creation          |
| **implementation-discipline** | Writing production code            | Clean code, conventions, incremental progress   |
| **testing-methodology**     | How to verify correctness            | Test selection, coverage, edge cases            |
| **code-review**             | Evaluate code quality                | Bug patterns, convention adherence              |
| **triage**                  | Prioritization decisions             | Impact, urgency, risk assessment                |

### SKILL.md Structure

```yaml
---
name: skill-name                    # Required: lowercase, hyphens, ≤64 chars
description: "What methodology this teaches AND when to use it"  # Required
---

# Skill Title

## Quick Start
[Brief example showing the methodology in action]

## Methodology

### Step 1: [Action]
[How to think about this step]

### Step 2: [Action]
[How to think about this step]

## Decision Trees
[Conditional logic for different scenarios]

## References
[Links to reference files for detailed information]
```

### Skill Best Practices

**DO:**

- Use imperative form ("Trace code paths", "Identify entry points")
- Focus on **how to think**, not just what to do
- Provide concrete examples showing the methodology
- Include decision trees for branching logic
- Keep skills reusable across different contexts

**DON'T:**

- Make skills too specific to one phase
- Duplicate methodology across multiple skills
- Exceed ~500 lines (use references for more)
- Include "When to Use" in body (already in description)

## Agents (10 Total)

Agents are **domain-specific actors** with isolated context windows. They are like a real development team.

### Agent = Who (Role)

| Agent                | Role                          | Pre-loaded Skills                                                         | Tools                                 |
| -------------------- | ----------------------------- | ------------------------------------------------------------------------- | ------------------------------------- |
| **context-builder**  | Explore codebase and docs     | code-exploration, docs-research                                           | Read, Grep, Glob, WebSearch, WebFetch |
| **security-analyst** | Security analysis             | deep-context, threat-model, footgun-detection, variant-hunt, fix-verify   | Read, Grep, Glob                      |
| **ui-ux-designer**   | Visual and interaction design | ui-ux-design                                                              | Read, Grep, Glob, WebFetch            |
| **frontend-engineer**| Frontend technical design     | frontend-engineering                                                      | Read, Grep, Glob                      |
| **api-designer**     | API contract design           | api-design                                                                | Read, Grep, Glob                      |
| **data-modeler**     | Database schema design        | data-modeling                                                             | Read, Grep, Glob                      |
| **architect**        | Synthesize into blueprint     | architecture-synthesis, triage                                            | Read, Grep, Glob                      |
| **implementer**      | Write production code         | implementation-discipline, testing-methodology                            | Read, Write, Edit, Bash, Grep, Glob   |
| **reviewer**         | Evaluate implementation       | code-review, deep-context                                                 | Read, Grep, Glob, Bash                |
| **remediator**       | Fix identified issues         | implementation-discipline, testing-methodology, fix-verify                | Read, Write, Edit, Bash, Grep, Glob   |

### Agent Structure

```yaml
---
name: agent-name                   # Required: kebab-case
description: "MUST BE USED for..." # Required: triggers auto-routing
tools: Read, Grep, Glob            # Required: restricts available tools
model: sonnet                      # Optional: sonnet, opus, haiku
color: blue                        # Optional: UI indicator
---

You are a [role] agent with expertise in [domain].

## Pre-loaded Skills

You think using these methodologies:
- **[skill-1]**: [brief description of how it frames your thinking]
- **[skill-2]**: [brief description of how it frames your thinking]

## Context Discovery

When invoked, first read:
- .claude/feature-forge/state.json (current phase)
- [Relevant prior phase outputs]
- [Necessary context files]

## Process

1. [Step one using your skills]
2. [Step two using your skills]
3. ...

## Output Format

[Define expected output structure]

## Completion

[What to do when finished, what files to update]
```

### Agent Tool Categories

| Agent Type           | Tools                                 | Purpose                    |
| -------------------- | ------------------------------------- | -------------------------- |
| Read-only (analysts) | Read, Grep, Glob                      | Examine without changing   |
| Research (builders)  | Read, Grep, Glob, WebSearch, WebFetch | Explore code and docs      |
| Writers (coders)     | Read, Write, Edit, Bash, Grep, Glob   | Implement changes          |

### Agent Best Practices

**DO:**

- Use "MUST BE USED for..." in description for auto-routing
- Pre-load relevant skills in the agent definition
- Include context discovery steps (agents start fresh)
- Define clear output format and file locations
- Specify completion behavior (what to update)

**DON'T:**

- Create too many agents (routing confusion)
- Omit skill loading (agents need framing)
- Use vague descriptions (won't trigger correctly)
- Let agents spawn sub-agents (1-level max)

## Commands

Commands are user-invokable entry points that orchestrate the workflow.

### Command Structure

```yaml
---
description: "Clear description of what this command does AND when to use it"
argument-hint: "Optional hint for arguments"
allowed-tools: ["Tool1", "Tool2"]          # Optional: restrict tools
---

# Command Title

Instructions that guide Claude's behavior when the command is invoked.

## Workflow Steps

1. First step
2. Second step
3. ...
```

### Orchestrator Command

The main `/feature-forge` command orchestrates the entire workflow:

```yaml
---
description: "Secure feature development with context building, security analysis, and human checkpoints"
argument-hint: "Feature description or 'resume'"
---

# Feature-Forge Orchestrator

## Initialization
1. Check for existing state.json
2. If resuming: read progress, continue from checkpoint
3. If new: create workspace, start UNDERSTANDING group

## Phase Execution

### UNDERSTANDING Group
1. Spawn context-builder for Discovery
2. Spawn parallel context-builders for Exploration (code + docs)
3. Spawn security-analyst for Security Context

### CLARIFICATION Group
1. Present questions to human
2. Update discovery.md with answers

### DESIGN Group (2 iterations max)
1. Spawn parallel specialists: ui-ux-designer, frontend-engineer, api-designer, data-modeler
2. Spawn architect to synthesize
3. Spawn security-analyst for hardening review
4. Present to human for approval [CHECKPOINT]

### EXECUTION Group
1. Spawn implementer in Ralph loop
2. Spawn parallel reviewers (quality + security)
3. If issues: spawn remediator in Ralph loop (2 max)
4. Spawn context-builder for summary
```

## Hooks

Hooks respond to events during Claude Code execution.

### Hook Events

| Event            | When Fired                 | Use Case              |
| ---------------- | -------------------------- | --------------------- |
| **PreToolUse**   | Before a tool executes     | Validation, blocking  |
| **PostToolUse**  | After a tool executes      | Logging, side effects |
| **Stop**         | When session tries to exit | Ralph loops, cleanup  |
| **SubagentStop** | When subagent completes    | Result processing     |
| **SessionStart** | Session begins             | Initialization        |
| **Notification** | Notifications sent         | Alerts, logging       |

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

## Complete Plugin Structure

```
feature-forge/
├── .claude-plugin/
│   └── plugin.json
│
├── commands/
│   └── feature-forge.md           # Main orchestrator
│
├── agents/
│   ├── context-builder.md         # code-exploration, docs-research
│   ├── security-analyst.md        # deep-context, threat-model, footgun-detection, variant-hunt, fix-verify
│   ├── ui-ux-designer.md          # ui-ux-design
│   ├── frontend-engineer.md       # frontend-engineering
│   ├── api-designer.md            # api-design
│   ├── data-modeler.md            # data-modeling
│   ├── architect.md               # architecture-synthesis, triage
│   ├── implementer.md             # implementation-discipline, testing-methodology
│   ├── reviewer.md                # code-review, deep-context
│   └── remediator.md              # implementation-discipline, testing-methodology, fix-verify
│
├── skills/
│   ├── code-exploration/SKILL.md
│   ├── docs-research/SKILL.md
│   ├── deep-context/SKILL.md
│   ├── threat-model/SKILL.md
│   ├── footgun-detection/SKILL.md
│   ├── variant-hunt/SKILL.md
│   ├── fix-verify/SKILL.md
│   ├── ui-ux-design/SKILL.md
│   ├── frontend-engineering/SKILL.md
│   ├── api-design/SKILL.md
│   ├── data-modeling/SKILL.md
│   ├── architecture-synthesis/SKILL.md
│   ├── implementation-discipline/SKILL.md
│   ├── testing-methodology/SKILL.md
│   ├── code-review/SKILL.md
│   └── triage/SKILL.md
│
├── scripts/
│   ├── init-workspace.sh          # Creates .claude/feature-forge/
│   ├── state-manager.py           # JSON state operations
│   └── progress-tracker.py        # Session handoffs
│
├── hooks/
│   ├── hooks.json
│   └── ralph-stop-hook.sh         # For implementation/remediation loops
│
└── README.md
```

## Key Distinctions

| Concept   | Answers | Example                                       |
| --------- | ------- | --------------------------------------------- |
| **Agent** | Who?    | "The security analyst examines the code"      |
| **Skill** | How?    | "Using threat modeling methodology (STRIDE)"  |
| **Phase** | When?   | "During the Design group"                     |
| **Tool**  | With?   | "Using Read, Grep, Glob to explore"           |

## Token Budget

| Component           | Tokens     | Notes             |
| ------------------- | ---------- | ----------------- |
| Plugin metadata     | ~500       | Always loaded     |
| Command body        | ~1,000     | On invocation     |
| Active agent        | ~800       | One at a time     |
| Pre-loaded skills   | ~2,000     | Per agent         |
| Context files       | ~3,000     | Varies            |
| **Scripts**         | **0**      | Token-free        |
| **Total per phase** | **~7,000** | Well under limits |

## Anti-Patterns

| Anti-Pattern             | Problem               | Solution                        |
| ------------------------ | --------------------- | ------------------------------- |
| Skill-less agents        | No methodology        | Every agent needs skills        |
| Nested agent spawning    | Context explosion     | 1-level max nesting             |
| Verbose explanations     | Wastes context        | Concise methodology examples    |
| Too many agents          | Routing confusion     | 10 domain-specific actors       |
| Vague descriptions       | Won't auto-trigger    | "MUST BE USED for..."           |
| No context discovery     | Agents start fresh    | Include file reading steps      |
