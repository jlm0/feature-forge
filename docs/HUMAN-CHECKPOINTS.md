# Human Checkpoints and Intervention

## Philosophy

Feature-Forge operates on a principle of **guided autonomy**, not full automation:

- AI handles routine execution within defined parameters
- Humans intervene at pivotal moments with uncertainty
- Quality emerges from human-AI collaboration, not replacement

_"Think of it as a relay race where you're passing the baton."_

## Why Human Checkpoints Matter

Without checkpoints:

- Agents may declare tasks complete without proper verification
- Design decisions are made without stakeholder input
- Security trade-offs are chosen without business context
- Errors compound through subsequent phases

With checkpoints:

- Course correction before significant investment
- Business context informs technical decisions
- Security requirements aligned with risk appetite
- Quality maintained through explicit verification

## Checkpoint Locations

| Checkpoint               | After Phase        | What's Reviewed             | Typical Decision            |
| ------------------------ | ------------------ | --------------------------- | --------------------------- |
| **Triage**               | Triage             | Security priorities for v1  | Approve / Adjust priorities |
| **Clarification**        | Clarification      | Resolved ambiguities        | Confirm understanding       |
| **Architecture**         | Architecture       | Design approach             | Approve / Request changes   |
| **Hardening**            | Hardening          | Security review of design   | Approve / Add requirements  |
| **Implementation Start** | Pre-Implementation | Ready to write code         | Approve start / Hold        |
| **Review**               | Review             | Quality & security findings | Ship / Fix now / Defer      |
| **Completion**           | Summary            | Final deliverable           | Accept / Revise             |

## Checkpoint Flow

```
Phase completes
      │
      ▼
Update state.json: phase=X, status=pending_approval
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
      ├── Approved ──► Update state.json approvals, proceed
      │
      ├── Feedback ──► Incorporate feedback, re-run phase
      │
      └── Questions ──► Answer questions, then re-present
```

## State Tracking for Checkpoints

**state.json approvals section:**

```json
{
  "phase": "implementation",
  "approvals": {
    "triage": {
      "approved": true,
      "approved_at": "2026-01-22T10:30:00Z",
      "notes": "Accepted all v1 requirements"
    },
    "architecture": {
      "approved": true,
      "approved_at": "2026-01-22T12:00:00Z",
      "notes": "Approved with minor change to error handling"
    },
    "hardening": {
      "approved": true,
      "approved_at": "2026-01-22T14:00:00Z",
      "notes": "Added rate limiting to requirements"
    },
    "implementation_start": {
      "approved": true,
      "approved_at": "2026-01-22T14:30:00Z"
    }
  }
}
```

## Checkpoint: Triage

**Purpose:** Ensure security priorities align with business needs and risk appetite.

**What's presented:**

- v1 security requirements (must have)
- Deferred items (can wait)
- Accepted risks (documented trade-offs)

**Human decides:**

- Are priorities correct?
- Should anything be promoted/demoted?
- Are accepted risks acceptable?

**Output:** Updated triage.json with approval

## Checkpoint: Architecture

**Purpose:** Ensure design approach is sound before implementation investment.

**What's presented:**

- Chosen architecture with rationale
- Alternative approaches considered
- Trade-offs (complexity, performance, security)
- Files that will be created/modified

**Human decides:**

- Is this the right approach?
- Are trade-offs acceptable?
- Any concerns about the design?

**Output:** Approved architecture.md

## Checkpoint: Hardening

**Purpose:** Ensure security concerns are addressed in design.

**What's presented:**

- Footguns identified in design
- Security recommendations
- Required mitigations for v1

**Human decides:**

- Are all critical issues addressed?
- Any additional security requirements?
- Acceptable to proceed with implementation?

**Output:** Approved hardening-review.md

## Checkpoint: Review

**Purpose:** Decide how to handle findings from quality/security review.

**What's presented:**

- Critical issues (bugs, security vulnerabilities)
- Important suggestions (code quality, patterns)
- Test results and coverage
- Variant analysis results (if applicable)

**Human decides:**

- Fix now (blocks release)
- Fix later (tracked for next sprint)
- Won't fix (documented decision)
- Need more information

**Output:** Updated findings.json with dispositions

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
  "options": ["Option A: Hybrid approach with...", "Option B: Prioritize compliance with..."],
  "recommendation": "Option B because..."
}
```

### Human Initiates

Humans can intervene by:

- Responding during a checkpoint pause
- Sending a message during execution
- Using `/cancel-ralph` to stop loops
- Modifying state.json directly

## Feedback Loop Patterns

### Quick Feedback (Same Session)

```
Agent: "I found X. Should I proceed with Y or Z?"
Human: "Proceed with Y"
Agent: Continues with Y approach
```

### Checkpoint Feedback (Phase Transition)

```
Agent: Completes Architecture phase, presents summary
Human: "Looks good, but also consider caching for the API"
Agent: Updates architecture.md, re-presents for approval
Human: "Approved"
Agent: Proceeds to Hardening
```

### Intervention Feedback (Mid-Phase)

```
Agent: Working on implementation
Human: "Stop. We need to change the API contract."
Agent: Pauses, updates discovery.md, may need to revisit architecture
```

## Loop Iteration Checkpoints

For Ralph loops (Implementation, Remediation), checkpoints occur:

1. **Before loop starts** — Approve feature-list or findings
2. **During loop** — Human can intervene anytime
3. **After loop completes** — Review results before next phase
4. **On iteration limit** — If max-iterations reached, human decides

**Max iterations as safety:**

```bash
/ralph-loop "..." --max-iterations 30
```

If limit reached without completion:

- Loop stops
- Human reviews progress
- Decides: continue with more iterations / change approach / pause

## Checkpoint Quality Gates

Each checkpoint can have quality gates that must pass:

**Architecture checkpoint gates:**

- [ ] Security requirements addressed
- [ ] Performance requirements considered
- [ ] Backward compatibility maintained
- [ ] Testing strategy defined

**Implementation checkpoint gates:**

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

- **PENDING** — Phase not yet started
- **RUNNING** — Phase in progress (agent working)
- **WAITING_APPROVAL** — Checkpoint reached, awaiting human
- **APPROVED** — Human approved, can proceed
- **COMPLETE** — Phase finished
- **BLOCKED** — Intervention needed, cannot proceed

## Summary

Human checkpoints transform Feature-Forge from an autonomous system into a collaborative one:

- **Scheduled checkpoints** ensure quality at phase transitions
- **Intervention triggers** allow course correction anytime
- **Feedback loops** incorporate human judgment into AI execution
- **Quality gates** enforce standards before proceeding

The goal is not to slow down development but to ensure that AI-assisted development produces outcomes humans actually
want.
