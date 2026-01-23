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

### Human Input = Cross-Cutting Mechanism

Human input is NOT a discrete phase—it's a mechanism available throughout:

- **Questions** — Agents ask when uncertain (internal to phases)
- **Checkpoints** — Explicit approval gates at phase transitions
- **AskUserQuestion tool** — Interactive prompting for clarification

The human is the orchestrating architect, always available to guide.

### Key Distinctions

| Concept        | Answers | Example                                           |
| -------------- | ------- | ------------------------------------------------- |
| **Agent**      | Who?    | "The security analyst examines the code"          |
| **Skill**      | How?    | "Using threat modeling methodology (STRIDE)"      |
| **Phase**      | When?   | "During the Design group"                         |
| **Tool**       | With?   | "Using Read, Grep, Glob to explore"               |
| **Questions**  | Clarify | "Agent asks user for scope clarification"         |
| **Checkpoint** | Approve | "Human approves architecture before implementation"|

## Questions vs Checkpoints

Two types of human interaction, serving different purposes:

### Questions (Internal to Phases)

**What:** Agents ask clarifying questions while working
**When:** Uncertainty arises, multiple valid paths, user could provide shortcuts
**How:** AskUserQuestion tool with multiple-choice options
**Behavior:** Agent pauses, gets answer, continues work

```
Agent working
      │
      ├── Encounters uncertainty
      │
      ▼
Ask question (multiple-choice, defaults)
      │
      ▼
Wait for answer
      │
      ▼
Confirm interpretation
      │
      ▼
Continue work
```

### Checkpoints (Phase Transitions)

**What:** Explicit approval gates before major transitions
**When:** Phase group completes, significant investment ahead
**How:** Present summary, request approval
**Behavior:** Work stops until human approves or requests changes

```
Phase group completes
      │
      ▼
Present summary + outputs
      │
      ▼
Wait for approval
      │
      ├── Approved ──► Proceed to next group
      │
      └── Changes ──► Iterate (max 2)
```

### Summary Table

| Aspect          | Questions                        | Checkpoints                     |
| --------------- | -------------------------------- | ------------------------------- |
| **Purpose**     | Clarify uncertainty              | Approve direction               |
| **Timing**      | Internal to phases               | Between phase groups            |
| **Frequency**   | As needed                        | Fixed points in workflow        |
| **Blocking**    | Pauses current agent             | Stops all progress              |
| **Output**      | Answer incorporated, work continues | Approval or iteration request |

## Skills (18 Total)

Skills are methodologies pre-loaded into agents to frame their thinking.

| Skill                       | Purpose                              | Methodology                                     |
| --------------------------- | ------------------------------------ | ----------------------------------------------- |
| **ask-questions**           | Clarify before acting                | Minimum questions, multiple-choice, pause until answered |
| **code-exploration**        | Trace code, map architecture         | Entry points → call chains → dependencies       |
| **docs-research**           | Read and digest external docs        | Identify sources → extract patterns → synthesize |
| **deep-context**            | Ultra-granular code analysis         | Line-by-line, First Principles, 5 Whys          |
| **threat-model**            | Security threat enumeration          | STRIDE, actor mapping, trust boundaries         |
| **footgun-detection**       | API misuse and dangerous defaults    | Adversary modeling, edge case probing           |
| **variant-hunt**            | Find similar issues                  | Start specific → generalize → stop at 50% FP    |
| **fix-verify**              | Verify fixes address root cause      | Differential analysis, regression detection     |
| **differential-review**     | Security-focused code review         | Risk-based triage, adaptive depth, blast radius |
| **ui-ux-design**            | Visual design and UX                 | User flows, interaction patterns, accessibility |
| **frontend-engineering**    | Frontend technical implementation    | State management, components, data fetching     |
| **api-design**              | API contract design                  | REST/GraphQL conventions, versioning            |
| **data-modeling**           | Database and schema design           | Relationships, normalization, migrations        |
| **architecture-synthesis**  | System design from multiple inputs   | Trade-off analysis, blueprint creation          |
| **implementation-discipline** | Writing production code            | Clean code, conventions, incremental progress   |
| **testing-methodology**     | How to verify correctness            | Test selection, coverage, edge cases            |
| **code-review**             | Evaluate code quality                | Bug patterns, convention adherence              |
| **triage**                  | Prioritization decisions             | Impact, urgency, risk assessment                |

