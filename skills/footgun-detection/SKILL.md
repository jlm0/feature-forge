---
name: footgun-detection
description:
  This skill should be used when reviewing API designs for misuse potential, evaluating configuration defaults, checking
  for dangerous patterns that enable security mistakes, or assessing whether code follows secure-by-default principles.
  Inspired by Trail of Bits sharp-edges methodology.
---

# Footgun Detection

## Overview

Identify error-prone APIs, dangerous configurations, and designs that enable security mistakes. This skill focuses on
design-level issues that make it easy for developers to create vulnerabilities—not implementation bugs themselves, but
the patterns that enable those bugs to occur.

A footgun is any design that allows users to shoot themselves in the foot. The goal is to find APIs where the obvious
usage is wrong, defaults that are insecure, and patterns that require expertise to use safely. Good security design
makes the right thing easy and the wrong thing hard.

This methodology applies during architecture review, before implementation begins. Catching footguns early prevents
entire classes of vulnerabilities from ever being written.

## Adversary Modeling

Think like a developer who will misuse this API or configuration. The adversary is not a malicious attacker—it is a
well-meaning developer under time pressure, copying code from Stack Overflow, or maintaining unfamiliar code at 2 AM
during an incident.

### Model Common Developer Mistakes

Consider how the API will actually be used:

- **Copy-paste coding**: Developers copy examples without understanding them. Consider what happens when the example
  code is used in a different context or with different data.
- **Time pressure**: Under deadline pressure, developers take shortcuts. Design for the shortcut path to be safe.
- **Incomplete documentation reading**: Most developers read only enough documentation to get something working.
  Critical security requirements buried in documentation will be missed.
- **Assumption of safety**: Developers assume libraries handle security correctly. When security requires explicit
  action, it will often be omitted.

### Anticipate Misuse Scenarios

For each API or configuration option, enumerate ways it could be misused:

- What happens when parameters are passed in the wrong order?
- What happens when required setup steps are skipped?
- What happens when the API is used in a context different from its intended purpose?
- What happens when error handling is omitted?

### Consider Maintenance Scenarios

Code changes over time. Consider how future modifications might introduce problems:

- A developer adds a new feature and disables a security check "temporarily"
- A configuration file is copied to a new environment without updating security settings
- A wrapper function is created that omits security-relevant parameters
- Refactoring consolidates code paths and loses context-specific security logic

## Edge Case Probing

Probe API boundaries with unexpected inputs to identify behaviors that could lead to security issues.

### Unexpected Input Categories

Test behavior with inputs the designer may not have considered:

**Empty and null values:**

- Empty strings where strings are expected
- Null or undefined values
- Empty arrays or objects
- Zero-length buffers

**Boundary values:**

- Zero where positive numbers are expected
- Negative numbers where unsigned is assumed
- Maximum integer values and overflow conditions
- Very large inputs that could cause resource exhaustion

**Type confusion:**

- Numeric strings where numbers are expected ("123" vs 123)
- Arrays where single values are expected
- Objects where primitives are expected
- Unicode strings with special characters, null bytes, or RTL markers

**Concurrent access:**

- Multiple simultaneous requests with the same identifier
- Race conditions between check and use
- Partial state during multi-step operations
- Interrupted operations leaving inconsistent state

### Examine Failure Modes

Determine what happens when things go wrong:

- Does the API fail open (allowing access) or fail closed (denying access)?
- Are errors logged with sufficient detail for debugging but without leaking sensitive data?
- Do error messages reveal internal implementation details?
- Is partial failure handled correctly, or can it leave the system in an inconsistent state?

### Identify Implicit Assumptions

Surface assumptions that are not enforced:

- Input validation assumed to happen elsewhere
- Ordering dependencies between operations
- Environmental requirements (file permissions, network access, memory limits)
- Authentication or authorization assumed to be checked by caller

## Default Security Assessment

Evaluate whether default configurations and behaviors are secure.

### Secure-by-Default Principle

For each configurable security setting, determine the default:

**Ask these questions:**

- Does the default configuration require changes to be secure?
- Is security enabled or disabled out of the box?
- Do examples and tutorials use secure configurations?
- Is the "quick start" path also the secure path?

**Common violations:**

- Debug mode enabled by default
- Development credentials included in examples
- Security features requiring explicit opt-in
- Permissive settings for ease of development

### Pit of Success Design

