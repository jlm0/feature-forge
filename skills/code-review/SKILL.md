---
name: code-review
description:
  This skill should be used when evaluating code quality, checking for common bug patterns, verifying convention
  adherence, assessing readability and maintainability, or providing constructive feedback on implementations.
---

# Code Review

## Overview

Evaluate code quality systematically to identify bugs, enforce conventions, assess maintainability, and provide
actionable feedback. Code review is not about style preferences—it is about catching defects before they reach
production, ensuring consistent conventions, and improving code health over time.

Effective code review requires reading code carefully, understanding intent, and evaluating execution. Skim reviews
catch nothing. Thorough reviews find bugs, improve designs, and share knowledge across the team.

The goal is not to block code but to improve it. Findings should be constructive, specific, and prioritized. Not every
issue requires fixing before merge—some are suggestions, some are requirements. Make the distinction clear.

## Bug Pattern Recognition

Identify common defects that static analysis misses and humans often overlook.

### Off-by-One Errors

Check loop boundaries carefully: loops using `<=` versus `<`, array indices at boundary values, substring operations,
range calculations, fence-post errors in iteration counts.

Ask: What happens at the first iteration? What happens at the last? What if the collection is empty? What if it has
exactly one element?

### Null and Undefined Handling

Trace null propagation through code: function parameters that could be null, return values that might be undefined,
object properties accessed without existence checks, array elements accessed at indices that might not exist.

Look for defensive programming patterns: early returns for null inputs, null coalescing operators, optional chaining,
default parameter values. Absence of these patterns in code handling external data is a warning sign.

### Resource Leaks

Verify resources are released: file handles closed after use, database connections returned to pools, network sockets
cleaned up, event listeners removed, timers cancelled, subscriptions unsubscribed.

Check error paths especially—resources allocated before an exception may never be released. Look for try-finally
patterns, using statements, context managers, or RAII patterns depending on the language.

### Error State Handling

Examine what happens when operations fail: partial state changes that leave data inconsistent, failed operations that do
not clean up, error conditions that are caught but ignored, silent failures that mask problems.

Check that error handling is appropriate for the failure mode: transient errors should trigger retries with backoff,
permanent errors should fail clearly, partial failures should not corrupt state.

### Integer Overflow and Underflow

Review arithmetic operations: multiplication that could exceed type bounds, subtraction that could go negative when
unsigned is expected, additions in loops that could accumulate beyond limits, division operations and their behavior at
zero.

### Type Coercion Issues

In dynamically typed languages, check for: implicit conversions that lose precision, string concatenation where numbers
were expected, truthiness checks on values that should be explicitly compared, equality checks using wrong comparison
operators.

### Concurrency Defects

Identify race conditions: shared state modified without synchronization, check-then-act patterns without atomicity,
assumptions about execution order in async code, missing volatile or atomic qualifiers where needed.

## Convention Adherence

Verify code follows established project patterns and standards.

### Naming Conventions

Check naming consistency: classes use expected casing (PascalCase, snake_case), functions follow verb-noun patterns,
variables describe their purpose, constants are distinguished from variables, abbreviations are consistent throughout
codebase.

Names should reveal intent. A name like `data` or `temp` or `x` reveals nothing. Names should be
searchable—`userAccountManager` is findable, `uam` is not.

### Code Formatting

Verify formatting matches project standards: indentation style and depth, brace placement, line length limits, spacing
around operators and keywords, blank line usage for visual grouping.

Formatting inconsistency makes code harder to read and review. Automated formatters should be configured; manual review
catches what automation misses.

### File Organization

Check structural conventions: file naming patterns, directory organization, one class per file rules if applicable, test
file placement, separation of concerns across files.

Related code should be colocated. Unrelated code should be separated. Cross-cutting concerns should be isolated.

### Import and Dependency Organization

Review imports: grouped by type (standard library, external, internal), alphabetized within groups, no unused imports,
no circular dependencies, explicit imports over wildcard imports.

### Documentation Requirements

Check documentation presence where required: public API documentation, complex algorithm explanations, non-obvious
business logic rationale, deprecation notices, example usage for reusable components.

## Readability Assessment

Evaluate whether code can be understood by the next developer.

### Clear Naming

Names should communicate purpose without requiring context: function names describe what they do, parameter names
indicate expected values, return values are evident from function names, boolean names read naturally in conditionals.

Avoid encoding type information in names, Hungarian notation, or redundant context. Prefer `accounts` over `accountList`
or `accountArray`.

### Appropriate Comments

Comments should explain why, not what. Code explains what; comments explain why the code exists, why this approach was
chosen, why an apparent mistake is actually intentional.

Delete comments that merely restate the code. Add comments for non-obvious business rules, performance optimizations,
workarounds for external bugs, or regulatory requirements.

### Logical Flow

Code should read top to bottom with minimal mental backtracking: early returns for edge cases, happy path as the main
flow, related operations grouped together, abstraction levels consistent within functions.

Avoid deep nesting—extract to functions, use guard clauses, invert conditionals. More than three levels of nesting
signals an opportunity to refactor.

### Function Size and Complexity

Functions should do one thing: single responsibility, clear inputs and outputs, predictable side effects (ideally none),
testable in isolation. Long functions often hide multiple responsibilities.

Cyclomatic complexity indicates cognitive load. High complexity means high bug probability. Suggest extraction or
simplification for functions with many branches.

### Cognitive Load

Assess how much a reader must hold in memory: number of variables in scope, state mutations to track, conditional
branches to consider, implicit dependencies to remember.

Reduce load through: smaller functions, immutable data, explicit data flow, reduced scope of variables.

