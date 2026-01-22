# Feature-Forge Architecture

## Workflow Overview

Feature-Forge operates in three distinct modes:

1. **Linear Context Building** — Phases execute sequentially, each building on prior outputs
2. **Iterative Loops** — Ralph-style loops for implementation and remediation
3. **Human Checkpoints** — Explicit pause points for approval and feedback

## Phase Definitions

### Context Building Phases

| Phase | Purpose | Inputs | Outputs |
|-------|---------|--------|---------|
| **Discovery** | Understand what needs to be built | User request | `discovery.md` |
| **Exploration** | Map codebase patterns and architecture | Discovery + codebase | `exploration.md` |
| **Audit** | Build security context (trust boundaries, attack surfaces) | Exploration | `audit-context.md` |
| **Threat** | Model threats using STRIDE methodology | Audit context | `threat-model.md` |
| **Triage** | Prioritize security requirements for v1 | Threat model | `triage.json` |
| **Clarification** | Resolve ambiguities with human input | All prior context | Updated discovery |
| **Architecture** | Design implementation approach | All prior context | `architecture.md` |
| **Hardening** | Review design for security footguns | Architecture + audit | `hardening-review.md` |

### Execution Phases

| Phase | Purpose | Mode | Inputs | Outputs |
|-------|---------|------|--------|---------|
| **Implementation** | Build the feature | Ralph loop | Architecture + feature-list.json | Code + commits |
| **Review** | Quality and security review | Agent + human | Implementation | `findings.json` |
| **Remediation** | Fix identified issues | Ralph loop | findings.json | Fixed code + commits |
| **Summary** | Document and handoff | Linear | All outputs | `summary.md` |

## Phase Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FEATURE-FORGE WORKFLOW                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ╔═══════════════════════════════════════════════════════════════════════╗  │
│  ║                    CONTEXT BUILDING (Linear)                          ║  │
│  ╠═══════════════════════════════════════════════════════════════════════╣  │
│  ║                                                                       ║  │
│  ║  DISCOVERY ──► EXPLORATION ──► AUDIT ──► THREAT ──► TRIAGE           ║  │
│  ║      │             │            │          │           │              ║  │
│  ║      ▼             ▼            ▼          ▼           ▼              ║  │
│  ║    .md           .md          .md        .md        .json             ║  │
│  ║                                                        │              ║  │
│  ║                                              [HUMAN CHECKPOINT]       ║  │
│  ║                                                        │              ║  │
│  ║  CLARIFICATION ◄───────────────────────────────────────┘              ║  │
│  ║      │                                                                ║  │
│  ║      │ [HUMAN CHECKPOINT]                                             ║  │
│  ║      ▼                                                                ║  │
│  ║  ARCHITECTURE ──► HARDENING                                           ║  │
│  ║      │                │                                               ║  │
│  ║      ▼                ▼                                               ║  │
│  ║    .md              .md                                               ║  │
│  ║      │                │                                               ║  │
│  ║      └──────┬─────────┘                                               ║  │
│  ║             │                                                         ║  │
│  ║   [HUMAN CHECKPOINT: Approve design]                                  ║  │
│  ║                                                                       ║  │
│  ╚═══════════════════════════════════════════════════════════════════════╝  │
│                              │                                              │
│                              ▼                                              │
│  ╔═══════════════════════════════════════════════════════════════════════╗  │
│  ║                    IMPLEMENTATION (Ralph Loop)                        ║  │
│  ╠═══════════════════════════════════════════════════════════════════════╣  │
│  ║                                                                       ║  │
│  ║  Read feature-list.json                                               ║  │
│  ║      │                                                                ║  │
│  ║      ▼                                                                ║  │
│  ║  ┌─────────────────────────────────────────────┐                      ║  │
│  ║  │  For each feature:                          │                      ║  │
│  ║  │    1. Read context files                    │                      ║  │
│  ║  │    2. Implement ONE feature                 │                      ║  │
│  ║  │    3. Run tests (unit + e2e)                │                      ║  │
│  ║  │    4. Run lint + typecheck                  │                      ║  │
│  ║  │    5. Commit                                │                      ║  │
│  ║  │    6. Update feature-list.json              │                      ║  │
│  ║  │    7. Update progress.json                  │                      ║  │
│  ║  │    8. Next iteration                        │                      ║  │
│  ║  └─────────────────────────────────────────────┘                      ║  │
│  ║                                                                       ║  │
│  ║  Exit: All features complete OR human intervention needed             ║  │
│  ║                                                                       ║  │
│  ╚═══════════════════════════════════════════════════════════════════════╝  │
│                              │                                              │
│                              ▼                                              │
│                           REVIEW                                            │
│                              │                                              │
│               ┌───── clean ──┴─── issues ─────┐                             │
│               │                               │                             │
│               ▼                               ▼                             │
│           SUMMARY              ╔══════════════════════════════════════╗     │
│                                ║      REMEDIATION (Ralph Loop)        ║     │
│                                ╠══════════════════════════════════════╣     │
│                                ║                                      ║     │
│                                ║  Read findings.json                  ║     │
│                                ║      │                               ║     │
│                                ║      ▼                               ║     │
│                                ║  For each finding:                   ║     │
│                                ║    1. Design fix                     ║     │
│                                ║    2. Implement fix                  ║     │
│                                ║    3. Verify fix                     ║     │
│                                ║    4. Commit                         ║     │
│                                ║    5. Update findings.json           ║     │
│                                ║    6. Next iteration                 ║     │
│                                ║                                      ║     │
│                                ║  Exit: All findings resolved         ║     │
│                                ║                                      ║     │
│                                ╚══════════════════════════════════════╝     │
│                                              │                              │
│                                              ▼                              │
│                                           SUMMARY                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Agent-Phase Mapping

