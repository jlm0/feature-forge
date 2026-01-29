# Security Integration

## Philosophy

Feature-Forge creates its own security skills **inspired by** Trail of Bits methodologies. We adapt their thinking
patterns into skills that frame how our agents approach security work.

**Key distinction:** We do NOT invoke Trail of Bits plugins. We create our own skills that embody similar methodologies.

## Security Skills

Feature-Forge includes five security-focused skills:

| Skill                 | Inspired By                | Purpose                                              |
| --------------------- | -------------------------- | ---------------------------------------------------- |
| **deep-context**      | ToB audit-context-building | Ultra-granular analysis before vulnerability hunting |
| **threat-model**      | STRIDE methodology         | Systematic threat enumeration                        |
| **footgun-detection** | ToB sharp-edges            | Identify dangerous defaults and API misuse           |
| **variant-hunt**      | ToB variant-analysis       | Find similar bugs after initial discovery            |
| **fix-verify**        | ToB fix-review             | Verify fixes address root cause                      |

## Skill Details

### deep-context

**Methodology:** Build deep architectural context through ultra-granular code analysis BEFORE vulnerability hunting.

**How to think:**

1. Analyze line-by-line / block-by-block
2. Apply First Principles, 5 Whys, 5 Hows at micro scale
3. Map insights → functions → modules → entire system
4. Identify invariants, assumptions, flows, reasoning hazards

**Output includes:**

- Trust boundary mapping
- Attack surface identification
- Data flow analysis
- Assumption documentation
- Invariant tracking

**NOT for:**

- Vulnerability findings (context only)
- Fix recommendations (context only)
- Exploit reasoning (context only)
- Severity/impact rating (context only)

### threat-model

**Methodology:** STRIDE-based systematic threat enumeration.

| Threat                     | Description                     | Key Question                 |
| -------------------------- | ------------------------------- | ---------------------------- |
| **S**poofing               | Impersonating something/someone | Can identity be faked?       |
| **T**ampering              | Modifying data or code          | Can data be changed?         |
| **R**epudiation            | Denying actions taken           | Can actions be traced?       |
| **I**nformation Disclosure | Exposing protected information  | Can data leak?               |
| **D**enial of Service      | Denying or degrading service    | Can service be disrupted?    |
| **E**levation of Privilege | Gaining unauthorized access     | Can permissions be exceeded? |

**How to think:**

