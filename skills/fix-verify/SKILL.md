---
name: fix-verify
description:
  This skill should be used when verifying that a security fix addresses the root cause, checking for regressions after
  remediation, validating that all variants of a vulnerability are covered, or performing differential analysis between
  vulnerable and fixed code.
---

# Fix Verification

## Overview

Verify that security fixes actually address the root cause of vulnerabilities without introducing regressions. This
methodology ensures remediation efforts are complete and effective rather than superficial patches that leave the
underlying weakness in place.

Fix verification is distinct from code review. Code review evaluates whether code is well-written; fix verification
evaluates whether a specific vulnerability has been eliminated. A fix that passes tests and looks correct may still be
incomplete—the vulnerability may have multiple manifestations, the fix may address symptoms rather than causes, or the
change may introduce new attack surface.

## Understand the Original Vulnerability

Before evaluating any fix, develop deep understanding of what allowed the vulnerability to exist.

### Read the Original Finding Thoroughly

Study the vulnerability report in detail: vulnerability type and classification (CWE, OWASP category), affected
component and line numbers, severity assessment, proof of concept if available, and attack prerequisites. Do not rely on
summary descriptions. Incomplete understanding leads to incomplete evaluation.

### Identify the Root Cause

Distinguish between the vulnerability's symptoms and its underlying cause:

- **Symptom**: SQL injection in the user search endpoint
- **Root cause**: User input concatenated into query strings without parameterization

The root cause answers: "What design flaw, missing control, or incorrect assumption allowed this vulnerability?" Common
categories include missing validation, incorrect trust assumptions, broken access control, cryptographic misuse, race
conditions, and unsafe deserialization.

### Understand the Exploit Path

Trace the full attack chain: entry point (how attacker data enters), propagation (how data flows), trigger (what
operation makes data dangerous), and impact (what exploitation achieves). Understanding the exploit path reveals where
effective fixes can be placed.

### Document What Allowed the Vulnerability

Record the specific conditions that enabled the vulnerability: which assumptions were violated, what input was not
validated, what check was missing. This documentation becomes the verification checklist.

## Analyze the Fix

Examine the proposed fix with the same rigor applied to vulnerability analysis.

### Read the Diff Carefully

Study every changed line: added code (what new logic?), removed code (what eliminated?), modified code (how did behavior
change?), unchanged context (is it appropriate?). Read changes in full context, not just diff hunks.

### Identify What Changed

Catalog concrete modifications: new validation (where, what inputs, what rules?), access control checks (what
conditions?), data flow changes, error handling modifications, dependency updates. Map each change to its security
purpose.

### Understand the Fix Approach

Characterize the remediation strategy: input validation, output encoding, access control, parameterization, sandboxing,
rate limiting, or cryptographic correction. Identify whether the approach matches the vulnerability class—SQL injection
fixes should use parameterization, not input filtering alone; XSS fixes should encode for output context, not strip
tags.

### Check if Fix Matches Root Cause

Evaluate alignment between the fix and identified root cause. A mismatch is a red flag—the fix may address a symptom
while leaving the underlying weakness intact.

## Root Cause Verification

Determine whether the fix addresses the fundamental problem or merely papers over a specific instance.

### Does the Fix Address WHY the Bug Existed?

Evaluate whether the fix eliminates the underlying design flaw. If validation was missing, is it now present? If access
control was bypassable, is logic now correct? A fix that only handles the reported case may leave the system vulnerable
to variations.

### Or Does It Only Address the Specific Instance?

Watch for narrow fixes: adds a check for one malicious pattern but not others, blocks the reported vector but not
alternatives, fixes one location while identical patterns exist elsewhere. Ask: "If an attacker knew about this fix,
could they trivially bypass it?"

### Could the Same Mistake Be Made Elsewhere?

Consider whether the vulnerability pattern exists in other locations—similar code in other endpoints, copy-paste
patterns, or whether future developers could recreate the vulnerability.

### Is the Fix at the Right Abstraction Level?

Evaluate placement: too low (fixing call sites when a helper should be secure by default), too high (application checks
when library should enforce safety), or appropriate (consistent protection without redundancy). Wrong abstraction
creates maintenance burden and bypass risk.

## Regression Detection

Verify that the fix does not break existing functionality or introduce new vulnerabilities.

### Does the Fix Break Existing Functionality?

Check for unintended changes: legitimate inputs now rejected, performance degradation, changed response formats, broken
integrations. Run the existing test suite and review failures.

### Are There Test Failures?

Analyze failures: do they indicate real regressions, incorrect assumptions about vulnerable behavior, or tests for the
vulnerability itself (which should now fail)? Failures require investigation, not automatic dismissal.

### Does the Fix Introduce New Attack Surface?

Evaluate whether the fix creates new concerns: new code paths with potential vulnerabilities, new dependencies with
security histories, configuration options that could be misconfigured, error messages that leak information, or logging
that captures sensitive data.