### The ask-questions Skill

Inspired by Trail of Bits' "ask-questions-if-underspecified" skill. ALL agents should have this.

**When to use:**
- Multiple plausible interpretations exist
- Key details (objective, scope, constraints) are unclear
- Decision exceeds delegated authority
- User could provide valuable shortcuts (sources, existing code)

**How to ask:**
1. Ask 1-5 questions maximum (prefer questions that eliminate branches)
2. Make questions easy to answer:
   - Multiple-choice options when possible
   - Suggest reasonable defaults (marked clearly)
   - Include fast-path response ("reply `defaults` to accept all")
   - Numbered questions with lettered options
3. **Pause before acting** until answers arrive
4. Can do low-risk discovery while waiting
5. Confirm interpretation before proceeding

**Question template:**
```
Before I proceed, I need to clarify:

1) Scope?
   a) Minimal change (recommended)
   b) Refactor while touching the area
   c) Not sure - use default

2) Which authentication approach?
   a) JWT tokens (recommended for your mobile app)
   b) Session cookies
   c) OAuth only

Reply with: defaults (or 1a 2a)
```

### The differential-review Skill

Inspired by Trail of Bits' differential-review skill. Used in Review phase.

**When to use:**
- Reviewing implementation for quality and security
- Analyzing PRs, commits, or diffs

**Methodology:**
- Classify risk level per file (HIGH, MEDIUM, LOW)
- Adapt analysis depth to codebase size (SMALL, MEDIUM, LARGE)
- Calculate blast radius for high-risk changes
- Generate concrete attack scenarios, not generic findings
- Reference specific line numbers and commits

## Agents (10 Total)

All agents have access to the `ask-questions` skill for human interaction.

| Agent                | Role                         | Pre-loaded Skills                                                         | Tools                                 |
| -------------------- | ---------------------------- | ------------------------------------------------------------------------- | ------------------------------------- |
| **context-builder**  | Explore codebase and docs    | ask-questions, code-exploration, docs-research                            | Read, Grep, Glob, WebSearch, WebFetch |
| **security-analyst** | Security analysis            | ask-questions, deep-context, threat-model, footgun-detection, variant-hunt, fix-verify | Read, Grep, Glob       |
| **ui-ux-designer**   | Visual and interaction design| ask-questions, ui-ux-design                                               | Read, Grep, Glob, WebFetch            |
| **frontend-engineer**| Frontend technical design    | ask-questions, frontend-engineering                                       | Read, Grep, Glob                      |
| **api-designer**     | API contract design          | ask-questions, api-design                                                 | Read, Grep, Glob                      |
| **data-modeler**     | Database schema design       | ask-questions, data-modeling                                              | Read, Grep, Glob                      |
| **architect**        | Synthesize into blueprint    | ask-questions, architecture-synthesis, triage                             | Read, Grep, Glob                      |
| **implementer**      | Write production code        | ask-questions, implementation-discipline, testing-methodology             | Read, Write, Edit, Bash, Grep, Glob   |
| **reviewer**         | Evaluate implementation      | ask-questions, code-review, deep-context, differential-review             | Read, Grep, Glob, Bash                |
| **remediator**       | Fix identified issues        | ask-questions, implementation-discipline, testing-methodology, fix-verify | Read, Write, Edit, Bash, Grep, Glob   |

## Phase Groups

Feature-Forge operates in three macro groups:

```
UNDERSTANDING
├── Discovery        [CAN ASK: sources, constraints, scope]
├── Exploration      [CAN ASK: confirm patterns, clarify code]
└── Security Context [CAN ASK: risk tolerance, compliance]

DESIGN (2 iterations max)
├── Architecture     [CAN ASK: trade-offs, preferences]
├── Security Review  [CAN ASK: acceptable risks]
└── Triage           [CHECKPOINT: approve priorities]

EXECUTION
├── Implementation   [CAN ASK: blockers, approach]
├── Review           [CHECKPOINT: disposition findings]
├── Remediation      [CAN ASK: fix approaches]
└── Summary
```

