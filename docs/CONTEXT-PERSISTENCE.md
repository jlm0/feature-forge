# Context Persistence and Memory

## The Core Problem

Claude Code sessions are fundamentally stateless. For complex tasks spanning hours or days:

- **Context rot** — As conversations grow, performance degrades
- **Information loss during compaction** — Auto-summarization loses critical nuances
- **Session handoff failures** — Next sessions must "guess" at prior state
- **Premature completion** — Agents may declare tasks complete without verification
- **One-shotting tendency** — Agents try to do too much, exhausting context mid-task

## The Key Insight

**Claude's memory is the file system, not the conversation.**

The conversation context is ephemeral and token-limited. Files persist indefinitely and can be read by any agent or
session.

## File-Based Memory Architecture

### What Goes Where

| Format                    | Use When                                             | Why                                    |
| ------------------------- | ---------------------------------------------------- | -------------------------------------- |
| **JSON**                  | State tracking, checklists, machine-readable data    | Less model drift, parseable by scripts |
| **Markdown**              | Explanatory prose, reasoning, human-readable context | Natural language, nuance, connections  |
| **YAML Frontmatter + MD** | Files needing both state AND context                 | Structured metadata + prose body       |

### Decision Framework

```
Does a script/hook need to parse it?
         │
    YES ─┴─ NO
     │      │
     ▼      ▼
Is it    Pure Markdown
purely   (human context)
state?
  │
YES ─┴─ NO
 │      │
 ▼      ▼
Pure   YAML Frontmatter
JSON   + Markdown body
```

### Examples

**JSON for state (protected, queryable):**

```json
{
  "phase": "implementation",
  "iteration": 3,
  "features": [
    { "id": "auth-001", "status": "complete", "tests_pass": true },
    { "id": "auth-002", "status": "in_progress", "tests_pass": false }
  ]
}
```

**Markdown for reasoning (nuanced, contextual):**

```markdown
## Why JWT with Refresh Token Rotation

We chose JWT over session cookies because:

1. The mobile app needs stateless auth
2. Microservices can validate without hitting a session store
3. Refresh rotation mitigates token theft risk

Trade-off: More complex token handling on client side.
```

**YAML frontmatter for both:**

```markdown
---
phase: architecture
status: approved
approved_by: human
approved_at: 2026-01-22T14:30:00Z
---

# Architecture Decision

## Chosen Approach

We're implementing a layered architecture...
```

## Baton Passing: The Core Pattern

Feature-Forge is designed around **baton passing** — agents and sessions hand off work via file-based state.

### Why Baton Passing Matters

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     WITHOUT BATON PASSING                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Session 1         Session 2         Session 3                          │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐                       │
│  │ Work...  │ ──?──│ What was │ ──?──│ Starting │                       │
│  │ Context  │      │ done?    │      │ over...  │                       │
│  │ compacts │      │ Guessing │      │          │                       │
│  └──────────┘      └──────────┘      └──────────┘                       │
│                                                                         │
│  Context lost at each transition                                        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                      WITH BATON PASSING                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Session 1         Session 2         Session 3                          │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐                       │
│  │ Work...  │      │ Read     │      │ Read     │                       │
│  │ Update   │ ────►│ state    │ ────►│ state    │                       │
│  │ state    │      │ Continue │      │ Continue │                       │
│  └──────────┘      └──────────┘      └──────────┘                       │
│       │                 │                 │                             │
│       ▼                 ▼                 ▼                             │
│  ┌─────────────────────────────────────────────┐                        │
│  │              FILE-BASED STATE               │                        │
│  │  state.json, progress.json, feature-list    │                        │
│  └─────────────────────────────────────────────┘                        │
│                                                                         │
│  Context persists through file system                                   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Baton Passing Points

| Transition                    | What's Passed                              | How                          |
| ----------------------------- | ------------------------------------------ | ---------------------------- |
| **Agent → Agent**             | Phase outputs (discoveries, architecture)  | Output files (discovery.md)  |
| **Phase → Phase**             | State, completion criteria                 | state.json updates           |
| **Session → Session**         | Progress, what's done, what's next         | progress.json, handoff notes |
| **Pre-compaction → Post**     | Critical state that must survive           | PreCompact hook triggers     |
| **Implementation iteration**  | Feature status, remaining work             | feature-list.json            |
| **Remediation iteration**     | Finding status, verification results       | findings.json                |

## Hooks in the Workflow

Hooks are event-driven automation that enables baton passing and Ralph loops.

### Critical Hook Events for Feature-Forge