1. Identify assets (what we're protecting)
2. Map actors (who interacts with the system)
3. Draw trust boundaries (where trust changes)
4. For each boundary crossing, apply STRIDE
5. Assess likelihood and impact
6. Propose mitigations

### footgun-detection

**Methodology:** Identify error-prone APIs, dangerous configurations, and designs that enable security mistakes.

**How to think:**

1. Model the adversary (what mistakes could be made?)
2. Probe edge cases (what happens with unexpected input?)
3. Check defaults (are they secure by default?)
4. Evaluate pit-of-success (is the safe path the easy path?)

**Key questions:**

- Is this API misuse-resistant?
- Are defaults secure?
- Can users accidentally create vulnerabilities?
- What happens if this is used wrong?

### variant-hunt

**Methodology:** Find similar vulnerabilities after discovering an initial issue.

**How to think:**

1. Start specific (understand the exact bug)
2. Generalize the pattern (what makes this vulnerable?)
3. Build queries (CodeQL, Semgrep, grep patterns)
4. Search codebase systematically
5. Stop at 50% false positive rate (diminishing returns)

**When to use:**

- After discovering a vulnerability (hunt variants)
- After fixing a bug (ensure no similar bugs)
- When a CVE affects patterns in your code
- During systematic security sweeps

### fix-verify

**Methodology:** Verify that fixes actually address security findings without introducing regressions.

**How to think:**

1. Understand the original vulnerability (root cause)
2. Analyze the fix (what changed?)
3. Verify root cause addressed (not just symptoms)
4. Check for regressions (did fix break anything?)
5. Look for incomplete fixes (all variants covered?)

**Differential analysis:**

- Compare before/after behavior
- Test original exploit vector
- Check related code paths
- Verify test coverage of fix

## Skills Applied to Phases

Security skills are used at multiple points in the workflow:

### UNDERSTANDING Group

**Security Context Phase:**

- security-analyst uses **deep-context** to build trust boundaries and attack surfaces
- Produces `security-context.md`

### DESIGN Group

**Architecture Phase:**

- All design specialists consider security in their domain
- security-analyst available for consultation

**Security Review Phase:**

- security-analyst uses **footgun-detection** to review architecture
- Identifies dangerous defaults, API misuse potential
- Produces `hardening-review.md`

**Triage Phase:**

- security-analyst uses **threat-model** to enumerate threats
- architect + security-analyst prioritize for v1
- Produces `triage.json`

### EXECUTION Group

**Review Phase:**

- reviewer (security) uses **deep-context** for thorough analysis
- Contributes to `findings.json`

**Remediation Phase:**

- remediator uses **variant-hunt** to find related issues
- remediator uses **fix-verify** to validate fixes
- Updates `findings.json` with verification status

## Security Context Output

The Security Context phase produces `security-context.md`:

```markdown
---
phase: security-context
status: complete
trust_boundaries: 5
attack_surfaces: 8
critical_assumptions: 3
---

# Security Context

## Trust Boundaries

[Where trust changes in the system]

## Attack Surfaces

[Entry points, exposed interfaces]

## Data Flows

[Sensitive data movement through the system]

## Invariants & Assumptions

[What must remain true for security]

## Reasoning Hazards

[Non-obvious security implications]
```

## Hardening Review Output

The Security Review phase produces `hardening-review.md`:

```markdown
---
phase: hardening
status: complete
issues_identified: 5
severity_high: 1
severity_medium: 3
severity_low: 1
---

# Hardening Review

## Critical Issues

[Must fix before implementation]

### Issue 1: [Title]

- **Risk:** [What could go wrong]
- **Recommendation:** [How to fix]

## Medium Priority

[Should fix, prioritized by risk]

## Low Priority

[Nice to have, can defer]

## Accepted Risks

[Documented decisions to accept certain risks]
```

## Triage Output

The Triage phase produces `triage.json`:

```json
{
  "v1_requirements": [
    {
      "id": "SEC-001",
      "threat_category": "spoofing",
      "description": "Implement JWT validation",
      "priority": 1,
      "source": "threat-model"
    }
  ],
  "deferred": [
    {
      "id": "SEC-005",
      "description": "Add rate limiting to all endpoints",
      "reason": "Low immediate risk, can add in v1.1"
    }
  ],
  "accepted_risks": [
    {
      "id": "RISK-001",
      "description": "Timing attacks on comparison",
      "justification": "Low likelihood, would require significant resources",
      "review_date": "2026-04-01"
    }
  ]
}
```

## Findings and Verification

Review produces `findings.json`, which is updated during remediation:

```json
{
  "findings": [
    {
      "id": "FIND-001",
      "type": "security",
      "severity": "high",
      "description": "SQL injection in user search",
      "location": "src/api/users.ts:42",
      "status": "fixed",
      "fix_commit": "abc123",
      "verification": {
        "root_cause_addressed": true,
        "regression_check": "pass",
        "variants_checked": true,
        "verified_by": "remediator",
        "verified_at": "2026-01-22T16:00:00Z"
      }
    }
  ]
}
```

## Security Workflow Summary

```
UNDERSTANDING
    │
    └── security-analyst (deep-context)
            │
            ▼
        security-context.md

DESIGN
    │
    ├── specialists (consider security in domain)
    │
    ├── security-analyst (footgun-detection)
    │       │
    │       ▼
    │   hardening-review.md
    │
    └── security-analyst + architect (threat-model)
            │
            ▼
        triage.json [HUMAN CHECKPOINT]

EXECUTION
    │
    ├── reviewer/security (deep-context)
    │       │
    │       ▼
    │   findings.json
    │
    └── remediator (variant-hunt, fix-verify)
            │
            ▼
        findings.json (with verification)
```

## Reusability of Security Skills

A key design principle: security skills are **reusable tools**, not one-time phases.

| Skill             | Used In                                     |
| ----------------- | ------------------------------------------- |
| deep-context      | Security Context, Review, any deep analysis |
| threat-model      | Triage, whenever threats need enumeration   |
| footgun-detection | Security Review, API design review          |
| variant-hunt      | Remediation, after any bug discovery        |
| fix-verify        | Remediation, after any fix implementation   |

This means the security-analyst agent can apply these skills whenever the orchestrator determines they're needed, not
just at predetermined phases.