**Legend:**
- `[CAN ASK]` — Agent uses ask-questions skill when uncertain
- `[CHECKPOINT]` — Requires explicit human approval to proceed

## Human Input Opportunities

### UNDERSTANDING Group

| Phase              | Questions Agents Might Ask                                    |
| ------------------ | ------------------------------------------------------------- |
| **Discovery**      | "What sources should I read?" "What's out of scope?"          |
| **Exploration**    | "This pattern is unusual—is it intentional?" "Confirm X?"     |
| **Security Context**| "What's your risk tolerance?" "Compliance requirements?"      |

**After UNDERSTANDING:** Orchestrator may surface questions that arose during exploration.

### DESIGN Group

| Phase              | Questions Agents Might Ask                                    |
| ------------------ | ------------------------------------------------------------- |
| **Architecture**   | "Multiple valid approaches—prefer A or B?" "Trade-off: X vs Y?"|
| **Security Review**| "This risk exists—acceptable for v1?" "Mitigation priority?"  |
| **Triage**         | **[CHECKPOINT]** — Present design, request approval           |

### EXECUTION Group

| Phase              | Questions Agents Might Ask                                    |
| ------------------ | ------------------------------------------------------------- |
| **Implementation** | "Blocked on X—guidance?" "Clarify requirement Y?"             |
| **Review**         | **[CHECKPOINT]** — Present findings, request disposition      |
| **Remediation**    | "Multiple fix approaches—preference?" "Accept remaining risk?"|
| **Summary**        | Final handoff, no questions typically needed                  |