| Hook Event      | When Fires                    | Feature-Forge Use                                |
| --------------- | ----------------------------- | ------------------------------------------------ |
| **SessionStart**| Session begins                | Load state.json, identify current phase          |
| **Stop**        | Agent wants to stop           | Ralph loops: check completion, feed back prompt  |
| **SubagentStop**| Subagent completes            | Process agent results, update state              |
| **PreCompact**  | Before context compaction     | **Critical:** Persist state before tokens cleared |
| **PreToolUse**  | Before tool executes          | Validate dangerous operations if needed          |

### PreCompact: The Session Continuity Hook

**This is critical for long-running workflows.**

When context is about to be compacted (auto-summarization), the PreCompact hook must:

1. Update state.json with current phase and progress
2. Update progress.json with session notes
3. Ensure feature-list.json or findings.json reflects current status
4. Commit any pending work to git

```
Context approaching limit
         │
         ▼
  PreCompact hook fires
         │
         ▼
  ┌────────────────────────────────┐
  │  1. Read current state         │
  │  2. Update JSON files          │
  │  3. Write handoff notes        │
  │  4. Commit if needed           │
  └────────────────────────────────┘
         │
         ▼
  Context compacts (summarized)
         │
         ▼
  New context reads state files
  and continues where it left off
```

### Stop Hook: The Ralph Loop Mechanism

The Stop hook intercepts session exit to enable iterative loops:

```
Claude attempts to stop
         │
         ▼
  Stop hook fires
         │
         ▼
  ┌────────────────────────────────┐
  │  Check completion criteria:    │
  │  - All features complete?      │
  │  - Tests passing?              │
  │  - Lint clean?                 │
  │  - Promise tag present?        │
  └────────────────────────────────┘
         │
    ┌────┴────┐
    │         │
Complete   Incomplete
    │         │
    ▼         ▼
 Allow     Block exit,
 exit      feed prompt back,
           increment iteration
```

**Stop hook output to continue loop:**

```json
{
  "decision": "block",
  "reason": "Continue implementing. Next feature: auth-003",
  "systemMessage": "Iteration 5/50 | Features: 2/8 complete"
}
```

### Hook Placement in Feature-Forge Workflow

```
SESSION START
      │
      ▼
┌─────────────────┐
│ SessionStart    │──► Load state.json, identify phase
│ hook            │    If resuming: read progress.json
└─────────────────┘
      │
      ▼
UNDERSTANDING / DESIGN phases (linear)
      │
      ▼
┌─────────────────┐
│ SubagentStop    │──► When agents complete, process results
│ hook            │    Update state with agent outputs
└─────────────────┘
      │
      ▼
IMPLEMENTATION (Ralph loop)
      │
      ├──► Work on one feature
      │
      ▼
┌─────────────────┐
│ Stop hook       │──► Check: all features complete?
│                 │    No: block exit, feed back prompt
│                 │    Yes: allow exit, proceed to Review
└─────────────────┘
      │
      ▼
REVIEW / REMEDIATION (Ralph loop)
      │
      ├──► Fix one finding
      │
      ▼
┌─────────────────┐
│ Stop hook       │──► Check: all findings resolved?
│                 │    No: block exit, continue fixes
│                 │    Yes: allow exit, proceed to Summary
└─────────────────┘
      │
      ▼
AT ANY POINT (approaching token limit)
      │
      ▼
┌─────────────────┐
│ PreCompact      │──► Update all state files
│ hook            │    Ensure nothing is lost
│                 │    New context can resume
└─────────────────┘
```

## The Ralph Wiggum Pattern

### Core Concept

Ralph is a stateless resampling approach: reset context each iteration, read progress from files.

```
while not complete:
    1. Start fresh context
    2. Read state from files
    3. Work on ONE thing
    4. Write progress to files
    5. Exit (or get intercepted by Stop hook)
    6. Loop restarts with fresh context
```

### How It Works in Claude Code

The Ralph Wiggum plugin uses a **Stop hook** to intercept session exit:

1. `/ralph-loop "task" --completion-promise "DONE"` starts the loop
2. Creates state file: `.claude/ralph-loop.local.md`
3. Claude works on the task
4. When Claude tries to exit, Stop hook fires
5. Hook checks: Did Claude output `<promise>DONE</promise>`?
6. If yes: Loop completes, state file removed
7. If no: Same prompt fed back, iteration counter incremented

### Key Innovations

- **Fresh context each iteration** — No context rot
- **File-based memory** — State persists through filesystem + git
- **Deterministic completion** — Clear success criteria
- **Iteration limits** — `--max-iterations 20` prevents infinite loops

### State File Structure

```markdown
---
active: true
iteration: 5
max_iterations: 50
completion_promise: "DONE"
started_at: "2026-01-22T10:00:00Z"
---

Build a REST API for todos. Requirements:

- CRUD operations
- Input validation
- Tests passing

Output <promise>DONE</promise> when complete.
```

## Progress Tracking Pattern

### Anthropic's Two-Agent Harness

