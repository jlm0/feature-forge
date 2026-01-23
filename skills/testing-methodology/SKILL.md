---
name: testing-methodology
description:
  This skill should be used when planning test strategies, selecting appropriate test types, identifying edge cases to
  cover, ensuring adequate test coverage, or designing tests that verify security properties.
---

# Testing Methodology

## Overview

Testing methodology provides a systematic approach to verification that ensures code correctness, prevents regressions,
and validates security properties. The methodology encompasses test type selection, coverage strategy, edge case
identification, and security testing. Testing is not an afterthought—it is an integral part of implementation that
shapes how code is designed and validated.

Effective testing requires intentionality. Strategic testing targets the areas most likely to contain defects, the
boundaries where behavior changes, and the security properties that must hold. A small number of well-designed tests
outperforms a large number of tests that exercise the same happy paths repeatedly.

## Test Type Selection

Different test types serve different purposes. Select the appropriate type based on what needs verification.

### Unit Tests

Unit tests verify individual functions, methods, or classes in isolation. They execute quickly, fail with precise error
localization, and enable thorough coverage of edge cases.

**When to use:** Testing pure functions, verifying algorithmic correctness, testing business logic independent of
infrastructure, validating data transformations.

**Characteristics:** No external dependencies, fast execution (milliseconds), precise failure messages, easy to write
many variations.

### Integration Tests

Integration tests verify that components work together correctly. They test the boundaries between modules, services,
and external systems.

**When to use:** Testing database operations, verifying API contracts, testing service interactions, validating external
integrations.

**Characteristics:** May involve real databases or network calls, slower execution, more complex setup, test realistic
interactions.

### End-to-End Tests

End-to-end tests verify complete user journeys through the system. They exercise the full stack from entry point to
persistence.

**When to use:** Verifying critical workflows, testing authentication flows, validating cross-cutting concerns,
confirming system behavior as users experience it.

**Characteristics:** Exercise complete system, slowest execution, most realistic but most brittle, highest confidence
when passing.

### Choosing the Right Type

Apply this decision framework: can the behavior be verified in isolation? Use unit tests. Does the behavior depend on
component integration? Use integration tests. Does the behavior span the full system? Use E2E tests.

## Test Pyramid

The test pyramid provides guidance on test distribution: many unit tests, some integration tests, few E2E tests.

### Many Unit Tests

Unit tests form the foundation because they execute quickly and localize failures precisely. Write unit tests for
algorithmic logic, data validation, transformations, business rules.

### Some Integration Tests

Integration tests verify component interactions. Write them for database operations, service communication, API
endpoints.

### Few E2E Tests

E2E tests are expensive to maintain. Write them for critical user workflows, authentication flows, transactions where
failure has significant impact.

### Inverting the Pyramid

For systems that are primarily integration (thin logic, thick integration), E2E tests may provide disproportionate
value. Optimize for confidence per test-dollar spent.

## E2E Over Unit Preference

In many practical contexts, E2E tests that verify actual user journeys provide more value than unit tests of isolated
components.

### Why E2E Tests Often Win

Unit tests do not verify that components are wired together correctly. An E2E test that exercises user registration
verifies: the endpoint exists, parsing works, validation applies, the database is reachable, the user is created
correctly, and the response format is correct.

### When to Prioritize E2E

Prioritize E2E tests when the risk is in integration rather than logic. Prioritize for authentication, data persistence,
cross-service communication, user-facing workflows.

### Practical Strategy

Write E2E tests for critical paths first. A system with one E2E test covering the purchase flow is better tested than a
system with 100 unit tests and no integration verification.

## Edge Case Identification

Edge cases are where bugs hide. Systematic identification produces tests that find defects before users do.

### Boundary Values

Test at input boundaries: minimum value, maximum value, just below minimum, just above maximum. For ages 18-65: test 17,
18, 65, 66, 0, negative numbers.

### Null and Empty

Test null, undefined, and empty values explicitly: null inputs, empty strings, empty arrays, missing optional
parameters. For list processing: test empty list, single-element list, list with null elements.

