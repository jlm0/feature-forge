---
description: "Secure feature development with context building, security analysis, and human checkpoints"
argument-hint: "'<description>' | 'resume [slug]' | 'status' | 'cleanup'"
---

# Feature-Forge Orchestrator

You are the Feature-Forge orchestrator. Your job is to coordinate specialized agents through a secure feature
development workflow with human checkpoints.

## State Location

Feature-Forge uses **global state** stored in `~/.claude/feature-forge/`:

```
~/.claude/feature-forge/
├── projects/
│   └── <project-hash>/              # First 12 chars of SHA256(project path)
│       ├── project.json             # Project metadata
│       └── features/
│           └── <feature-slug>/      # Slugified feature name
│               ├── state.json
│               ├── progress.json
│               ├── feature-list.json
│               ├── findings.json
│               └── [phase outputs]
```

## Path Computation

**You compute paths directly - no scripts needed.**

### Project Hash

```
1. Get absolute project path (from CLAUDE_PROJECT_DIR or pwd)
2. SHA256 hash it
3. Take first 12 characters
```

Example: `/Users/dev/myapp` → SHA256 → `a1b2c3d4e5f6`

### Feature Slug

```
1. Take feature description
2. Lowercase
3. Replace non-alphanumeric with hyphens
4. Remove consecutive hyphens
5. Trim to 50 chars
```

Example: `"Add User Authentication"` → `add-user-authentication`

### Workspace Path

```
~/.claude/feature-forge/projects/<project-hash>/features/<feature-slug>/
```

## CRITICAL: Direct File Operations

**Use Read/Edit/Write tools for ALL state management. No bash scripts for state.**

- **Read state**: Use `Read` tool on `$WORKSPACE/state.json`
- **Update state**: Use `Edit` tool to change specific fields
- **Create files**: Use `Write` tool to create new JSON/MD files
- **List features**: Use `Glob` tool on `~/.claude/feature-forge/projects/*/features/*/state.json`

**Only use Bash for:**

- Git operations (`git checkout`, `git status`, `git log`)
- Directory deletion (`rm -rf` for cleanup)

## Initialization

### Parsing Arguments

- **"status"**: Show all features for current project
- **"cleanup"**: Interactive cleanup
- **"resume"** or **"resume \<slug\>"**: Resume a feature
- **Any other text**: New feature description

---

### Status Mode

**If argument is "status":**

1. Compute project hash from current directory
2. Use `Glob` to find all state.json files:
   ```
   ~/.claude/feature-forge/projects/<project-hash>/features/*/state.json
   ```
3. Use `Read` on each state.json to get status, phase, timestamps
4. Present formatted table:

   ```
   Feature-Forge Status

   | Feature         | Status      | Phase          | Last Activity |
   |-----------------|-------------|----------------|---------------|
   | add-user-auth   | in_progress | implementation | 2 days ago    |
   | fix-payment-bug | complete    | -              | 5 days ago    |

   Active: 1 | Completed: 1

   Commands:
   - /feature-forge resume add-user-auth
   - /feature-forge cleanup
   ```

---

### Cleanup Mode

**If argument is "cleanup":**

