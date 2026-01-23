---
name: differential-review
description:
  This skill should be used when performing security-focused code review, classifying risk levels by file, adapting
  analysis depth to codebase size, calculating blast radius of changes, or generating concrete attack scenarios rather
  than generic findings.
---

# Differential Review

## Overview

Security-focused code review methodology that adapts analysis depth to change size and risk profile. Inspired by Trail
of Bits' differential review approach, this skill prioritizes findings that matter—concrete attack scenarios with
specific exploitation paths, not generic warnings about theoretical vulnerabilities.

Differential review operates on changes, not entire codebases. The question is not "is this code secure?" but "does this
change introduce or expose security vulnerabilities?" This scoping makes review tractable even for large changes while
ensuring coverage of what matters most.

The methodology emphasizes risk-based triage: classify files by risk level, adapt depth to codebase size, calculate
blast radius for high-risk changes, and generate findings with exploitation context. High-confidence findings only—false
positives erode trust and waste remediation effort.

## Risk Classification

Classify each changed file to focus analysis where it matters.

### HIGH Risk Files

Files handling security-critical functionality require deep analysis:

- **Authentication code**: Login handlers, session management, credential storage, token generation and validation,
  password reset flows, multi-factor authentication
- **Authorization code**: Permission checks, role validation, access control lists, policy enforcement, privilege
  escalation paths
- **Cryptographic operations**: Key generation, encryption/decryption, signature creation and verification, random
  number generation, certificate handling
- **Input parsing and deserialization**: JSON/XML/YAML parsers, protocol handlers, file format processors, user input
  sanitization
- **External data handling**: API request construction, response parsing, webhook processing, file upload handling
- **Database queries**: Query construction, ORM usage, stored procedure calls, data sanitization
- **Financial or PII processing**: Payment handling, personal data processing, sensitive data storage

### MEDIUM Risk Files

Files that could contribute to security issues but are not primary targets:

- **Business logic**: Rules that determine access or capability, workflow state machines, feature flags
- **Configuration handling**: Settings parsers, environment variable processing, feature toggles
- **Logging and monitoring**: What gets logged, where, what might be exposed
- **Error handling**: What information errors reveal, how failures are communicated
- **Data validation**: Input constraints, format validation, business rule validation
- **API contracts**: Request/response schemas, versioning, backward compatibility

### LOW Risk Files

Files unlikely to introduce security vulnerabilities directly:

- **UI components**: Presentation logic, styling, layout
- **Tests**: Test files themselves (unless they reveal implementation details)
- **Documentation**: README, comments, API docs
- **Build configuration**: Build scripts, CI configuration
- **Static assets**: Images, fonts, stylesheets

Classification is not permanent. A UI component that handles authentication state is HIGH risk. A test that demonstrates
a security bypass should trigger review of production code.

## Risk Factors

Indicators that increase risk classification.

### Direct Risk Indicators

Presence of these patterns elevates risk immediately:

- **Auth code changes**: Any modification to authentication or authorization logic
- **Crypto changes**: New or modified cryptographic operations, key handling, random generation
- **Input parsing changes**: New input formats, parser modifications, deserialization logic
- **Privilege changes**: Modifications to user roles, permissions, capability assignments
- **External data handling**: New external API integrations, webhook handlers, file processors

### Contextual Risk Indicators

These factors increase risk when present in changes:

- **New dependencies**: Third-party libraries introduce supply chain risk
- **Error handling modifications**: Changed error paths may expose information or skip controls
- **Configuration changes**: New settings may have insecure defaults
- **Database schema changes**: New fields may store sensitive data, migrations may expose data
- **API surface changes**: New endpoints expand attack surface

### Historical Risk Indicators

Consider file and component history:

- **Prior vulnerabilities**: Files with previous security issues warrant closer review
- **Complex code**: High cyclomatic complexity correlates with bug density
- **Rapid changes**: Frequently modified files accumulate inconsistencies
- **Multiple authors**: Knowledge fragmentation increases risk of conflicting assumptions

## Adaptive Depth

Scale analysis approach to change size.

### SMALL Codebase (<10 changed files)

Apply comprehensive analysis:

- Read every changed line in context
- Trace all data flows through changed code
- Verify all input validation and output encoding
- Check all error handling paths
- Review all test coverage for security properties
- Analyze all interactions with existing code