### Error Conditions

Test how the system handles failures: database unavailable, network timeout, malformed response, concurrent
modification. Inject failures explicitly using test doubles.

### Concurrency

Test concurrent access: simultaneous reads, simultaneous writes, read-write races. Use synchronization primitives in
tests to force orderings that expose race conditions.

## Coverage Strategy

Coverage metrics guide testing but do not guarantee quality.

### Line vs Branch vs Path Coverage

**Line coverage:** Which lines execute. Weakest metric. **Branch coverage:** Which decision branches execute. More
useful—catches both branches of conditionals. **Path coverage:** Which execution paths execute. Often impractical but
identifies valuable tests.

Focus on branch coverage as a practical target.

### Meaningful Coverage Targets

Coverage targets should reflect risk. 100% coverage of low-risk utility code is less valuable than 80% coverage of
security-critical authentication code.

Set higher targets for security-sensitive code, payment processing, core business logic. Accept lower coverage for
generated code and simple wrappers.

### Beyond Coverage

Coverage measures execution, not quality. Complement with mutation testing, assertion density review, and test quality
review.

## Security Testing

Security testing verifies that security controls work and that attacks fail.

### Negative Tests: Attack Should Fail

Negative tests verify attacks are prevented. Write negative tests for SQL injection, XSS, path traversal, authentication
bypass, authorization violations. Structure tests to attempt the attack and verify it fails.

### Authentication Testing

Test boundaries: valid credentials succeed, invalid fail with appropriate error, missing credentials fail, expired
credentials fail, brute force protection activates. Test session management: expiration, logout invalidation, concurrent
session handling.

### Authorization Testing

Test at every access point: users access own resources, users cannot access others' resources, admins access admin
functions, non-admins cannot. Test authorization failures explicitly.

### Input Validation

Test that validation enforces security boundaries: maximum length, forbidden characters, format requirements. Test
bypass attempts: encoded payloads, null bytes, unicode tricks.

## Test Organization

Well-organized tests are easier to maintain and understand.

### Naming Conventions

Test names should describe what is tested and expected outcome: `test_login_with_invalid_password_returns_401`,
`should_reject_duplicate_email_registration`. Avoid vague names like `test_login`.

### Grouping

Group related tests by feature, module, or scenario. Use test suites to create hierarchy: outer group for feature, inner
groups for scenarios, individual tests for conditions.

### Fixtures and Factories

Use fixtures for shared setup. Use factories for test data generation—create valid objects with minimal specification,
override specific fields per test.

### Setup and Teardown

Use setup/teardown for database transactions, mocking, state initialization. Each test should run independently—avoid
shared state or execution order dependencies.

## Regression Tests

When bugs are found, write tests that prevent recurrence.

### Test for Each Bug Fix

Before fixing, write a test that fails due to the bug. Fix the bug. Verify the test passes. Commit both together. This
ensures the bug is reproducible and the fix works.

### Capture the Original Failure

Use realistic data from the bug report. The test should fail if the fix is reverted.

### Minimal Reproduction

Make regression tests as simple as possible while still failing without the fix. Strip irrelevant setup.

## Output Format

Testing work produces test plans and test files.

### Test Plan

```markdown
## Test Plan for User Registration

### Unit Tests

- Email format validation: valid, invalid, edge cases
- Password strength: minimum length, required characters

### Integration Tests

- Database: successful creation, duplicate handling
- Email service: verification sent, failure handling

### E2E Tests

- Complete flow: submission, verification, first login
- Error flows: duplicate email, invalid input

### Security Tests

- SQL injection in all fields
- Rate limiting on endpoint
```

### Test Files

Implement tests following codebase conventions. Record coverage in progress tracking:

```json
{
  "feature": "FEAT-001",
  "test_coverage": {
    "unit": "complete",
    "integration": "complete",
    "e2e": "critical paths covered",
    "security": "auth tested",
    "gaps": "Performance deferred"
  }
}
```
