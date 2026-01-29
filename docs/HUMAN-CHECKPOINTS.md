# Human Checkpoints and Intervention

## Philosophy

Feature-Forge operates on a principle of **human stewardship**, not full automation:

- AI handles execution within defined parameters
- Humans provide business context and make trade-off decisions
- Quality emerges from human-AI collaboration
- The human is the orchestrating architect

_"Think of it as a relay race where you're passing the baton."_

## Why Human Checkpoints Matter

Without checkpoints:

- Agents may declare tasks complete without verification
- Design decisions are made without stakeholder input
- Security trade-offs are chosen without business context
- Errors compound through subsequent phases

With checkpoints:

- Course correction before significant investment
- Business context informs technical decisions
- Security requirements aligned with risk appetite
- Quality maintained through explicit verification

## Checkpoint Locations

Feature-Forge has checkpoints at key decision points:

| Checkpoint        | After Phase              | What's Reviewed                | Typical Decision          |
| ----------------- | ------------------------ | ------------------------------ | ------------------------- |
| **Clarification** | UNDERSTANDING group      | Ambiguities and questions      | Provide answers           |
| **Design Triage** | DESIGN group (each iter) | Architecture + security review | Approve / Request changes |
| **Review**        | Implementation           | Quality & security findings    | Ship / Fix now / Defer    |
| **Completion**    | Summary                  | Final deliverable              | Accept / Revise           |

## Checkpoint Flow

```
Phase group completes
      │
      ▼
Update state.json: group=X, status=pending_approval
      │
      ▼
Present summary to human:
  - What was done
  - Key findings/decisions
  - Recommendations
  - Questions (if any)
      │
      ▼
Wait for human response
      │
      ├── Approved ──► Update state.json, proceed to next group
      │
      ├── Feedback ──► Incorporate feedback, may re-run phases
      │
      └── Questions ──► Answer questions, then re-present
```

## Checkpoints by Group

### CLARIFICATION Checkpoint

**When:** After UNDERSTANDING group, before DESIGN

**Purpose:** Resolve ambiguities discovered during exploration.

**What's presented:**

- Questions about requirements
- Unclear business rules discovered
- Technology choices that need input
- Scope clarifications

**Human provides:**

- Answers to specific questions
- Business context
- Priority guidance
- Scope decisions

**Output:** Updated `discovery.md` with clarifications

### DESIGN Checkpoint (Triage)

**When:** After each DESIGN iteration (max 2)

**Purpose:** Approve architectural approach before implementation investment.

**What's presented:**

- Architecture summary from specialists
- Security review (hardening findings)
- Threat model with prioritized mitigations
- Files that will be created/modified

**Human decides:**

- Is the approach correct?
- Are trade-offs acceptable?
- Are security priorities right?
- Ready to implement?

**Output:** Approved `triage.json` with disposition

### REVIEW Checkpoint

**When:** After implementation, before remediation

**Purpose:** Decide how to handle quality/security findings.

**What's presented:**

- Critical issues (bugs, vulnerabilities)
- Important suggestions (code quality)
- Test results and coverage
- Variant analysis results (if applicable)

**Human decides:**

- Fix now (blocks release)
- Fix later (tracked)
- Won't fix (documented)
- Need more information

**Output:** Updated `findings.json` with dispositions

### COMPLETION Checkpoint

**When:** After Summary phase

**Purpose:** Final acceptance of deliverable.

**What's presented:**

- Summary of what was built
- Test results
- Known issues and limitations
- Handoff notes

**Human decides:**

- Accept as complete
- Request revisions
- Document for future work

## State Tracking

**state.json approvals section:**

```json
{
  "group": "execution",
  "approvals": {
    "clarification": {
      "approved": true,
      "approved_at": "2026-01-22T10:30:00Z",
      "notes": "Answered all questions"
    },
    "design_iteration_1": {
      "approved": false,
      "feedback": "Need to reconsider caching strategy",
      "feedback_at": "2026-01-22T12:00:00Z"
    },
    "design_iteration_2": {
      "approved": true,
      "approved_at": "2026-01-22T14:00:00Z",
      "notes": "Approved revised approach"
    }
  }
}
```

## Intervention Triggers

Beyond scheduled checkpoints, humans can intervene when:

### Agent Requests Help

Agents should ask for help when:

- Unclear requirements discovered mid-phase
- Conflicting constraints identified
- Decision exceeds delegated authority
- Unexpected blockers encountered

**How to signal:**

