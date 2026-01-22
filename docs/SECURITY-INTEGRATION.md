# Security Integration

## Trail of Bits Skills

Feature-Forge integrates Trail of Bits security skills into the development workflow:

| Skill | Phase | Purpose |
|-------|-------|---------|
| **audit-context-building** | Audit | Deep context before vulnerability hunting |
| **sharp-edges** | Hardening | Identify footgun designs and insecure defaults |
| **variant-analysis** | Remediation | Find similar bugs after initial discovery |
| **fix-review** | Verification | Verify fixes address findings |

## Skill Details

### audit-context-building

**Purpose:** Build deep architectural context through ultra-granular code analysis BEFORE vulnerability hunting.

**When to use:**
- Deep comprehension needed before bug discovery
- Bottom-up understanding vs high-level guessing
- Reducing hallucinations and context loss
- Preparing for security audit or threat modeling

**What it does:**
- Line-by-line / block-by-block analysis
- First Principles, 5 Whys, 5 Hows at micro scale
- Maps insights → functions → modules → entire system
- Identifies invariants, assumptions, flows, reasoning hazards

**NOT for:**
- Vulnerability findings (context only)
- Fix recommendations (context only)
- Exploit reasoning (context only)
- Severity/impact rating (context only)

**Output includes:**
- Trust boundary mapping
- Attack surface identification
- Data flow analysis
- Assumption documentation
- Invariant tracking

### sharp-edges

**Purpose:** Identify error-prone APIs, dangerous configurations, and footgun designs that enable security mistakes.

**When to use:**
- Reviewing API designs
- Evaluating configuration schemas
- Assessing cryptographic library ergonomics
- Checking "secure by default" and "pit of success" principles

**What it identifies:**
- APIs that make misuse easy
- Dangerous default configurations
- Missing guardrails
- Footgun designs
- Non-obvious failure modes

**Key questions:**
- Is this misuse-resistant?
- Are defaults secure?
- Does it follow pit-of-success principles?
- Can users accidentally create vulnerabilities?

### variant-analysis

**Purpose:** Find similar vulnerabilities across codebases using pattern-based analysis after finding an initial issue.

**When to use:**
- After discovering a vulnerability (hunt variants)
- After fixing a bug (ensure no similar bugs)
- When a CVE affects patterns in your code
- During systematic security sweeps

**What it does:**
- Builds queries (CodeQL/Semgrep) from initial finding
- Searches for similar patterns across codebase
- Identifies related code paths
- Maps vulnerability patterns

**Triggers:**
- "I found an XSS here, find similar issues"
- "Search for other places where user input reaches SQL"
- "After fixing this bug, check for variants"

### fix-review

**Purpose:** Verify that git commits actually address security audit findings without introducing new bugs or regressions.

**When to use:**
- After implementing fixes for audit findings
- Before merging security-related PRs
- During post-audit remediation review

**What it does:**
- Compares fix implementation against vulnerability report
- Verifies the fix addresses root cause
- Checks for introduced regressions
- Validates completeness of remediation

**Triggers:**
- "Verify commits on branch fix/auth-bypass address TOB-003"
- "Check if last 3 commits remediate SQL injection finding"
- "Review the fix branch against the audit report"

## Integration into Feature-Forge Phases

### Audit Phase

```
1. Read exploration.md (understand codebase first)
2. Invoke audit-context-building methodology
3. Perform ultra-granular analysis:
   - Trust boundaries
   - Attack surfaces
   - Data flows
   - Invariants and assumptions
4. Write to audit-context.md
```

**Output structure:**
```markdown
---
phase: audit
status: complete
trust_boundaries: 5
attack_surfaces: 8
critical_assumptions: 3
---

# Security Context

## Trust Boundaries
[Detailed analysis]

## Attack Surfaces
[Entry points, exposed interfaces]

## Data Flows
[Sensitive data movement]

## Invariants & Assumptions
[What must remain true]
```

### Hardening Phase