### Are Error Handling Paths Still Correct?

Verify error handling: appropriate responses for new validation, no information leakage about validation rules,
exceptions handled without exposing state, proper resource cleanup. Error handling is a common source of secondary
vulnerabilities.

## Variant Coverage

Verify that the fix addresses all manifestations of the vulnerability pattern.

### Were All Variants Addressed?

Check each variant: different input vectors, same pattern in different locations, similar vulnerabilities in related
functionality, edge cases and boundary conditions. Fixing only the reported variant leaves the system partially
vulnerable.

### Run Variant Analysis Queries on Fixed Code

Execute static analysis: run the same queries that found the original vulnerability, verify queries no longer match the
fixed location, review remaining matches for false negatives.

### Check Related Code Paths

Examine structurally similar code: other handlers in the same API, other methods in the same class, other
implementations of the same interface, code copied from the vulnerable location.

### Verify Similar Patterns Elsewhere

Search the codebase: grep for similar constructs, review other uses of dangerous APIs, check for the same missing
validation pattern. Document additional findings for separate remediation.

## Differential Analysis

Compare behavior before and after the fix to confirm the vulnerability is eliminated.

### Compare Before/After Behavior

Analyze how behavior changes: what inputs produce different outputs, what operations are now rejected, what error
messages changed. Changes should align with fix intent.

### Test Original Exploit Vector

If a proof of concept exists, test whether it still works. Execute the original attack, verify it is blocked, check that
security properties are enforced. This is the most direct confirmation.

### Verify the Exploit No Longer Works

Confirm exploitation is prevented: attack input rejected before reaching vulnerable operation, payload no longer
executes, impact mitigated. Document how the fix prevents the attack.

### Check Edge Cases Around the Fix

Test boundary conditions: inputs just below thresholds, boundary values, malformed inputs that might bypass parsing,
encoded payloads, TOCTOU variations. Attackers probe edge cases.

## Test Coverage Verification

Evaluate whether automated tests adequately exercise the fix.

### Is the Fix Covered by Tests?

Verify code execution: line coverage (new lines executed?), branch coverage (both branches tested?), path coverage
(relevant paths tested?). Uncovered code is unverified code.

### Do Tests Check the Security Property?

Evaluate test assertions: tests should verify the vulnerable condition cannot occur, malicious input is handled
correctly, security controls are enforced. Coverage alone is insufficient.

### Are Negative Tests Present?

Check for attack prevention tests: known malicious inputs, boundary values, encoded payloads, assertions that attacks
fail. Negative tests are as important as positive tests.

### Is Coverage Adequate?

Assess overall coverage: percentage of fix code covered, untested error paths, untested edge cases, integration
coverage. Document gaps and recommend additional tests.

## Incomplete Fix Patterns

Recognize common signs of incomplete fixes.

### Fix Only Addresses One Code Path

Check all entry points to the vulnerable operation, verify all callers pass through the fix, look for indirect calls
that bypass it, check for reflection or dynamic invocation.

### Validation Added but Can Be Bypassed

Watch for: input encoding that bypasses string matching, alternate representations, case sensitivity issues, Unicode
normalization bypass, double encoding.

### Error Handling Creates New Vulnerability

Watch for: verbose error messages revealing internals, error paths skipping security controls, exceptions causing
resource leaks, error conditions exposing race windows.

### Race Condition Not Fully Addressed

Watch for: check-then-use without atomicity, lock scope not covering critical sections, async operations introducing new
races, cleanup with race potential.

### Fix in Wrong Layer

Watch for: application-level fix for library vulnerability, instance-level fix for class-wide problem, single-file fix
for cross-cutting concern, band-aid instead of architectural change.

## Output Format

Record verification results in findings.json:

```json
{
  "id": "FIND-001",
  "status": "fixed",
  "fix_commit": "abc123",
  "verification": {
    "root_cause_addressed": true,
    "regression_check": "pass",
    "variants_checked": true,
    "test_coverage": "adequate",
    "verification_notes": "Fix adds parameterized queries. Original injection no longer possible. Checked 3 similar endpoints. Test added for malicious input."
  }
}
```

### Verification Fields

- **root_cause_addressed**: Boolean indicating whether fix addresses underlying cause, not just symptoms
- **regression_check**: "pass" if no regressions detected, "fail" with details in notes
- **variants_checked**: Boolean indicating whether related code was checked for same pattern
- **test_coverage**: "adequate" if well-tested, "inadequate" if gaps exist
- **verification_notes**: Explanation of reasoning and caveats

### Incomplete Fix Documentation

When incomplete, document remaining issues:

```json
{
  "status": "partially_fixed",
  "verification": {
    "root_cause_addressed": false,
    "verification_notes": "Validation added for POST only. GET still vulnerable.",
    "remaining_issues": ["GET /api/search vulnerable", "Missing attack tests"]
  }
}
```

Verification is not complete until all findings have clear disposition and remaining risks are documented.