Time permits thoroughness. Use it.

### MEDIUM Codebase (10-100 changed files)

Apply risk-prioritized analysis:

1. Classify all files by risk level
2. Analyze HIGH risk files comprehensively (as SMALL)
3. Review MEDIUM risk files for obvious issues and interactions with HIGH risk code
4. Scan LOW risk files for misclassification (security-relevant code in unexpected places)
5. Focus cross-file analysis on security boundaries

Prioritize depth over breadth for security-critical code.

### LARGE Codebase (>100 changed files)

Apply strategic sampling:

1. Classify files by risk using automated heuristics where possible
2. Comprehensively analyze highest-risk files (top 10% by risk score)
3. Sample MEDIUM risk files, prioritizing those interacting with HIGH risk code
4. Rely on automated analysis for LOW risk files
5. Focus manual review on architectural changes, trust boundary modifications, and security control changes

Document coverage limitations. Large reviews cannot guarantee completeness—state what was reviewed and what was not.

## Blast Radius Calculation

Assess potential impact if the changed code is vulnerable.

### What Could an Attacker Achieve?

For each HIGH risk change, determine maximum impact:

- **Data exposure**: What sensitive data could be accessed? User credentials, PII, financial data, business secrets?
- **Privilege escalation**: Could an attacker gain elevated access? Admin capabilities, other user accounts, system
  access?
- **Service disruption**: Could the service be crashed or degraded? Denial of service, resource exhaustion?
- **Lateral movement**: Could compromise here enable attacks elsewhere? Internal services, connected systems, supply
  chain?

### Affected Scope

Map the boundaries of potential impact:

- **Users affected**: All users, specific roles, specific accounts
- **Data affected**: All data, specific categories, specific records
- **Services affected**: This service only, connected services, external systems
- **Time window**: Current data only, historical data, future data

### Exploitability Assessment

Consider practical exploitation factors:

- **Attacker prerequisites**: Authentication required, specific permissions, network position
- **Complexity**: Single step, multi-step, race condition timing
- **Visibility**: Exploitation leaves traces, exploitation is silent
- **Reliability**: Deterministic, probabilistic, single-attempt

High impact with low complexity and no authentication required is critical. High impact with high complexity and admin
access required is lower priority.

## Attack Scenario Generation

Produce concrete scenarios, not generic warnings.

### Avoid Generic Findings

Generic finding (useless): "This endpoint may be vulnerable to injection."

The finding says nothing about what type of injection, what the attack looks like, what the impact would be, or whether
exploitation is actually possible.

### Construct Concrete Scenarios

Concrete finding (actionable): "The `search` parameter at line 45 is concatenated into a SQL query at line 52 without
sanitization. An attacker can inject SQL via: `GET /api/users?search=x' OR '1'='1` to dump all user records including
email and hashed passwords."

Concrete scenarios include:

- **Entry point**: Exact parameter, header, or input that attacker controls
- **Vulnerability location**: Specific line where the security flaw exists
- **Exploitation mechanism**: How attacker input becomes dangerous
- **Payload example**: Actual malicious input that triggers the vulnerability
- **Impact demonstration**: What the attacker achieves

### Test the Scenario Mentally

Before reporting, verify the scenario is plausible:

- Does the attacker-controlled input actually reach the vulnerable code?
- Are there intervening controls that would block the attack?
- Is the payload syntactically valid for the context?
- Does the impact claim match what exploitation would actually achieve?

Incomplete scenarios create noise. Verify before reporting.

## Line-Level References

Precision enables verification and remediation.

### Specific Line Numbers

Reference exact locations: "Input received at `src/api/users.ts:34` flows to query construction at
`src/db/queries.ts:89` without validation."

Line numbers must be accurate. Inaccurate references waste time and erode trust.

### Specific Commits

For multi-commit reviews, identify which commit introduced the issue: "Vulnerability introduced in commit `a1b2c3d`
which removed input validation from the handler."

Commit-level attribution helps understand how vulnerabilities were introduced and prevents regression.

### Code Snippets

Include relevant code excerpts:

```typescript
// src/api/users.ts:34-36
const searchTerm = req.query.search; // User input, unvalidated
// ...
// src/db/queries.ts:89
const query = `SELECT * FROM users WHERE name LIKE '%${searchTerm}%'`; // Injection
```

