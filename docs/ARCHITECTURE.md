# Feature-Forge Architecture

## Core Concepts

### Agent = Role (Who)

Agents are the actors that perform work. Each agent has:

- Isolated context window (prevents pollution)
- Pre-loaded skills that frame their thinking
- Restricted tool access based on their role
- Domain-specific expertise

### Skill = Methodology (How)

Skills define how an agent thinks about problems. They are:

- Pre-loaded into agents at spawn time
- Methodologies, not procedures
- Reusable across different phases
- The "lens" through which work is viewed

### Key Distinction

| Concept   | Answers | Example                                       |
| --------- | ------- | --------------------------------------------- |
| **Agent** | Who?    | "The security analyst examines the code"      |
| **Skill** | How?    | "Using threat modeling methodology (STRIDE)"  |
| **Phase** | When?   | "During the Design group"                     |
| **Tool**  | With?   | "Using Read, Grep, Glob to explore"           |

## Phase Groups

Feature-Forge operates in four macro groups:

```
UNDERSTANDING (Linear)
├── Discovery        → What needs to be built
├── Exploration      → How the codebase works (parallel agents)
└── Security Context → Trust boundaries, attack surfaces

CLARIFICATION (Human Input)
└── Questions        → Resolve ambiguities [HUMAN INPUT]

DESIGN (2 iterations max)
├── Architecture     → Parallel specialists → synthesis
├── Security Review  → Review for footguns
└── Triage           → Prioritize for v1 [HUMAN CHECKPOINT]

EXECUTION (Ralph Loops)
├── Implementation   → Build features (Ralph loop)
├── Review           → Quality + security (parallel reviewers)
├── Remediation      → Fix issues (Ralph loop, 2 max)
└── Summary          → Document and handoff
```

## Skills (16 Total)

Skills are methodologies pre-loaded into agents to frame their thinking.

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

## Agents (10 Total)

Agents are domain-specific actors, like a real development team.

| Agent                | Role                         | Pre-loaded Skills                                          | Tools                                      |
| -------------------- | ---------------------------- | ---------------------------------------------------------- | ------------------------------------------ |
| **context-builder**  | Explore codebase and docs    | code-exploration, docs-research                            | Read, Grep, Glob, WebSearch, WebFetch      |
| **security-analyst** | Security analysis            | deep-context, threat-model, footgun-detection, variant-hunt, fix-verify | Read, Grep, Glob          |
| **ui-ux-designer**   | Visual and interaction design| ui-ux-design                                               | Read, Grep, Glob, WebFetch                 |
| **frontend-engineer**| Frontend technical design    | frontend-engineering                                       | Read, Grep, Glob                           |
| **api-designer**     | API contract design          | api-design                                                 | Read, Grep, Glob                           |
| **data-modeler**     | Database schema design       | data-modeling                                              | Read, Grep, Glob                           |
| **architect**        | Synthesize into blueprint    | architecture-synthesis, triage                             | Read, Grep, Glob                           |
| **implementer**      | Write production code        | implementation-discipline, testing-methodology             | Read, Write, Edit, Bash, Grep, Glob        |
| **reviewer**         | Evaluate implementation      | code-review, deep-context                                  | Read, Grep, Glob, Bash                     |
| **remediator**       | Fix identified issues        | implementation-discipline, testing-methodology, fix-verify | Read, Write, Edit, Bash, Grep, Glob        |

## Phase Flow with Inputs/Outputs

### UNDERSTANDING Group

| Phase              | Agent(s)                | Inputs                   | Outputs                | Notes                  |
| ------------------ | ----------------------- | ------------------------ | ---------------------- | ---------------------- |
| **Discovery**      | context-builder         | User request             | `discovery.md`         | Single agent           |
| **Exploration**    | context-builder (×2)    | Discovery + codebase     | `exploration.md`       | **Parallel**: code + docs |
| **Security Context** | security-analyst      | Exploration outputs      | `security-context.md`  | Trust boundaries, attack surfaces |

### CLARIFICATION Group

| Phase          | Agent(s)        | Inputs            | Outputs              | Notes                 |
| -------------- | --------------- | ----------------- | -------------------- | --------------------- |
| **Questions**  | orchestrator    | All prior context | Updated discovery    | [HUMAN INPUT] required |

### DESIGN Group (2 iterations max)

| Phase              | Agent(s)                               | Inputs              | Outputs               | Notes                      |
| ------------------ | -------------------------------------- | ------------------- | --------------------- | -------------------------- |
| **Architecture**   | ui-ux-designer, frontend-engineer, api-designer, data-modeler → architect | All context | `architecture.md` | **Parallel** specialists → synthesis |
| **Security Review** | security-analyst                      | Architecture        | `hardening-review.md` | Footgun detection          |
| **Triage**         | architect + security-analyst           | All design outputs  | `triage.json`         | [HUMAN CHECKPOINT]         |