Different phases require different agent capabilities:

| Agent | Phases | Tools | Purpose |
|-------|--------|-------|---------|
| **context-builder** | Discovery, Exploration, Clarification | Read, Grep, Glob, WebSearch | Understand requirements and codebase |
| **security-analyst** | Audit, Threat, Triage | Read, Grep, Glob, Skill | Build security context |
| **architect** | Architecture, Hardening | Read, Grep, Glob, Skill | Design and security review |
| **implementer** | Implementation | Read, Write, Edit, Bash, Grep, Glob | Build features (Ralph-compatible) |
| **reviewer** | Review | Read, Grep, Glob, Bash | Quality and security review |
| **remediator** | Remediation | Read, Write, Edit, Bash, Grep, Glob | Fix issues (Ralph-compatible) |

## The Remediation Loop is a Mini Main Loop

When issues are found in Review, the Remediation phase mirrors the main workflow:

| Main Loop Phase | Remediation Equivalent |
|-----------------|------------------------|
| Discovery | Issue identified from Review |
| Exploration | Variants (find related issues) |
| Triage | Prioritize fixes |
| Architecture | Design the fix |
| Implementation | Apply the fix |
| Review | Verify the fix |

This recursive structure means the same patterns apply at both scales.

## State Management

All workflow state persists in `.claude/feature-forge/`:

```
.claude/feature-forge/
├── state.json              # Current phase, approvals, criteria
├── progress.json           # Session handoffs, history
├── feature-list.json       # Implementation checklist
├── findings.json           # Review findings (if any)
├── discovery.md            # Phase outputs...
├── exploration.md
├── audit-context.md
├── threat-model.md
├── triage.json
├── architecture.md
├── hardening-review.md
├── summary.md
└── archive/                # Archived session details
```

## Completion Criteria

Each phase has explicit completion criteria tracked in `state.json`:

```
{
  "phase": "implementation",
  "completion_criteria": {
    "all_features_complete": false,
    "tests_passing": true,
    "lint_clean": true,
    "typecheck_clean": true
  }
}
```

Implementation and Remediation loops only exit when criteria are met OR human intervention is requested.