Snippets should be minimal but complete—enough to understand the issue without navigating to the source.

## Severity Assessment

Rate findings by realistic impact and likelihood.

### Impact Categories

- **Critical**: Complete system compromise, mass data breach, arbitrary code execution
- **High**: Significant data exposure, privilege escalation to admin, service disruption
- **Medium**: Limited data exposure, privilege escalation within tier, degraded service
- **Low**: Minimal data exposure, information disclosure, minor policy violation

### Likelihood Factors

- **Exposure**: Is the vulnerable code reachable by attackers? Public endpoint vs. internal service.
- **Complexity**: How difficult is exploitation? Single request vs. multi-stage attack.
- **Authentication**: Required access level? Unauthenticated, any user, specific role.
- **Preconditions**: Required system state? Default configuration, specific settings.

### Severity Matrix

Combine impact and likelihood:

|                     | High Likelihood | Medium Likelihood | Low Likelihood |
| ------------------- | --------------- | ----------------- | -------------- |
| **Critical Impact** | Critical        | High              | Medium         |
| **High Impact**     | High            | Medium            | Medium         |
| **Medium Impact**   | Medium          | Medium            | Low            |
| **Low Impact**      | Low             | Low               | Informational  |

### Exploitability Considerations

Adjust severity based on practical factors:

- Public exploit code available: increase severity
- Exploitation requires insider knowledge: decrease severity
- Vulnerability is actively exploited in the wild: increase severity
- Exploit requires rare conditions: decrease severity

## False Positive Avoidance

Maintain high confidence in findings.

### Verify Before Reporting

For each potential finding, confirm:

- The code path is reachable
- Input validation is actually absent (not performed elsewhere)
- The vulnerability type applies to this context
- Exploitation would achieve the claimed impact

### Check for Mitigating Controls

Before reporting, search for:

- Input validation in calling code
- Output encoding at render time
- Parameterized queries despite string appearance
- WAF or framework-level protection
- Feature flags that disable the vulnerable code

### Acknowledge Uncertainty

When confidence is not high, state it: "This may be a false positive if the `sanitize()` function at line 20 handles the
injection vectors; that function was not included in the diff."

Do not suppress low-confidence findings—document the uncertainty and let humans decide.

### Prefer Precision Over Recall

Missing a real vulnerability is bad. Reporting many false positives is also bad—it wastes remediation time, erodes trust
in the review process, and causes real findings to be dismissed as noise.

When uncertain, investigate further before reporting. If investigation is not possible, report with explicit
uncertainty.

## Output Format

Record findings in structured format for tracking and remediation.

```json
{
  "findings": [
    {
      "id": "DR-001",
      "type": "sql_injection",
      "severity": "high",
      "confidence": "high",
      "description": "SQL injection via unsanitized search parameter",
      "location": {
        "file": "src/api/users.ts",
        "line_start": 34,
        "line_end": 36,
        "commit": "a1b2c3d"
      },
      "attack_scenario": {
        "entry_point": "GET /api/users?search=<payload>",
        "payload": "x' OR '1'='1",
        "exploitation": "Search parameter concatenated into SQL at src/db/queries.ts:89",
        "impact": "Dump all user records including emails and password hashes"
      },
      "blast_radius": {
        "data_affected": "All user records",
        "users_affected": "All users",
        "exploitability": "Unauthenticated, single request"
      },
      "recommendation": "Use parameterized queries or an ORM with proper escaping"
    }
  ],
  "review_metadata": {
    "files_reviewed": 45,
    "high_risk_files": 8,
    "medium_risk_files": 22,
    "low_risk_files": 15,
    "coverage_notes": "All HIGH risk files reviewed comprehensively. MEDIUM risk files sampled."
  }
}
```

### Required Finding Fields

- **id**: Unique identifier for tracking
- **type**: Vulnerability class (sql_injection, xss, auth_bypass, etc.)
- **severity**: Critical, High, Medium, Low, Informational
- **confidence**: High, Medium, Low
- **description**: One-sentence summary
- **location**: File, lines, commit
- **attack_scenario**: Concrete exploitation details
- **blast_radius**: Impact assessment
- **recommendation**: Remediation guidance

### Review Metadata

Document coverage and limitations:

- Files reviewed by category
- Time constraints if applicable
- Areas not covered and why
- Assumptions made during review

Transparency about coverage enables informed risk decisions.