### EXECUTION Group

| Phase              | Agent(s)        | Inputs                  | Outputs               | Notes                      |
| ------------------ | --------------- | ----------------------- | --------------------- | -------------------------- |
| **Implementation** | implementer     | Architecture + features | Code + commits        | Ralph loop                 |
| **Review**         | reviewer (×2)   | Implementation          | `findings.json`       | **Parallel**: quality + security |
| **Remediation**    | remediator      | Findings                | Fixed code + commits  | Ralph loop (2 max)         |
| **Summary**        | context-builder | All outputs             | `summary.md`          | Document and handoff       |

## Detailed Phase Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FEATURE-FORGE WORKFLOW                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ╔═══════════════════════════════════════════════════════════════════════╗  │
│  ║                    UNDERSTANDING (Linear → Parallel)                  ║  │
│  ╠═══════════════════════════════════════════════════════════════════════╣  │
│  ║                                                                       ║  │
│  ║  DISCOVERY ──────────────────────────────────────────────────────────►║  │
│  ║      │                                                                ║  │
│  ║      │                                                                ║  │
│  ║      ├──► context-builder (code) ─────┐                               ║  │
│  ║      │                                ├──► exploration.md             ║  │
│  ║      └──► context-builder (docs) ─────┘                               ║  │
│  ║                    (PARALLEL)              │                          ║  │
│  ║                                            ▼                          ║  │
│  ║                                  security-analyst                     ║  │
│  ║                                            │                          ║  │
│  ║                                            ▼                          ║  │
│  ║                                  security-context.md                  ║  │
│  ║                                                                       ║  │
│  ╚═══════════════════════════════════════════════════════════════════════╝  │
│                              │                                              │
│                              ▼                                              │
│  ╔═══════════════════════════════════════════════════════════════════════╗  │
│  ║                    CLARIFICATION [HUMAN INPUT]                        ║  │
│  ╠═══════════════════════════════════════════════════════════════════════╣  │
│  ║                                                                       ║  │
│  ║  Present ambiguities and questions to human                           ║  │
│  ║  Human provides answers/decisions                                     ║  │
│  ║  Update discovery.md with clarifications                              ║  │
│  ║                                                                       ║  │
│  ╚═══════════════════════════════════════════════════════════════════════╝  │
│                              │                                              │
│                              ▼                                              │
│  ╔═══════════════════════════════════════════════════════════════════════╗  │
│  ║                    DESIGN (2 iterations max)                          ║  │
│  ╠═══════════════════════════════════════════════════════════════════════╣  │
│  ║                                                                       ║  │
│  ║  ┌──────────────────────────────────────────────────────────────┐     ║  │
│  ║  │ ARCHITECTURE (Parallel Specialists)                          │     ║  │
│  ║  │                                                              │     ║  │
│  ║  │   ui-ux-designer ─────┐                                      │     ║  │
│  ║  │   frontend-engineer ──┼──► architect ──► architecture.md     │     ║  │
│  ║  │   api-designer ───────┤      (synthesis)                     │     ║  │
│  ║  │   data-modeler ───────┘                                      │     ║  │
│  ║  │                                                              │     ║  │
│  ║  └──────────────────────────────────────────────────────────────┘     ║  │
│  ║                              │                                        ║  │
│  ║                              ▼                                        ║  │
│  ║                    security-analyst                                   ║  │
│  ║                    (footgun detection)                                ║  │
│  ║                              │                                        ║  │
│  ║                              ▼                                        ║  │
│  ║                    hardening-review.md                                ║  │
│  ║                              │                                        ║  │
│  ║                              ▼                                        ║  │
│  ║                    TRIAGE [HUMAN CHECKPOINT]                          ║  │
│  ║                              │                                        ║  │
│  ║              ┌─── approved ──┴─── needs changes ───┐                  ║  │
│  ║              │                                     │                  ║  │
│  ║              ▼                                     │                  ║  │
│  ║         triage.json              (loop back, max 2 iterations)        ║  │
│  ║                                                                       ║  │
│  ╚═══════════════════════════════════════════════════════════════════════╝  │
│                              │                                              │
│                              ▼                                              │
│  ╔═══════════════════════════════════════════════════════════════════════╗  │
│  ║                    EXECUTION (Ralph Loops)                            ║  │
│  ╠═══════════════════════════════════════════════════════════════════════╣  │
│  ║                                                                       ║  │
│  ║  ┌─────────────────────────────────────────────────────────────┐      ║  │
│  ║  │  IMPLEMENTATION (Ralph Loop)                                │      ║  │
│  ║  │                                                             │      ║  │
│  ║  │  Read feature-list.json                                     │      ║  │
│  ║  │       │                                                     │      ║  │
│  ║  │       ▼                                                     │      ║  │
│  ║  │  For each feature:                                          │      ║  │
│  ║  │    1. Read context files                                    │      ║  │
│  ║  │    2. Implement ONE feature                                 │      ║  │
│  ║  │    3. Run tests                                             │      ║  │
│  ║  │    4. Run lint + typecheck                                  │      ║  │
│  ║  │    5. Commit                                                │      ║  │
│  ║  │    6. Update feature-list.json                              │      ║  │
│  ║  │    7. Update progress.json                                  │      ║  │
│  ║  │    8. Next iteration (fresh context)                        │      ║  │
│  ║  │                                                             │      ║  │
│  ║  │  Exit: All features complete OR human intervention          │      ║  │
│  ║  └─────────────────────────────────────────────────────────────┘      ║  │
│  ║                              │                                        ║  │
│  ║                              ▼                                        ║  │
│  ║  ┌─────────────────────────────────────────────────────────────┐      ║  │
│  ║  │  REVIEW (Parallel)                                          │      ║  │
│  ║  │                                                             │      ║  │
│  ║  │  reviewer (quality) ────┐                                   │      ║  │
│  ║  │                         ├──► findings.json                  │      ║  │
│  ║  │  reviewer (security) ───┘                                   │      ║  │
│  ║  │                                                             │      ║  │
│  ║  └─────────────────────────────────────────────────────────────┘      ║  │
│  ║                              │                                        ║  │
│  ║               ┌───── clean ──┴─── issues ─────┐                       ║  │
│  ║               │                               │                       ║  │
│  ║               ▼                               ▼                       ║  │
│  ║           SUMMARY          ┌─────────────────────────────────────┐    ║  │
│  ║                            │  REMEDIATION (Ralph Loop, 2 max)    │    ║  │
│  ║                            │                                     │    ║  │
│  ║                            │  Read findings.json                 │    ║  │
│  ║                            │       │                             │    ║  │
│  ║                            │       ▼                             │    ║  │
│  ║                            │  For each finding:                  │    ║  │
│  ║                            │    1. Design fix                    │    ║  │
│  ║                            │    2. Implement fix                 │    ║  │
│  ║                            │    3. Verify fix                    │    ║  │
│  ║                            │    4. Commit                        │    ║  │
│  ║                            │    5. Update findings.json          │    ║  │
│  ║                            │    6. Next iteration                │    ║  │
│  ║                            │                                     │    ║  │
│  ║                            │  Exit: All findings resolved        │    ║  │
│  ║                            └─────────────────────────────────────┘    ║  │
│  ║                                              │                        ║  │
│  ║                                              ▼                        ║  │
│  ║                                           SUMMARY                     ║  │
│  ║                                                                       ║  │
│  ╚═══════════════════════════════════════════════════════════════════════╝  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Parallelism Specification