## Maintainability Evaluation

Assess whether code can be safely modified in the future.

### Single Responsibility

Each module, class, and function should have one reason to change. Multiple responsibilities indicate coupling that will
complicate future modifications.

Ask: If requirement X changes, how many files must be modified? The answer should be few.

### Coupling Assessment

Evaluate dependencies between components: tight coupling (direct knowledge of internals), loose coupling (communication
through interfaces), inappropriate coupling (unrelated components depending on each other).

High coupling makes changes risky—modifications ripple through the system. Favor dependency injection, interface-based
design, and event-driven communication.

### Cohesion Analysis

Verify related functionality is grouped together: methods that use the same fields belong together, methods that change
together belong together, methods that serve the same client belong together.

Low cohesion indicates a class doing too many things. Consider splitting into focused components.

### Testability Considerations

Assess whether code can be tested: dependencies injectable or mockable, side effects isolated, outputs verifiable, state
observable. Hard-to-test code is hard to maintain.

Look for: global state, static methods with side effects, new operators in constructors, hidden dependencies, untestable
private methods that should be extracted.

## Performance Concerns

Identify obvious inefficiencies without premature optimization.

### N+1 Query Patterns

Check database access in loops: fetching related records one at a time, lazy loading in iteration, missing joins or
eager loading. N+1 queries are the most common performance defect in data-driven applications.

### Unnecessary Allocations

Identify wasteful memory operations: allocations in tight loops, string concatenation in loops (use builders), creating
collections to iterate once, defensive copies where references suffice.

### Algorithmic Complexity

Review algorithm choices: O(n^2) where O(n log n) is available, linear search where hash lookup is appropriate, repeated
work that could be cached, unnecessary sorting.

### Premature Optimization Warning

Distinguish optimization from defects. An O(n^2) algorithm on a list of ten items is fine. Micro-optimizations that harm
readability are counterproductive. Flag only clear inefficiencies, not theoretical concerns.

## Error Handling Evaluation

Verify errors are handled appropriately throughout.

### Error Propagation

Check error flow: errors caught at appropriate levels, context added when re-throwing, stack traces preserved, error
types distinguished appropriately.

Avoid: catching and ignoring, catching overly broad exception types, losing error context through poor re-throwing.

### Meaningful Error Messages

Error messages should enable diagnosis: what operation failed, what state was involved, what action might resolve it.
"Error occurred" helps no one. "Failed to connect to database at host:port after 3 retries" enables action.

### Recovery Strategies

Evaluate recovery approaches: retry logic for transient failures, fallback values where appropriate, graceful
degradation, circuit breaker patterns for external services.

### User-Facing Error Handling

For user-visible errors: messages are understandable by non-technical users, sensitive information is not exposed,
actionable guidance is provided where possible, errors are logged for debugging while showing user-friendly messages.

## Constructive Feedback

Provide feedback that helps rather than harms.

### Be Specific and Actionable

Vague feedback is useless. "This could be better" says nothing. "Consider extracting the validation logic to a separate
function to enable unit testing" is actionable.

Reference specific lines. Explain the problem. Suggest a solution or alternative approach.

### Explain the Why

Developers learn from understanding rationale. "Use parameterized queries" is a command. "Use parameterized queries
because string concatenation enables SQL injection attacks" is education.

When blocking on an issue, explain the consequences of not addressing it.

### Offer Alternatives

When suggesting changes, provide options where multiple valid approaches exist. "Consider approach A for simplicity or
approach B for performance" respects developer judgment.

Avoid prescribing exact solutions when the goal is clear and implementation details are preference.

### Distinguish Severity Levels

Categorize findings: BLOCKING (must fix before merge), IMPORTANT (should fix, willing to discuss), SUGGESTION (take it
or leave it), QUESTION (seeking understanding, not requesting change).

Everything is not equally important. Treating minor issues as blocking erodes trust.

## Review Scope

Focus review effort appropriately.

### Focus on Changed Code

Review what was modified. Context is necessary to understand changes, but the review evaluates the diff, not the entire
file. Pre-existing issues in unchanged code are out of scope unless the change makes them worse.

### Understand Context for Changes

Read surrounding code to understand the change: what problem does this solve, how does it integrate, what assumptions
does it make about callers and callees. Changes that make sense in isolation may be wrong in context.

### Consider Change Impact

Evaluate blast radius: does this change affect public APIs, does it change behavior for existing callers, could it
affect other parts of the system, is it backward compatible where required.

## Output Format

Structure review findings for clarity and actionability:

```markdown
## Code Review Findings

### [BLOCKING] Null Pointer Risk

**Location**: `src/service/UserService.ts:45` **Issue**: `user.profile.settings` accessed without null checks; `profile`
may be undefined for new users. **Suggestion**: Add optional chaining: `user.profile?.settings ?? defaultSettings`

### [IMPORTANT] Missing Error Handling

**Location**: `src/api/handlers.ts:120-135` **Issue**: Database errors caught and logged but empty response returned;
client cannot distinguish error from empty result. **Suggestion**: Return appropriate HTTP error status (500 for server
error, 503 for transient failure).

### [SUGGESTION] Naming Clarity

**Location**: `src/utils/helpers.ts:30` **Issue**: Function `process` does not indicate what it processes or how.
**Suggestion**: Rename to `validateAndNormalizeEmail` or similar descriptive name.

### [QUESTION] Intentional Behavior?

**Location**: `src/auth/session.ts:88` **Question**: Session timeout set to 30 days—is this intentional for this
application type?
```

Include file paths, line numbers, and code snippets. Severity levels enable prioritization. Suggestions enable learning.
Questions prevent false positives.
