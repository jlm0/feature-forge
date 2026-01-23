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

## License

MIT

## Developer Footnotes

I spent the better half of a day building my context of Claude's plugin architecture, agent model, and skill system
before proceeding with the implementation of Feature-Forge. And yes of course Claude was involved in that process!
Through multiple full conversation sessions and context compressions we managed to dump and synthesize a significant
portion of the relevant documentation together and create a docs outline. I also took inspiration from existing plugins
like "feature-dev" and Trail of Bits skills to understand how others were approaching skill and agent creation. However
from my perspective the skills and agents needed to implement great features actually required an orchestration that
went far beyond what those plugins provided. So I designed a new workflow from the ground up that emphasized context
building, security integration, and human checkpoints.

The mental model I landed on was this: if an Agent is just the equivalent of a worker who has context and tasks to
perform, and a Skill is a methodology or approach that worker uses to perform their tasks, then the workflow is the
project plan that organizes how those workers and methodologies interact to deliver the final product. Allow these
agents to pass their context to each other like coworkers giving handoffs and you can simulate a team working together.
By breaking the feature development process into distinct phases with clear goals and deliverables, I was able to create
a structured approach that ensures thoroughness and quality at each step.

Of course as we all know AI still generates AI slop, so incorporating human checkpoints was essential. By no means is
Feature-Forge a set it and forget it autonomous system. I intentionally want a human at the steering wheel to ensure the
final deliverables are up to par. And that's what these tools are for - to augment human capabilities, not replace them.
As a developer you can leverage your own set of "skills" to guide and oversee the work of these agents, ensuring the
final output aligns with your vision and standards.

After not kidding 7-8 hours of building my own context and reasoning through how workflows work and the loops required,
doing research on simple context persistence approaches that didn't need a database, and thinking through security
integration - I felt comfortable to let Claude loose on building Feature-Forge. Testing and refining is still an ongoing
process , but the core architecture and workflow are solid. The plugin can now guide users through a disciplined feature
development process that emphasizes understanding, design, execution, and review - all while integrating security
analysis and maintaining human oversight.Overall I am quite proud of how Feature-Forge turned out and I believe it
provides a solid foundation for secure feature development using Claude Code plugins.

By no means do I take credit for it in its entirety - Claude was instrumental in helping me reason through the
architecture, design the workflow, and even write portions of the code. The existing plugins from Anthropic and Trail of
Bits provided invaluable reference points as well. But I do take pride in having orchestrated the entire process and
brought it all together into a cohesive whole. I highly recommend other developers take the time to study these existing
plugins as they embark on their own plugin development journeys. There's a lot to learn from the work others have done
in this space, and much like no single person has ownership of a skill we can create our own versions inspired by those
that came before us. I look forward to seeing how others might build upon Feature-Forge and adapt it to their own
workflows. Happy coding!