Evaluate whether the design guides developers toward secure usage:

**Characteristics of pit-of-success design:**

- The easiest way to use the API is also the secure way
- Insecure usage requires explicit, obvious steps
- Security is automatic unless deliberately disabled
- Developers fall into correctness rather than falling into errors

**Red flags:**

- Security requires additional setup beyond basic functionality
- Secure usage is more verbose or complex than insecure usage
- "Just make it work" coding produces insecure results
- Middleware or wrappers required for security

### Explicit Unsafe Opt-In

When unsafe behavior is necessary, require explicit acknowledgment:

**Good patterns:**

- `allowInsecure: true` parameter with documented risks
- Unsafe methods with "unsafe" in the name
- Compilation or runtime warnings for insecure configurations
- Separate APIs for trusted vs untrusted input

**Bad patterns:**

- Insecure behavior as default with secure opt-in
- Security settings in environment variables that might not be set
- Optional security validation that most code paths skip

### Documentation of Security Implications

Check that security-relevant options are clearly documented:

- Are security implications of configuration options explicit?
- Are recommended secure configurations provided?
- Are risks of disabling security features explained?
- Are security requirements for safe usage prominent, not buried?

## API Misuse Patterns

Identify design patterns that enable incorrect usage.

### Parameter Confusion

Evaluate parameter design for misuse potential:

**Order sensitivity:**

- Parameters of the same type that could be swapped
- Boolean parameters that are easy to confuse
- Source/destination confusion in copy operations

**Type coercion issues:**

- String parameters that accept numeric input ambiguously
- Boolean parameters that accept truthy values inconsistently
- Parameters that silently truncate or convert values

**Optional parameter dangers:**

- Security-critical parameters that are optional
- Default values that change behavior in non-obvious ways
- Overloaded functions where wrong overload might be called

### Missing Validation Reliance

Identify where validation is expected but not enforced:

- Input assumed to be pre-validated by callers
- Trust assumptions about data sources
- Length limits documented but not enforced
- Format requirements not checked programmatically

### Assumed Preconditions

Find preconditions that are assumed but not verified:

- Initialization expected before use
- Authentication assumed to have occurred
- Permissions assumed to be checked elsewhere
- Resource locks assumed to be held

### Silent vs Loud Failures

Evaluate failure handling design:

**Silent failures (dangerous):**

- Errors return empty or default values instead of failing
- Security checks that log but do not block
- Validation that warns but continues processing
- Operations that partially succeed without indication

**Loud failures (preferred):**

- Clear exceptions or errors on invalid input
- Blocking behavior on security violations
- Fail-fast on precondition violations
- All-or-nothing transactional semantics

## Configuration Footguns

Identify configuration patterns that enable security mistakes.

### Debug and Development Modes

Check for dangerous development-time settings:

- Debug mode that disables security checks
- Verbose error messages that leak information
- Development credentials or bypass mechanisms
- Logging that captures sensitive data

**Verify these cannot accidentally reach production:**

- Check default values in configuration templates
- Review environment detection logic
- Examine deployment configurations
- Test behavior when configuration is missing

### Permissive Defaults

Identify defaults that are too permissive:

- Network bindings to 0.0.0.0 instead of localhost
- CORS allowing all origins by default
- Authentication disabled or optional by default
- File permissions more open than necessary
- Rate limits disabled or set very high

### Security Features Disabled by Default

Find security mechanisms that require explicit enablement:

- CSRF protection requiring opt-in
- Input sanitization as optional middleware
- HTTPS enforcement requiring configuration
- Security headers not included by default
- Audit logging disabled unless configured

### Unclear Security Implications

Identify options whose security impact is not obvious:

- Settings that affect security but are not in a "security" section
- Performance options that trade off security
- Compatibility options that disable newer security features
- Options with security implications only in certain contexts

## Pattern Recognition

Recognize common footgun patterns across codebases.

### Injection Enablement Patterns

Identify designs that enable injection attacks:

- SQL query building with string concatenation available
- Command execution with user-controlled components
- Template rendering with raw output option
- Deserialization of untrusted data

**Look for:**

- "Raw" or "unsafe" method variants
- String interpolation in security-sensitive contexts
- Methods that bypass escaping or encoding

### Output Encoding Issues

Find patterns that enable output-related vulnerabilities:

- HTML output without automatic encoding
- JSON responses with improper content-type
- File downloads without content-disposition
- Error messages reflecting user input