```json
{
  "intervention_requested": true,
  "reason": "Discovered conflicting requirements",
  "context": "Auth design requires both stateless JWT and server-side session for compliance",
  "options": ["Option A: Hybrid approach", "Option B: Prioritize compliance"],
  "recommendation": "Option B because..."
}
```

### Human Initiates

Humans can intervene by:

- Responding during a checkpoint pause
- Sending a message during execution
- Using `/cancel-ralph` to stop loops
- Modifying state.json directly

## Design Iteration Limit

The DESIGN group allows **maximum 2 iterations**:

```
Iteration 1:
  - Parallel specialists design
  - Architect synthesizes
  - Security review
  - Present to human

If feedback requires changes:

Iteration 2:
  - Incorporate feedback
  - Re-run affected phases
  - Present to human again

If still not approved after iteration 2:
  - Escalate to human for direction
  - May need requirements revision
```

## Ralph Loop Checkpoints

For Ralph loops (Implementation, Remediation), checkpoints occur:

1. **Before loop starts** — Approve feature-list or findings
2. **During loop** — Human can intervene anytime
3. **After loop completes** — Review results before next phase
4. **On iteration limit** — If max-iterations reached, human decides

**Max iterations as safety:**

```
Implementation: --max-iterations 50
Remediation: --max-iterations 30 (and max 2 remediation cycles)
```

If limit reached without completion:

- Loop stops
- Human reviews progress
- Decides: continue with more iterations / change approach / pause

## Quality Gates

Each checkpoint can have quality gates that must pass:

**Design checkpoint gates:**

- [ ] All specialists provided input
- [ ] Security review completed
- [ ] Threat model enumerated
- [ ] Trade-offs documented

**Review checkpoint gates:**

- [ ] All tests passing
- [ ] Lint clean
- [ ] Typecheck clean
- [ ] Coverage above threshold
- [ ] No critical security findings

## Best Practices

### For Agents

1. **Surface uncertainty early** — Don't guess, ask
2. **Present options with trade-offs** — Enable informed decisions
3. **Be specific about needs** — "Need decision on X" not "What should I do?"
4. **Respect checkpoint decisions** — Don't revisit approved decisions without cause

### For Humans

1. **Review at checkpoints** — Don't approve blindly
2. **Provide context** — Business reasoning helps AI make better decisions
3. **Be decisive** — Delayed decisions block progress
4. **Trust the process** — Checkpoints exist for specific reasons

### For the Workflow

1. **Don't skip checkpoints** — Each serves a purpose
2. **Document decisions** — Future sessions need context
3. **Time-box reviews** — Balance thoroughness with progress
4. **Escalate blockers** — If stuck, surface to human immediately

## State Machine

```
                    ┌─────────────────────┐
                    │                     │
                    ▼                     │
┌─────────┐    ┌─────────┐    ┌─────────┐ │
│ PENDING │───►│ RUNNING │───►│ WAITING │─┘
└─────────┘    └─────────┘    │ APPROVAL│
                    │         └────┬────┘
                    │              │
                    │         ┌────▼────┐
                    │         │APPROVED │
                    │         └────┬────┘
                    │              │
                    ▼              ▼
              ┌─────────┐    ┌─────────┐
              │ BLOCKED │    │COMPLETE │
              └─────────┘    └─────────┘
```

- **PENDING** — Phase/group not yet started
- **RUNNING** — Phase/group in progress (agents working)
- **WAITING_APPROVAL** — Checkpoint reached, awaiting human
- **APPROVED** — Human approved, can proceed
- **COMPLETE** — Phase/group finished
- **BLOCKED** — Intervention needed, cannot proceed

## Human as Orchestrating Architect

The human is not a passive approver—they are the orchestrating architect:

| Role                          | What It Means                              |
| ----------------------------- | ------------------------------------------ |
| **Provides context**          | Business requirements AI cannot infer      |
| **Makes trade-offs**          | Chooses between valid competing approaches |
| **Approves direction**        | Ensures work aligns with actual needs      |
| **Intervenes on uncertainty** | Guides when AI encounters ambiguity        |
| **Accepts or rejects**        | Final authority on deliverables            |

The workflow is designed for human stewardship, not full autonomy. AI executes; humans steer.

## Summary

Human checkpoints transform Feature-Forge from an autonomous system into a collaborative one:

- **Clarification** ensures understanding before design
- **Design Triage** ensures good architecture before implementation
- **Review** ensures quality before shipping
- **Completion** ensures acceptance of deliverables

The goal is not to slow down development but to ensure AI-assisted development produces outcomes humans actually want.
