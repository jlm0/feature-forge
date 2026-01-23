---
name: implementation-discipline
description:
  This skill should be used when writing production code, following incremental development practices, adhering to
  codebase conventions, or maintaining focus on one feature at a time during implementation.
---

# Implementation Discipline

## Overview

Implementation discipline is a methodology for writing production code that maintains quality, consistency, and
progress. The approach centers on focused execution: complete one feature before starting another, make incremental
commits that preserve working state, and adhere strictly to existing codebase conventions. This discipline prevents
context pollution, reduces merge conflicts, enables clean rollbacks, and produces code that integrates naturally with
the existing system.

The goal is not just working code but maintainable code. Every implementation decision should consider the developer who
reads this code in six months. Clever solutions create maintenance burden; clear solutions create sustainable systems.

## One Feature at a Time

Focus is the foundation of disciplined implementation. Attempting multiple features simultaneously fragments attention,
increases error rates, and creates complex commits that are difficult to review and revert.

### Complete Before Moving On

Finish the current feature entirely before starting another. "Finished" means implemented, tested, documented where
required, and committed. Partial implementations scattered across the codebase create technical debt and cognitive load
for future work.

When tempted to start another feature while the current one is incomplete, stop. Either finish the current feature or
explicitly pause it with a documented state.

### Maintain Single-Purpose Commits

Each commit should address exactly one concern. A commit that implements a feature AND refactors unrelated code AND
fixes an old bug is three commits incorrectly combined. Separate concerns enable selective reversion, cleaner code
review, and accurate history.

### Track Progress Explicitly

Update progress tracking files after completing each feature. Record what was implemented, what tests were added, what
remains. Read the feature list before starting work. Mark features in-progress when starting and completed when done.

### Handle Blockers Deliberately

When blocked, do not silently switch to another feature. Document the blocker explicitly—what is blocking, what
information is needed, what alternatives exist. Blockers often indicate missing requirements or unclear specifications.

## Incremental Progress

Build features through small, verified steps. Large changes introduce large risks; small changes introduce small risks.

### Small Commits That Build on Each Other

Structure implementation as a series of small commits, each adding incremental value. Small commits provide natural
checkpoints. If a later change introduces problems, the last known-good state is recent.

### Maintain Working State

Never commit code that breaks the build or fails tests. The main branch should be deployable at any commit. Use feature
flags or conditional logic to hide incomplete functionality while still allowing intermediate commits.

### Verify Before Committing

Run tests before every commit. Check for linting errors, type errors, and other static analysis warnings. Address them
before committing rather than accumulating technical debt.

### Enable Easy Rollback

Structure changes to be reversible. A commit that can be cleanly reverted is a commit with clear boundaries. If
reverting requires manual surgery rather than a clean git revert, the commit is too complex.

## Convention Adherence

Match existing patterns in the codebase. Consistency reduces cognitive load for readers and maintainers.

### Match Existing Code Style

Study the existing codebase before writing new code. Observe formatting, indentation, brace placement, import ordering.
Match these patterns exactly. When the codebase has a formatter configuration, use it.

### Follow Naming Conventions

Use the same naming patterns as existing code: camelCase vs snake_case, prefixes for certain types, suffixes for certain
roles. Names should be descriptive and consistent with domain terminology used elsewhere in the codebase.

### Respect File Organization

Place new files where similar files already exist. When uncertain about placement, examine where similar existing
components reside and mirror that structure.

### Preserve Architecture Patterns

If the codebase uses dependency injection, use dependency injection. If it follows a repository pattern, implement
repositories. Do not introduce architectural novelty unless specifically required.

## Clean Code Principles

Write code that communicates intent clearly without requiring extensive documentation.

### Readability Over Cleverness

Choose the solution that is easiest to read over the solution that is most elegant or concise. Code is read far more
often than it is written. Optimize for the reader.

### Single Responsibility

Each function, class, and module should have one reason to change. Functions that do many things are hard to test, hard
to understand, and hard to modify safely.

### Meaningful Names

Names should describe what something is or does, not how it is implemented. Variable names like `data`, `info`, `temp`
convey no meaning. A good name eliminates the need for comments explaining what the code does.

### Minimize State

Prefer pure functions that derive outputs from inputs without side effects. Minimize mutable state and make state
changes explicit and localized.

## Error Handling

Handle errors explicitly and provide useful information for debugging.

### Explicit Error Paths

Do not ignore errors or swallow exceptions. Every operation that can fail should have explicit handling for the failure
case. Distinguish between errors that should propagate, errors that should be handled locally, and errors that should
terminate.

### Meaningful Error Messages

Error messages should identify what failed, why it failed, and ideally what can be done about it. Include context that
aids debugging—relevant identifiers, input values (sanitized if sensitive), operation being attempted.

### Recovery Strategies

Design for graceful degradation. Implement retry logic for transient failures. Provide fallback behavior where
appropriate.

### Fail Fast

Validate inputs at system boundaries and fail immediately if invalid. Early failures with clear error messages are
easier to debug than late failures with confusing state.

## Commit Discipline

Commits are the permanent record of development. Craft them deliberately.

### Atomic Commits

Each commit should be a complete, self-contained change. It should be possible to check out any commit and have a
working system. The goal is logical coherence, not arbitrary size limits.

### Descriptive Messages

Commit messages should explain why the change was made, not just what changed. Use the conventional commit format: type,
scope, and description.

### Logical Grouping

Group related changes together, separate unrelated changes. When a feature requires preparatory refactoring, commit the
refactoring first with its own message.

## Context Management

Work within the constraints of limited context by reading state files and preparing for session handoffs.

### Read State Files

Before starting work, read the current state files: `state.json` for workflow position, `progress.json` for
implementation history, `feature-list.json` for what to implement, `architecture.md` for design decisions. Context that
is not read is context that is lost.

### Update Progress

After completing work, update the relevant state files. Write progress updates as if another developer will read them to
continue the work.

### Prepare for Handoff

At the end of each work session, leave the codebase in a state that enables continuation. Commit all complete work.
Document incomplete work explicitly. Update feature tracking to reflect current state.

## Anti-Patterns to Avoid

Recognize and resist common implementation pitfalls.

### Over-Engineering

Do not build for requirements that do not exist. The simplest solution that meets requirements is usually correct. Add
complexity only when requirements demand it.

### Premature Optimization

Do not optimize before measuring. Implement clearly, measure actual performance, then optimize the measured bottlenecks.

### Scope Creep

Do not expand scope during implementation. If a better approach becomes apparent, document it and discuss before
implementing. If related improvements are noticed, create separate tasks.

### Gold Plating

Do not add unrequested features or polish. Deliver what was specified, no more. Propose improvements for future
iterations rather than implementing them unilaterally.

## Output Format

Implementation work produces two categories of output: code files and state updates.

### Code Files

Commit implemented features following the commit discipline guidelines. Each commit should be atomic, well-messaged, and
maintain working state.

### State Updates

Update `feature-list.json` to reflect implementation progress:

```json
{
  "features": [
    {
      "id": "FEAT-001",
      "name": "User authentication",
      "status": "complete",
      "commit": "abc1234",
      "notes": "JWT-based auth with refresh tokens"
    },
    {
      "id": "FEAT-002",
      "name": "Password reset flow",
      "status": "in_progress",
      "blockers": ["Email service configuration unclear"],
      "notes": "Token generation complete, email sending blocked"
    }
  ]
}
```

Update `progress.json` with session details for handoff.
