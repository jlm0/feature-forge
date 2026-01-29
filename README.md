# Feature-Forge

A Claude Code plugin for secure feature development with context building, security analysis, and human checkpoints.

## Overview

Feature-Forge orchestrates specialized agents through a disciplined workflow that builds deep context before writing
code, integrates security analysis throughout, and maintains human oversight at key decision points.

**Core Philosophy:**

- Context before action
- Security by design
- File-based memory persistence
- Human stewardship, not full autonomy

## Installation

```bash
claude --plugin-dir /path/to/feature-forge
```

## Usage

**Start a new feature:**

```bash
/feature-forge "Add user authentication with JWT tokens"
```

**Resume an interrupted workflow:**

```bash
/feature-forge resume
```

## Workflow

```
                    FEATURE-FORGE WORKFLOW
    ============================================================

    UNDERSTANDING
    +----------------------------------------------------------+
    |                                                          |
    |  Discovery -----> Exploration (parallel) -----> Security |
    |     |               /        \                  Context  |
    |     |           code        docs                   |     |
    |     |               \        /                     |     |
    |     +---------------> merge <----------------------+     |
    |                                                          |
    +----------------------------------------------------------+
                              |
                              v
                    [CLARIFICATION CHECKPOINT]
                     Present questions to human
                              |
                              v
    DESIGN (max 2 iterations)
    +----------------------------------------------------------+
    |                                                          |
    |  Parallel Specialists:                                   |
    |    ui-ux-designer                                        |
    |    frontend-engineer  -----> architect -----> security   |
    |    api-designer              (synthesis)      analyst    |
    |    data-modeler                               (hardening)|
    |                                                          |
    +----------------------------------------------------------+
                              |
                              v
                    [TRIAGE CHECKPOINT]
                     Approve architecture
                              |
                              v
    EXECUTION
    +----------------------------------------------------------+
    |                                                          |
    |  Implementation -----> Review (parallel) -----> Summary  |
    |  (Ralph loop)         quality    security                |
    |       |                   |                              |
    |       |                   v                              |
    |       |         [REVIEW CHECKPOINT]                      |
    |       |          Disposition findings                    |
    |       |                   |                              |
    |       |                   v                              |
    |       +<-------- Remediation (if needed)                 |
    |                  (Ralph loop, max 2 cycles)              |
    |                                                          |
    +----------------------------------------------------------+
                              |
                              v
                    [COMPLETION CHECKPOINT]
                     Accept deliverable
```

## Agents (10)

Feature-Forge uses specialized agents, each with isolated context and pre-loaded skills:

| Agent                 | Role      | Description                                                             |
| --------------------- | --------- | ----------------------------------------------------------------------- |
| **context-builder**   | Explorer  | Maps codebase structure, reads documentation, builds understanding      |
| **security-analyst**  | Security  | Threat modeling, footgun detection, variant hunting, fix verification   |
| **ui-ux-designer**    | Design    | Visual design, user flows, interaction patterns, accessibility          |
| **frontend-engineer** | Design    | Component architecture, state management, data fetching patterns        |
| **api-designer**      | Design    | API contracts, endpoint design, request/response schemas                |
| **data-modeler**      | Design    | Database schema, relationships, migrations, data integrity              |
| **architect**         | Synthesis | Combines specialist designs into unified blueprint with trade-offs      |
| **implementer**       | Build     | Writes production code following architecture and security requirements |
| **reviewer**          | Quality   | Code review for bugs, quality issues, and security vulnerabilities      |
| **remediator**        | Fix       | Addresses findings from review, verifies fixes address root cause       |

## Skills (18)

Skills are methodologies that frame how agents think about problems.

### Core Skills

| Skill                | Purpose                                      |
| -------------------- | -------------------------------------------- |
| **ask-questions**    | Clarify before acting (all agents have this) |
| **code-exploration** | Trace code paths, map architecture           |
| **docs-research**    | Read and synthesize external documentation   |

### Security Skills

| Skill                   | Purpose                                     |
| ----------------------- | ------------------------------------------- |
| **deep-context**        | Ultra-granular, line-by-line code analysis  |
| **threat-model**        | STRIDE-based threat enumeration             |
| **footgun-detection**   | Find dangerous defaults and misuse patterns |
| **variant-hunt**        | Find similar issues across codebase         |
| **fix-verify**          | Verify fixes address root cause             |
| **differential-review** | Risk-based security code review             |

### Design Skills

| Skill                      | Purpose                                         |
| -------------------------- | ----------------------------------------------- |
| **ui-ux-design**           | User flows, interaction patterns, accessibility |
| **frontend-engineering**   | Components, state, data fetching                |
| **api-design**             | REST/GraphQL conventions, contracts             |
| **data-modeling**          | Schema design, relationships, migrations        |
| **architecture-synthesis** | Trade-off analysis, blueprint creation          |
| **triage**                 | Impact and risk-based prioritization            |

### Execution Skills

| Skill                         | Purpose                                       |
| ----------------------------- | --------------------------------------------- |
| **implementation-discipline** | Clean code, conventions, incremental progress |
| **testing-methodology**       | Test selection, coverage, edge cases          |
| **code-review**               | Bug patterns, convention adherence            |

## State Persistence

All workflow state persists in `.claude/feature-forge/`:

```
.claude/feature-forge/
├── state.json           # Current phase, approvals, criteria
├── progress.json        # Session handoffs, history
├── feature-list.json    # Implementation checklist
├── findings.json        # Review findings
├── discovery.md         # Phase outputs...
├── exploration.md
├── security-context.md
├── architecture.md
├── hardening-review.md
├── triage.json
├── summary.md
└── archive/             # Archived session details
```

## Human Checkpoints

Feature-Forge pauses at key decision points for human input:

| Checkpoint        | After          | Decision                                |
| ----------------- | -------------- | --------------------------------------- |
| **Clarification** | Understanding  | Answer questions, provide context       |
| **Triage**        | Design         | Approve architecture or request changes |
| **Review**        | Implementation | Disposition findings (fix/defer/accept) |
| **Completion**    | Summary        | Accept deliverable                      |

## Documentation

For detailed architecture and design decisions:

- [Architecture](docs/ARCHITECTURE.md) - Phase groups, agents, skills, workflow
- [Plugin Structure](docs/PLUGIN-STRUCTURE.md) - Commands, skills, agents, hooks
- [Human Checkpoints](docs/HUMAN-CHECKPOINTS.md) - Intervention points and flow
- [Context Persistence](docs/CONTEXT-PERSISTENCE.md) - Memory patterns, Ralph loops
- [Security Integration](docs/SECURITY-INTEGRATION.md) - Security methodologies

## Dev Notes

- If "swarms" becomes a feature in Claude code as its meant to be then this workflow is effectively the same. We took
  Anthorpics idea of of orchestration and json file for managing state and built this plugin around it.