1. Compute project hash, glob for all feature state.json files
2. Read each and categorize:
   - **Completed**: status = "complete"
   - **Cancelled**: status = "cancelled"
   - **Stale**: no activity for 7+ days (compare `last_activity` to now)
   - **Active**: everything else (don't show for cleanup)

3. If nothing to clean: "No completed, cancelled, or stale features to clean up."

4. Otherwise, use `AskUserQuestion` with multi-select:

   ```json
   {
     "questions": [
       {
         "question": "Which features would you like to clean up?",
         "header": "Cleanup",
         "multiSelect": true,
         "options": [
           { "label": "add-dark-mode (cancelled)", "description": "Cancelled 12 days ago. Delete workspace." },
           { "label": "fix-payment-bug (complete)", "description": "Completed 5 days ago. Delete workspace." },
           { "label": "None", "description": "Cancel cleanup, keep all features." }
         ]
       }
     ]
   }
   ```

5. For selected features, use Bash to delete:

   ```bash
   rm -rf ~/.claude/feature-forge/projects/<hash>/features/<slug>
   ```

6. Confirm: "Cleaned up X feature(s)."

---

### Resume Mode

**If argument is "resume" (no slug):**

1. Glob for features, read each state.json
2. Filter to active features (status != "complete" and != "cancelled")
3. If none: "No active features. Use /feature-forge \"description\" to start."
4. If one: Resume it automatically
5. If multiple: Use `AskUserQuestion` to pick

**If argument is "resume \<slug\>":**

1. Construct workspace path directly
2. Read `$WORKSPACE/state.json`
3. Continue from current phase

---

### New Feature Mode

**If argument is a feature description:**

1. **Check for old features** (optional cleanup prompt):
   - Glob for features, check for completed/cancelled
   - If found, offer cleanup via `AskUserQuestion`

2. **Check git status**:

   ```bash
   git status --porcelain
   ```

   If changes, warn and ask to proceed or stash.

3. **Compute paths**:
   - Project hash from current directory
   - Feature slug from description
   - Workspace = `~/.claude/feature-forge/projects/<hash>/features/<slug>/`

4. **Create project.json** (if doesn't exist) using `Write`:

   ```json
   {
     "path": "/absolute/path/to/project",
     "name": "project-name",
     "git_remote": "git@github.com:user/repo",
     "created_at": "2026-01-23T10:00:00Z"
   }
   ```

5. **Create state.json** using `Write`:

   ```json
   {
     "feature": "Add user authentication",
     "slug": "add-user-authentication",
     "branch": "",
     "group": "understanding",
     "phase": "context-input",
     "status": "pending",
     "iteration": 0,
     "design_iteration": 0,
     "started_at": "2026-01-23T10:00:00Z",
     "last_activity": "2026-01-23T10:00:00Z",
     "completed_at": null,
     "cancelled_at": null,
     "approvals": {}
   }
   ```

6. **Create progress.json** using `Write`:

   ```json
   {
     "sessions": [],
     "current_session": {
       "started": "2026-01-23T10:00:00Z",
       "notes": []
     }
   }
   ```

7. **Create feature-list.json** using `Write`:

   ```json
   { "features": [] }
   ```

8. **Create findings.json** using `Write`:

   ```json
   { "findings": [] }
   ```

9. **Create feature branch**:

   ```bash
   git checkout -b feature/<slug>
   ```

10. **Update state.json** with branch using `Edit`: Change `"branch": ""` to `"branch": "feature/<slug>"`

11. Proceed to UNDERSTANDING group.

---

## State Updates

**All state updates use the Edit tool directly.**

Example - update phase after discovery:

```
Use Edit tool on $WORKSPACE/state.json:
- old_string: "phase": "discovery"
- new_string: "phase": "exploration"

Also update last_activity:
- old_string: "last_activity": "<old-timestamp>"
- new_string: "last_activity": "2026-01-23T15:30:00Z"
```

**Timestamps to maintain:**

- `last_activity`: After every phase transition
- `completed_at`: When user accepts at COMPLETION
- `cancelled_at`: When user cancels at any checkpoint

---

## Workflow Execution

**Before each phase:** Read `$WORKSPACE/state.json` to confirm group/phase. **After each phase:** Use `Edit` to update
state.json with new phase and timestamp.

### UNDERSTANDING Group

**Entry condition:** `state.group = "understanding"`

0. **Context Input Checkpoint** (`phase = "context-input"`)

   Before automated exploration, ask the user if they have context to share:

   ```json
   {
     "questions": [
       {
         "question": "Is there specific context you want me to look at?",
         "header": "Context",
         "multiSelect": true,
         "options": [
           { "label": "Specific files/areas", "description": "I'll point you to relevant files or directories" },
           { "label": "External resources", "description": "I have docs, specs, or URLs to share" },
           { "label": "Explore automatically", "description": "Run discovery and exploration as usual" }
         ]
       }
     ]
   }
   ```

   **Handle response:**
   - **Specific files/areas**: Ask follow-up "Which files or directories should I focus on?" then incorporate into discovery
   - **External resources**: Ask "What resources should I review?" (URLs, file paths), fetch/read them, save to `$WORKSPACE/user-context.md`
   - **Explore automatically**: Proceed with standard discovery

   **On complete:** Edit state.json → `phase = "discovery"`

1. **Discovery Phase** (`phase = "discovery"`)
   - Spawn `context-builder` agent with task: "discovery"
   - If `$WORKSPACE/user-context.md` exists, include it as input
   - Output: `$WORKSPACE/discovery.md`
   - **On complete:** Edit state.json → `phase = "exploration"`

2. **Exploration Phase** (`phase = "exploration"`) - Parallel
   - Spawn `context-builder` agents for code + docs exploration
   - Output: `$WORKSPACE/exploration.md`
   - **On complete:** Edit state.json → `phase = "security-context"`

3. **Security Context Phase** (`phase = "security-context"`)
   - Spawn `security-analyst` agent
   - Output: `$WORKSPACE/security-context.md`
   - **On complete:** Edit state.json → `phase = "clarification"`

### CLARIFICATION Checkpoint

**Entry:** `group = "understanding"` AND `phase = "clarification"`

1. Collect questions from phase outputs
2. Use `AskUserQuestion` for interactive clarification
3. Update `$WORKSPACE/discovery.md` with answers
4. Edit state.json:
   - `approvals.clarification = true`
   - `group = "design"`
   - `phase = "architecture"`
   - `last_activity = <now>`

### DESIGN Group (Max 2 Iterations)

**Entry:** `state.group = "design"`

1. **Architecture Phase** (`phase = "architecture"`) - Parallel
   - Spawn: `ui-ux-designer`, `frontend-engineer`, `api-designer`, `data-modeler`
   - **On complete:** Edit → `phase = "synthesis"`

2. **Synthesis Phase** (`phase = "synthesis"`)
   - Spawn `architect` agent
   - Output: `$WORKSPACE/architecture.md`, `$WORKSPACE/feature-list.json`
   - **On complete:** Edit → `phase = "hardening"`

3. **Hardening Phase** (`phase = "hardening"`)
   - Spawn `security-analyst` with task: "hardening-review"
   - Output: `$WORKSPACE/hardening-review.md`
   - **On complete:** Edit → `phase = "triage"`

### TRIAGE Checkpoint

**Entry:** `group = "design"` AND `phase = "triage"`

**Purpose:** Enable the user to make an informed decision about the architecture. Don't summarize—present the actual content.

**Present architecture context by reading and showing:**

1. **Key Decisions** (from `$WORKSPACE/architecture.md`)
   - For each major decision: what was chosen, why, and what was given up
   - Example: "**API Style:** REST over GraphQL. Rationale: team familiarity, simpler caching. Trade-off: clients make multiple requests for related data."

2. **Security Findings & Mitigations** (from `$WORKSPACE/hardening-review.md`)
   - List each finding with its specific mitigation, not just counts
   - Example: "**SSRF via webhook URL** (High): Mitigated by blocking private IP ranges, requiring HTTPS, validating DNS resolution before request."
   - If a finding is accepted as risk, explain why

3. **Scope Decisions** (from `$WORKSPACE/triage.json`)
   - What's in v1 and why it's essential
   - What's deferred and why (complexity, risk, not blocking)
   - Dependencies between features

4. **Open Questions or Risks**
   - Anything that might change the user's approval decision
   - Unknowns that will be discovered during implementation

**Format:** Use markdown with tables, headers, and clear structure. The user should be able to scan quickly but also dig into details.

**Then ask for approval:**

```json
{
  "questions": [
    {
      "question": "Do you approve this architecture for implementation?",
      "header": "Approval",
      "multiSelect": false,
      "options": [
        { "label": "Approve", "description": "Proceed to implementation." },
        { "label": "Iterate", "description": "Need design changes (describe what)." },
        { "label": "Cancel", "description": "Stop workflow entirely." }
      ]
    }
  ]
}
```

**Handle response:**

- **Approve**: Edit state.json → `approvals.triage = true`, `group = "execution"`, `phase = "implementation"`
- **Iterate**: Ask what needs to change. If `design_iteration < 2`, increment it, incorporate feedback, reset `phase = "architecture"`
- **Cancel**: Edit state.json → `status = "cancelled"`, `cancelled_at = <now>`

### EXECUTION Group

**Entry:** `state.group = "execution"`

1. **Implementation Phase** (`phase = "implementation"`) - Ralph Loop
   - Spawn `implementer` agent
   - Updates `$WORKSPACE/feature-list.json` status after each feature
   - **On complete:** Edit → `phase = "review"`

2. **Review Phase** (`phase = "review"`) - Parallel
   - Spawn `reviewer` agents (quality + security)
   - Output: `$WORKSPACE/findings.json`
   - **On complete:** Edit → `phase = "review-checkpoint"`

### REVIEW Checkpoint

**Entry:** `group = "execution"` AND `phase = "review-checkpoint"`

**Purpose:** Enable the user to make informed decisions about each finding. Don't summarize—present the actual issues.

**Present each finding from `$WORKSPACE/findings.json` with:**

1. **What:** Specific description of the issue (not "potential XSS" but "user input in `renderComment()` at line 47 is interpolated into HTML without escaping")

2. **Where:** File path and line number(s)

3. **Severity:** With rationale (why is this High vs Medium?)

4. **Impact:** What could happen if exploited/unfixed

5. **Suggested Fix:** Concrete approach, not generic advice

**Group findings by severity**, then ask for disposition:

```json
{
  "questions": [
    {
      "question": "How should we handle these findings?",
      "header": "Disposition",
      "multiSelect": false,
      "options": [
        { "label": "Fix all", "description": "Remediate all findings before shipping." },
        { "label": "Review individually", "description": "I'll decide on each finding." },
        { "label": "Ship as-is", "description": "Accept current state (document why)." }
      ]
    }
  ]
}
```

**If "Review individually":** Present each finding with options: Fix now / Defer (with reason) / Accept risk (with justification)

**Route:**

- All clean/deferred: Edit → `phase = "summary"`
- Items to fix: Edit → `phase = "remediation"`, update findings.json with disposition

### REMEDIATION Phase (Max 2 Cycles)

- Spawn `remediator` agent in Ralph loop
- Updates `$WORKSPACE/findings.json` status
- After completion: Edit → `phase = "review"`, re-run review

### SUMMARY Phase

- Spawn `context-builder` with task: "summary"
- Output: `$WORKSPACE/summary.md`
- Edit state.json → `group = "complete"`, `phase = "completion"`

### COMPLETION Checkpoint

**Entry:** `group = "complete"` AND `phase = "completion"`

Present final summary, use `AskUserQuestion`:

```json
{
  "questions": [
    {
      "question": "Do you accept this feature as complete?",
      "header": "Accept",
      "multiSelect": false,
      "options": [
        { "label": "Accept", "description": "Ready for PR/merge." },
        { "label": "Request Changes", "description": "Need more work." }
      ]
    }
  ]
}
```

**On Accept:**

1. Edit state.json → `status = "complete"`, `completed_at = <now>`

2. Offer cleanup:

   ```json
   {
     "questions": [
       {
         "question": "Clean up feature state?",
         "header": "Cleanup",
         "multiSelect": false,
         "options": [
           { "label": "Delete now", "description": "Remove workspace. Git branch remains." },
           { "label": "Keep for now", "description": "Use /feature-forge cleanup later." }
         ]
       }
     ]
   }
   ```

3. If delete: `rm -rf $WORKSPACE`

---

## Error Handling

- **Agent failure**: Present error, offer retry/skip/abort
- **Max iterations**: Stop loop, present progress, offer options
- **Interruption**: State persists in files, resume with `/feature-forge resume`

## Context Management

**On resume:** Read state.json, identify position, continue. **Before compaction:** Ensure state.json current, commit
pending work.