**1. Initializer Agent** (first session only):

- Creates comprehensive feature list (100-200+ items)
- Sets up progress tracking files
- Makes initial git commit

**2. Coding Agent** (all subsequent sessions):

1. Read git logs and progress files
2. Read feature list, choose highest-priority incomplete item
3. Work on ONE feature only
4. Test thoroughly (e2e, not just unit tests)
5. Commit with descriptive message
6. Update progress file with clear handoff notes

### Progress File Structure

**progress.json (machine-readable):**

```json
{
  "current_session": {
    "started": "2026-01-22T15:30:00Z",
    "phase": "implementation",
    "completed_this_session": ["auth-001"],
    "in_progress": "auth-002",
    "notes": ["JWT validation working", "Starting refresh tokens"]
  },
  "history": [
    {
      "session": "2026-01-22T10:00:00Z",
      "summary": "Completed context building, architecture approved",
      "details_archived": "archive/session-001.json"
    }
  ]
}
```

**feature-list.json (implementation checklist):**

```json
{
  "features": [
    {
      "id": "auth-001",
      "category": "security",
      "description": "Implement JWT token validation",
      "priority": 1,
      "status": "complete",
      "verification": {
        "tests_pass": true,
        "e2e_verified": true
      }
    }
  ]
}
```

### Why JSON Over Markdown for Checklists

Per Anthropic's research: _"JSON format is preferred over Markdown as models are less likely to inappropriately modify
it."_

JSON provides:

- Structured data that scripts can parse
- Less tendency for models to "helpfully" edit
- Clear boolean states vs. ambiguous prose

## Memory Hierarchy

Claude Code uses hierarchical memory files:

| Level          | Location                     | Purpose                          |
| -------------- | ---------------------------- | -------------------------------- |
| **Enterprise** | `/etc/claude-code/CLAUDE.md` | Organization standards           |
| **User**       | `~/.claude/CLAUDE.md`        | Personal preferences             |
| **Project**    | `./CLAUDE.md`                | Team-shared context              |
| **Local**      | `./CLAUDE.local.md`          | Private preferences (gitignored) |
| **Workflow**   | `.claude/feature-forge/`     | Feature-Forge state              |

### CLAUDE.md Best Practices

**DO:**

- Keep it concise (<60 lines ideal)
- Include essential commands (build, test, lint)
- Document project-specific gotchas
- Use imports for modularity: `@docs/architecture.md`

**DON'T:**

- Auto-generate without review
- Include everything (use progressive disclosure)
- Duplicate what linters/formatters handle
- Let it grow unbounded

## Context Compaction and Continuity

When approaching token limits, context is compacted (auto-summarized). This is why PreCompact is critical.

### What Must Survive Compaction

| Must Persist                       | Where                        |
| ---------------------------------- | ---------------------------- |
| Current phase                      | state.json                   |
| Completion criteria                | state.json                   |
| Features done / remaining          | feature-list.json            |
| Findings done / remaining          | findings.json                |
| Session notes and context          | progress.json                |
| Uncommitted insights               | Commit or write to MD file   |

### PreCompact Checklist

Before context compacts:

- [ ] state.json reflects current phase and status
- [ ] progress.json has session notes
- [ ] feature-list.json or findings.json is current
- [ ] Any uncommitted code is committed
- [ ] Any important reasoning is in MD files

## Handoff Protocol

When transitioning between sessions or phases:

1. **Update state.json** — Current phase, completion criteria
2. **Update progress.json** — What was done, what's next, notes
3. **Commit code changes** — Git history = audit trail
4. **Archive if needed** — Move detailed logs to archive/

### Handoff Note Structure

```json
{
  "session_end": "2026-01-22T18:00:00Z",
  "phase_completed": "implementation",
  "what_was_done": ["Implemented auth-001: JWT validation", "Implemented auth-002: Refresh token rotation"],
  "what_remains": ["auth-003: Password reset flow", "Review phase pending"],
  "context_notes": [
    "Using 15-minute token expiry",
    "Refresh tokens stored in httpOnly cookies",
    "Rate limit set to 100 req/min"
  ],
  "blockers": [],
  "next_session_should": "Continue with auth-003, then move to Review phase"
}
```

## Key Principles

1. **Write everything down** — If it's not in a file, it will be forgotten
2. **One thing at a time** — Complete one feature before starting next
3. **JSON for state, MD for context** — Match format to purpose
4. **Commit frequently** — Git history survives token limits
5. **Clean handoffs** — Next iteration should understand immediately
6. **Archive old progress** — Keep active files lean
7. **Test e2e** — Browser automation catches what code review misses
8. **PreCompact is critical** — Always ensure state persists before compaction
9. **Hooks enable continuity** — SessionStart loads, PreCompact saves, Stop loops