### Authentication and Authorization Gaps

Identify authentication and authorization design issues:

- Endpoints without authentication by default
- Authorization checks at wrong granularity
- Role checks that use string comparison
- Session management with weak defaults

### Cryptographic Footguns

Find cryptography patterns prone to misuse:

- Encryption without authentication (CBC without HMAC)
- Random number generation from insecure sources
- Key derivation with insufficient iterations
- Hash functions used for password storage
- Custom cryptographic protocol implementations

### Cross-Origin Issues

Identify cross-origin security gaps:

- CORS configurations allowing all origins
- Missing or permissive CSP defaults
- Cookies without SameSite attribute
- Frames without X-Frame-Options

## Pit of Success Design Principles

Apply these principles when evaluating or suggesting improvements.

### Make the Right Thing Easy

The secure path should require less effort than the insecure path:

- Secure defaults that work without configuration
- Convenient APIs that happen to be safe
- Examples and documentation showing secure usage first
- Scaffolding and generators producing secure code

### Make the Wrong Thing Hard

Insecure usage should require deliberate effort:

- Unsafe operations require explicit opt-in
- Dangerous methods have obvious names (unsafe*, raw*, noValidation\_)
- Security bypass requires uncommon knowledge
- Insecure configurations generate warnings

### Fail Loudly, Not Silently

Errors should be obvious and impossible to ignore:

- Exceptions rather than error return codes
- Validation failures that halt processing
- Security violations that log at error level
- Missing configuration that prevents startup

### Require Explicit Unsafe Opt-In

When unsafe behavior is necessary, make the choice explicit:

- Named parameters for dangerous options
- Separate APIs for trusted vs untrusted contexts
- Warnings or confirmations for dangerous operations
- Documentation at the point of use, not just in reference docs

## Output Format

Produce a hardening-review.md file with findings categorized by priority.

### Document Structure

```markdown
---
phase: hardening
status: complete
issues_identified: [count]
severity_critical: [count]
severity_medium: [count]
severity_low: [count]
---

# Hardening Review

## Critical Issues

[Must fix before implementation—these footguns will likely result in vulnerabilities]

### Issue: [Descriptive Title]

**Pattern:** [Type of footgun: API misuse, insecure default, silent failure, etc.]

**Risk:** [What could go wrong when this is misused]

**Location:** [Where in the design this occurs]

**Recommendation:** [How to redesign for safety]

## Medium Priority

[Should fix—these footguns create unnecessary risk]

### Issue: [Descriptive Title]

**Pattern:** [Type of footgun]

**Risk:** [What could go wrong]

**Recommendation:** [How to improve]

## Low Priority

[Nice to have—these are minor improvements to developer experience]

### Issue: [Descriptive Title]

**Observation:** [What was noted]

**Suggestion:** [Optional improvement]

## Accepted Risks

[Documented decisions to accept certain footguns, with justification]

### [Risk Title]

**Description:** [What the risk is]

**Justification:** [Why this risk is acceptable]

**Mitigations:** [Any partial mitigations in place]

**Review Date:** [When to reconsider this decision]
```

### Issue Classification Guidelines

**Critical:** Footguns that will likely result in exploitable vulnerabilities if the API is used as designed. The
obvious usage path leads to insecurity.

**Medium:** Footguns that create unnecessary risk but require specific circumstances or combinations to become
exploitable. The secure path exists but is not the default.

**Low:** Design choices that are suboptimal for security but unlikely to directly cause vulnerabilities. Improvements to
developer experience and defense in depth.

**Accepted Risks:** Footguns that have been evaluated and deliberately accepted, with documented justification. Include
review dates to ensure these decisions are revisited.

## Principles

### Focus on Design, Not Bugs

This skill identifies design patterns that enable bugs, not the bugs themselves. A footgun is not "this function has a
SQL injection"—it is "this API makes SQL injection easy to introduce."

### Assume Good Intent, Bad Circumstances

The developer is not malicious. The developer is tired, rushed, unfamiliar with the codebase, or copying code without
full understanding. Design for this reality.

### Practicality Over Perfection

Not every footgun can be eliminated. Prioritize findings by likelihood of misuse and severity of consequences. Accept
that some risks may be justified for usability or compatibility.

### Actionable Recommendations

Each finding should include a concrete recommendation for improvement. "This is dangerous" is not helpful without "do
this instead."