## Phase Flow with Human Input

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FEATURE-FORGE WORKFLOW                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ╔═══════════════════════════════════════════════════════════════════════╗  │
│  ║                    UNDERSTANDING                                      ║  │
│  ╠═══════════════════════════════════════════════════════════════════════╣  │
│  ║                                                                       ║  │
│  ║  DISCOVERY ◄─── questions ───────────────────────────────────────────►║  │
│  ║      │         (sources, scope, constraints)                          ║  │
│  ║      │                                                                ║  │
│  ║      ├──► context-builder (code) ─────┐                               ║  │
│  ║      │         ◄── questions ──►      ├──► exploration.md             ║  │
│  ║      └──► context-builder (docs) ─────┘                               ║  │
│  ║                    (PARALLEL)              │                          ║  │
│  ║                                            ▼                          ║  │
│  ║                                  security-analyst                     ║  │
│  ║                                    ◄── questions ──►                  ║  │
│  ║                                            │                          ║  │
│  ║                                            ▼                          ║  │
│  ║                                  security-context.md                  ║  │
│  ║                                                                       ║  │
│  ╚═══════════════════════════════════════════════════════════════════════╝  │
│                              │                                              │
│                              ▼                                              │
│  ╔═══════════════════════════════════════════════════════════════════════╗  │
│  ║                    DESIGN (2 iterations max)                          ║  │
│  ╠═══════════════════════════════════════════════════════════════════════╣  │
│  ║                                                                       ║  │
│  ║  ARCHITECTURE (Parallel Specialists)                                  ║  │
│  ║  ◄───────────────── questions ──────────────────►                     ║  │
│  ║                                                                       ║  │
│  ║    ui-ux-designer ─────┐                                              ║  │
│  ║    frontend-engineer ──┼──► architect ──► architecture.md             ║  │
│  ║    api-designer ───────┤      (synthesis)                             ║  │
│  ║    data-modeler ───────┘                                              ║  │
│  ║                              │                                        ║  │
│  ║                              ▼                                        ║  │
│  ║                    security-analyst ◄── questions ──►                 ║  │
│  ║                    (footgun detection)                                ║  │
│  ║                              │                                        ║  │
│  ║                              ▼                                        ║  │
│  ║                    hardening-review.md                                ║  │
│  ║                              │                                        ║  │
│  ║                              ▼                                        ║  │
│  ║            ╔═════════════════════════════════════════╗                ║  │
│  ║            ║  TRIAGE [CHECKPOINT]                    ║                ║  │
│  ║            ║  Present: architecture + security       ║                ║  │
│  ║            ║  Human: approve / request changes       ║                ║  │
│  ║            ╚═════════════════════════════════════════╝                ║  │
│  ║                              │                                        ║  │
│  ║              ┌─── approved ──┴─── changes ───┐                        ║  │
│  ║              │                               │                        ║  │
│  ║              ▼                        (max 2 iterations)              ║  │
│  ║         triage.json                                                   ║  │
│  ║                                                                       ║  │
│  ╚═══════════════════════════════════════════════════════════════════════╝  │
│                              │                                              │
│                              ▼                                              │
│  ╔═══════════════════════════════════════════════════════════════════════╗  │
│  ║                    EXECUTION (Ralph Loops)                            ║  │
│  ╠═══════════════════════════════════════════════════════════════════════╣  │
│  ║                                                                       ║  │
│  ║  IMPLEMENTATION (Ralph Loop) ◄── questions ──►                        ║  │
│  ║                                (blockers, clarifications)             ║  │
│  ║  For each feature:                                                    ║  │
│  ║    1. Read context files                                              ║  │
│  ║    2. Implement ONE feature                                           ║  │
│  ║    3. Run tests                                                       ║  │
│  ║    4. Commit                                                          ║  │
│  ║    5. Update progress                                                 ║  │
│  ║    6. Next iteration (fresh context)                                  ║  │
│  ║                              │                                        ║  │
│  ║                              ▼                                        ║  │
│  ║            ╔═════════════════════════════════════════╗                ║  │
│  ║            ║  REVIEW [CHECKPOINT]                    ║                ║  │
│  ║            ║  Present: quality + security findings   ║                ║  │
│  ║            ║  Human: ship / fix now / defer          ║                ║  │
│  ║            ╚═════════════════════════════════════════╝                ║  │
│  ║                              │                                        ║  │
│  ║               ┌───── clean ──┴─── issues ─────┐                       ║  │
│  ║               │                               │                       ║  │
│  ║               ▼                               ▼                       ║  │
│  ║           SUMMARY          REMEDIATION (Ralph Loop)                   ║  │
│  ║                            ◄── questions ──►                          ║  │
│  ║                            (fix approaches)                           ║  │
│  ║                            For each finding:                          ║  │
│  ║                              1. Design fix                            ║  │
│  ║                              2. Implement fix                         ║  │
│  ║                              3. Verify fix                            ║  │
│  ║                              4. Commit                                ║  │
│  ║                                    │                                  ║  │
│  ║                                    ▼                                  ║  │
│  ║                                 SUMMARY                               ║  │
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

## One-Level Max Nesting

**Critical constraint:** Agents can be spawned by the orchestrator, but agents cannot spawn sub-agents.

```
orchestrator (main command)
    │
    ├── context-builder ──► can ask questions ──► returns findings
    ├── security-analyst ──► can ask questions ──► returns findings
    └── ... etc

NOT ALLOWED:
    architect
        └── security-analyst (nested spawn)
```

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

## Human as Orchestrating Architect

The human is not just a checkpoint—they are the orchestrating architect throughout:

| Role                     | How                                               |
| ------------------------ | ------------------------------------------------- |
| **Provides sources**     | Discovery: "Read the RFC at this URL"             |
| **Clarifies scope**      | Discovery: "Only the auth module, not payments"   |
| **Guides exploration**   | Exploration: "Check how we did this in service X" |
| **Makes trade-offs**     | Architecture: "Prefer simplicity over performance"|
| **Sets risk tolerance**  | Security: "We can accept this risk for v1"        |
| **Approves direction**   | Checkpoints: "Approved" or "Change X"             |
| **Dispositions findings**| Review: "Fix now" or "Defer to v1.1"              |

The workflow is designed for **human stewardship**, not "set and forget" autonomy.
