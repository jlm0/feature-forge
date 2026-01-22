# Feature-Forge

**Secure, Human-Stewarded, Context-Persistent Feature Development**

Feature-Forge is a Claude Code plugin that combines deep context building, security analysis, iterative implementation, and human oversight into a cohesive workflow for non-trivial feature development.

## Origin

Feature-Forge synthesizes learnings from multiple sources:

| Source | Contribution |
|--------|--------------|
| **feature-dev** (Anthropic) | Phased workflow, specialized agents, clarification loops |
| **Trail of Bits skills** | Security-first context building, hardening review, verification |
| **Ralph Wiggum** (Geoffrey Huntley) | Iterative loops, file-based memory persistence |
| **Anthropic research** | Context management, two-agent harness, progress tracking |

## Core Principles

1. **Context before action** — Build deep understanding before writing code
2. **Security by design** — Threat model and harden before implementation
3. **File-based memory** — Externalize findings to survive token limits
4. **Iterative execution** — Ralph-style loops for implementation and remediation
5. **Human stewardship** — Checkpoints at uncertainty points, not full autonomy
6. **One feature at a time** — Incremental progress prevents context exhaustion

## The Workflow

```
CONTEXT BUILDING (Linear)
├── Discovery        → Understand requirements
├── Exploration      → Map codebase patterns
├── Audit            → Build security context
├── Threat           → Model threats and mitigations
├── Triage           → Prioritize for v1 (CHECKPOINT)
├── Clarification    → Resolve ambiguities (CHECKPOINT)
├── Architecture     → Design approaches (CHECKPOINT)
└── Hardening        → Review for security footguns (CHECKPOINT)

IMPLEMENTATION (Ralph Loop)
└── Iterative: implement → test → commit → next feature

REVIEW (Human + Agent)
├── Quality review
├── Security review
└── Decision: ship / fix / defer

REMEDIATION (Ralph Loop, if needed)
└── Iterative: fix → verify → commit → next finding

SUMMARY
└── Document and handoff
```

## Documentation

| Document | Purpose |
|----------|---------|
| [Architecture](docs/ARCHITECTURE.md) | Workflow phases, flow, structure |
| [Context Persistence](docs/CONTEXT-PERSISTENCE.md) | Memory patterns, JSON vs MD, Ralph loops |
| [Plugin Structure](docs/PLUGIN-STRUCTURE.md) | Skills, agents, commands, hooks |
| [Security Integration](docs/SECURITY-INTEGRATION.md) | Trail of Bits skill composition |
| [Human Checkpoints](docs/HUMAN-CHECKPOINTS.md) | Intervention points and feedback |

## Status

**Conceptual Design Phase** — This repository currently contains architectural documentation and design decisions. Implementation will follow once the design is validated.

## Name Origin

*"We don't just write code—we forge it through fire: understood, hardened, reviewed, and refined."*

Feature-Forge captures both the feature development aspect and the disciplined, security-conscious process of shaping code through multiple phases of analysis and verification.