| Phase        | Parallel Agents                                         | Synchronization Point       |
| ------------ | ------------------------------------------------------- | --------------------------- |
| Exploration  | context-builder (code), context-builder (docs)          | Both complete → merge       |
| Architecture | ui-ux, frontend-engineer, api-designer, data-modeler    | All complete → architect    |
| Review       | reviewer (quality), reviewer (security)                 | Both complete → merge       |

## Remediation as Mini Main Loop

The remediation phase mirrors the main workflow structure:

| Main Loop Phase | Remediation Equivalent         |
| --------------- | ------------------------------ |
| Discovery       | Issue identified from Review   |
| Exploration     | Variant hunt (find related)    |
| Triage          | Prioritize fixes               |
| Architecture    | Design the fix                 |
| Implementation  | Apply the fix                  |
| Review          | Verify the fix                 |

This recursive structure means the same patterns apply at both scales.

## One-Level Max Nesting

**Critical constraint:** Agents can be spawned by the orchestrator, but agents cannot spawn sub-agents.

```
orchestrator (main command)
    │
    ├── context-builder ──► returns findings
    ├── security-analyst ──► returns findings
    ├── architect ──► returns findings
    ├── implementer ──► returns code
    └── ... etc

NOT ALLOWED:
    architect
        └── security-analyst (nested spawn)
```

This prevents context explosion and keeps the workflow manageable.

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
├── security-context.md
├── architecture.md
├── hardening-review.md
├── triage.json
├── summary.md
└── archive/                # Archived session details
```

## Completion Criteria

Each phase has explicit completion criteria tracked in `state.json`:

```json
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

## Human as Orchestrating Architect

The human is not just a checkpoint—they are the orchestrating architect:

- **Provides business context** that AI cannot infer
- **Makes trade-off decisions** when multiple valid paths exist
- **Approves direction** before significant investment
- **Intervenes** when AI encounters uncertainty

The workflow is designed for human stewardship, not full autonomy.
