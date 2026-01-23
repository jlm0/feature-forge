# Feature-Forge

**Secure, Human-Stewarded, Context-Persistent Feature Development**

Feature-Forge is a Claude Code plugin that combines deep context building, security analysis, iterative implementation,
and human oversight into a cohesive workflow for non-trivial feature development.

## Origin

Feature-Forge synthesizes learnings from multiple sources:

| Source                              | Contribution                                                    |
| ----------------------------------- | --------------------------------------------------------------- |
| **feature-dev** (Anthropic)         | Phased workflow, specialized agents, clarification loops        |
| **Trail of Bits skills**            | Security methodologies: deep context, threat modeling, footguns |
| **Ralph Wiggum** (Geoffrey Huntley) | Iterative loops, file-based memory persistence                  |
| **Anthropic research**              | Context management, two-agent harness, progress tracking        |

## Core Principles

1. **Context before action** — Build deep understanding before writing code
2. **Security by design** — Threat model and harden before implementation
3. **File-based memory** — Externalize findings to survive token limits
4. **Iterative execution** — Ralph-style loops for implementation and remediation
5. **Human stewardship** — Checkpoints at decision points, not full autonomy
6. **One feature at a time** — Incremental progress prevents context exhaustion

## The Workflow

```
UNDERSTANDING (Linear → Parallel)
├── Discovery        → Understand requirements
├── Exploration      → Map codebase (parallel: code + docs)
└── Security Context → Trust boundaries, attack surfaces

CLARIFICATION [HUMAN INPUT]
└── Questions        → Resolve ambiguities

DESIGN (2 iterations max)
├── Architecture     → Parallel specialists → synthesis
├── Security Review  → Footgun detection
└── Triage           → Prioritize for v1 [HUMAN CHECKPOINT]

EXECUTION (Ralph Loops)
├── Implementation   → Build features (iterative)
├── Review           → Quality + security (parallel)
├── Remediation      → Fix issues (iterative, 2 max)
└── Summary          → Document and handoff
```

## Agents and Skills

Feature-Forge uses **10 specialized agents** with **16 pre-loaded skills**:

| Agent            | Role                    | Key Skills                                    |
| ---------------- | ----------------------- | --------------------------------------------- |
| context-builder  | Explore codebase/docs   | code-exploration, docs-research               |
| security-analyst | Security analysis       | deep-context, threat-model, footgun-detection |
| ui-ux-designer   | Visual/interaction      | ui-ux-design                                  |
| frontend-engineer| Frontend technical      | frontend-engineering                          |
| api-designer     | API contracts           | api-design                                    |
| data-modeler     | Database schemas        | data-modeling                                 |
| architect        | Synthesis               | architecture-synthesis, triage                |
| implementer      | Write code              | implementation-discipline, testing-methodology|
| reviewer         | Evaluate quality        | code-review, deep-context                     |
| remediator       | Fix issues              | implementation-discipline, fix-verify         |

**Agent = Who** (the actor) | **Skill = How** (the methodology)

## Documentation

| Document                                             | Purpose                                  |
| ---------------------------------------------------- | ---------------------------------------- |
| [Architecture](docs/ARCHITECTURE.md)                 | Phase groups, agents, skills, flow       |
| [Context Persistence](docs/CONTEXT-PERSISTENCE.md)   | Memory patterns, JSON vs MD, Ralph loops |
| [Plugin Structure](docs/PLUGIN-STRUCTURE.md)         | Skills, agents, commands, hooks          |
| [Security Integration](docs/SECURITY-INTEGRATION.md) | Security skills and methodologies        |
| [Human Checkpoints](docs/HUMAN-CHECKPOINTS.md)       | Intervention points and feedback         |

## Status

**Conceptual Design Phase** — This repository currently contains architectural documentation and design decisions.
Implementation will follow once the design is validated.

## Name Origin

_"We don't just write code—we forge it through fire: understood, hardened, reviewed, and refined."_

Feature-Forge captures both the feature development aspect and the disciplined, security-conscious process of shaping
code through multiple phases of analysis and verification.