```
1. Read architecture.md (understand design)
2. Read audit-context.md (security context)
3. Invoke sharp-edges methodology
4. Analyze for:
   - API footguns
   - Insecure defaults
   - Missing guardrails
   - Misuse potential
5. Write to hardening-review.md
```

**Output structure:**
```markdown
---
phase: hardening
status: complete
footguns_identified: 3
severity_high: 1
severity_medium: 2
---

# Hardening Review

## Critical Issues
[Must fix before implementation]

## Recommendations
[Should fix, prioritized]

## Accepted Risks
[Documented decisions to accept]
```

### Remediation Phase (Variant Hunt)

```
1. Read findings.json from Review phase
2. For issues that may have variants:
   - Invoke variant-analysis
   - Search for similar patterns
   - Add variants to findings.json
3. Prioritize all findings
4. Fix iteratively
```

### Verification (Fix Review)

```
1. After fixes implemented
2. Invoke fix-review methodology
3. Compare commits against original findings
4. Verify:
   - Root cause addressed
   - No new issues introduced
   - Complete remediation
5. Update findings.json with verification status
```

## STRIDE Threat Modeling

The Threat phase uses STRIDE methodology:

| Threat | Description | Questions |
|--------|-------------|-----------|
| **S**poofing | Impersonating something/someone | Can identity be faked? |
| **T**ampering | Modifying data or code | Can data be changed? |
| **R**epudiation | Denying actions taken | Can actions be traced? |
| **I**nformation Disclosure | Exposing protected information | Can data leak? |
| **D**enial of Service | Denying or degrading service | Can service be disrupted? |
| **E**levation of Privilege | Gaining unauthorized access | Can permissions be exceeded? |

**Threat model output:**
```markdown
---
phase: threat
status: complete
threats_identified: 12
mitigations_required: 8
---

# Threat Model

## Assets
[What we're protecting]

## Actors
[Who interacts with the system]

## Trust Boundaries
[Where trust changes]

## Threats by STRIDE

### Spoofing
- Threat: [description]
  - Likelihood: [H/M/L]
  - Impact: [H/M/L]
  - Mitigation: [required action]

### Tampering
...
```

## Triage Output

The Triage phase prioritizes security requirements:

```json
{
  "v1_requirements": [
    {
      "id": "SEC-001",
      "threat": "spoofing",
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

## Composing Skills

Feature-Forge skills **wrap** Trail of Bits skills, adding:

1. **Context file reading** — Read prior phase outputs
2. **Output file writing** — Write to Feature-Forge workspace
3. **State updates** — Update state.json and progress.json

**Example wrapper skill:**
```yaml
---
name: audit-context
description: "Build security context for Feature-Forge. Wraps ToB audit-context-building."
---

# Audit Context (Feature-Forge)

## Pre-Execution
1. Read .claude/feature-forge/exploration.md
2. Read .claude/feature-forge/discovery.md

## Execution
Apply Trail of Bits audit-context-building methodology:
- Ultra-granular analysis
- Trust boundaries, attack surfaces
- Invariants and assumptions

## Post-Execution
1. Write to .claude/feature-forge/audit-context.md
2. Update state.json: phase=audit, status=complete
3. Update progress.json with session notes
```

## Security Workflow Summary

```
AUDIT (audit-context-building)
    │
    ▼
THREAT (STRIDE methodology)
    │
    ▼
TRIAGE (prioritize for v1)
    │ [HUMAN CHECKPOINT]
    ▼
ARCHITECTURE (design)
    │
    ▼
HARDENING (sharp-edges)
    │ [HUMAN CHECKPOINT]
    ▼
IMPLEMENTATION
    │
    ▼
REVIEW
    │
    ├── issues found ──► VARIANTS (variant-analysis)
    │                        │
    │                        ▼
    │                   REMEDIATION
    │                        │
    │                        ▼
    │                   VERIFICATION (fix-review)
    │                        │
    └── clean ◄──────────────┘
    │
    ▼
SUMMARY
```
