---
name: threat-model
description:
  This skill should be used when enumerating security threats systematically, applying STRIDE methodology, identifying
  assets and actors, mapping trust boundaries, or prioritizing security requirements. It teaches structured threat
  enumeration for feature design.
---

# Threat Model Skill

## Overview

Apply STRIDE-based systematic threat enumeration to identify security risks before implementation begins. This skill
provides a structured methodology for identifying assets, mapping actors, defining trust boundaries, and systematically
enumerating threats across those boundaries.

Threat modeling is not ad-hoc security brainstorming. It is a disciplined process that ensures comprehensive coverage by
applying a proven framework to every trust boundary crossing in a system.

## STRIDE Categories

STRIDE is a mnemonic for six categories of security threats. Apply each category systematically to ensure comprehensive
coverage.

| Threat                     | Description                                 | Key Question                           |
| -------------------------- | ------------------------------------------- | -------------------------------------- |
| **S**poofing               | Impersonating something or someone          | Can identity be faked?                 |
| **T**ampering              | Modifying data or code                      | Can data be changed without detection? |
| **R**epudiation            | Denying actions taken                       | Can actions be traced and proven?      |
| **I**nformation Disclosure | Exposing protected information              | Can data leak to unauthorized parties? |
| **D**enial of Service      | Denying or degrading service availability   | Can service be disrupted?              |
| **E**levation of Privilege | Gaining unauthorized access or capabilities | Can permissions be exceeded?           |

### Applying STRIDE

For each category, ask the key question in the context of every trust boundary crossing. A complete threat model
addresses all six categories—gaps in coverage indicate incomplete analysis.

**Spoofing threats** target identity and authentication. Consider:

- Authentication bypass mechanisms
- Token theft or forgery
- Session hijacking
- Credential stuffing and brute force
- Identity confusion between services

**Tampering threats** target data integrity. Consider:

- Parameter manipulation in requests
- Database record modification
- Configuration file tampering
- Man-in-the-middle attacks
- Cache poisoning

**Repudiation threats** target accountability. Consider:

- Missing or insufficient audit logs
- Log tampering or deletion
- Unsigned transactions
- Lack of non-repudiation mechanisms
- Anonymous actions that should be attributed

**Information Disclosure threats** target confidentiality. Consider:

- Verbose error messages
- Directory traversal
- SQL injection for data extraction
- Side-channel leaks (timing, caching)
- Exposure through logs or monitoring

**Denial of Service threats** target availability. Consider:

- Resource exhaustion (CPU, memory, disk, connections)
- Algorithmic complexity attacks
- Infinite loops or recursive calls
- External dependency failures
- Rate limiting gaps

**Elevation of Privilege threats** target authorization. Consider:

- Insecure direct object references
- Missing function-level access control
- Privilege escalation paths
- Role confusion
- Default or hardcoded credentials

## Asset Identification

Before enumerating threats, identify what requires protection. Assets fall into several categories.

### Data Assets

Data assets include all information the system processes, stores, or transmits.

**Identify and classify:**

- Personally Identifiable Information (PII): names, emails, addresses, phone numbers
- Authentication credentials: passwords, API keys, tokens, certificates
- Business-critical data: financial records, proprietary algorithms, trade secrets
- User-generated content: documents, messages, uploaded files
- Configuration and secrets: environment variables, connection strings, encryption keys

**For each data asset, determine:**

- Sensitivity level (public, internal, confidential, restricted)
- Regulatory requirements (GDPR, HIPAA, PCI-DSS)
- Impact if compromised (reputational, financial, legal, operational)

### System Assets

System assets include the infrastructure and services that process data.

**Identify:**

- Servers and compute resources
- Databases and data stores
- Message queues and event buses
- Caches and session stores
- Load balancers and proxies
- Monitoring and logging systems

### Intangible Assets

Intangible assets include non-physical resources of value.

**Consider:**

- Reputation and user trust
- Service availability commitments (SLAs)
- Intellectual property
- Competitive advantages
- Regulatory compliance status

## Actor Mapping

Identify all entities that interact with the system. Each actor type presents different threat profiles.

### Authenticated Users

Users who have established identity through authentication.

**Consider:**

- Regular users with standard permissions
- Premium or paying users with additional access
- Trial or limited users with restricted access
- Compromised accounts (valid credentials, malicious intent)

### Unauthenticated Users

Entities interacting without established identity.

**Consider:**

- Anonymous visitors browsing public content
- Pre-registration users
- Attackers probing for vulnerabilities
- Automated bots and scrapers

### Internal Actors

Entities within the organization or system boundary.

**Consider:**

- Administrators with elevated privileges
- Developers with deployment access
- Support staff with user data access
- Automated internal services
- Background job processors

### External Actors

Entities outside the organization interacting through integrations.

**Consider:**

- Third-party API consumers
- OAuth providers
- Payment processors
- External identity providers
- Partner integrations

### Adversaries

Explicitly model potential attackers.

**Consider:**

- External attackers (opportunistic, targeted)
- Malicious insiders (disgruntled employees, compromised accounts)
- Competitors seeking proprietary information
- Nation-state actors (for high-value targets)
- Automated attack infrastructure (botnets, scanners)

## Trust Boundary Analysis

Trust boundaries are points where the level of trust changes. Every trust boundary crossing is a potential attack
surface.

### Identifying Trust Boundaries

Trust boundaries exist where:

- Data moves between different security contexts
- Control passes from one entity to another
- Network zones change (public, DMZ, internal)
- Privilege levels differ

### Common Trust Boundary Types

**External to Internal**

- Internet to web server
- Mobile app to API
- Third-party webhook to internal service
- User browser to backend

**User to Admin**

- Standard user to administrative functions
- Self-service to support-assisted operations
- Public API to management API

**Service to Service**

- Frontend to backend
- API gateway to microservices
- Application to database
- Service to external API

**Process Boundaries**

- User input to application logic
- Application to operating system
- Container to host
- Sandboxed to privileged execution

### Documenting Trust Boundaries

For each trust boundary, document:

- Source context (who/what is requesting)
- Destination context (who/what is receiving)
- Data crossing the boundary
- Authentication mechanism (if any)
- Authorization checks applied
- Validation performed

## Threat Enumeration Process

Apply a systematic process to enumerate threats comprehensively.

### Step 1: List All Trust Boundary Crossings

Enumerate every point where data or control crosses a trust boundary. Create an explicit list—implicit boundaries often
harbor vulnerabilities.

**Document for each crossing:**

- Boundary identifier (for reference)
- Source and destination contexts
- Data elements crossing
- Protocols and mechanisms used

### Step 2: Apply Each STRIDE Category

For each trust boundary crossing, apply all six STRIDE categories. This creates a matrix of boundary crossings by threat
categories.

**Work through systematically:**

1. Select a trust boundary crossing
2. Ask each STRIDE key question
3. Document potential threats
4. Move to next boundary crossing
5. Repeat until all crossings covered

### Step 3: Ask the Key Questions

For each STRIDE category at each boundary, ask the key question in context.

**Example for API endpoint crossing:**

- **Spoofing:** Can a caller impersonate another user or service?
- **Tampering:** Can request data be modified in transit or at rest?
- **Repudiation:** Are API calls logged with sufficient detail to prove actions?
- **Information Disclosure:** Can error responses leak sensitive information?
- **Denial of Service:** Can excessive requests exhaust resources?
- **Elevation of Privilege:** Can a caller access resources beyond their permissions?

### Step 4: Document Potential Threats

For each identified threat, document:

- Threat identifier (for tracking)
- STRIDE category
- Trust boundary affected
- Description of the threat scenario
- Preconditions for exploitation
- Potential impact if exploited

### Step 5: Assess Likelihood and Impact

Evaluate each threat for prioritization.

**Likelihood factors:**

- Skill required to exploit
- Access required (network position, credentials)
- Existence of known attack patterns
- Detectability of attack attempts
- Motivation of potential attackers

**Impact factors:**

- Confidentiality: scope of data exposure
- Integrity: extent of data corruption
- Availability: duration and scope of disruption
- Financial: direct costs and liability
- Reputational: user trust and brand damage
- Compliance: regulatory penalties

**Risk calculation:** Risk = Likelihood x Impact

Prioritize threats by risk score for mitigation planning.

## Mitigation Mapping

Map identified threats to potential mitigations and prioritize implementation.

### Mitigation Strategies by STRIDE Category

**Spoofing mitigations:**

- Strong authentication (MFA, passwordless)
- Certificate validation
- API key rotation
- Session management controls

**Tampering mitigations:**

- Input validation and sanitization
- Cryptographic integrity checks (HMAC, signatures)
- Immutable audit logs
- Transport encryption (TLS)

**Repudiation mitigations:**

- Comprehensive audit logging
- Digital signatures
- Timestamps from trusted sources
- Log integrity protection

**Information Disclosure mitigations:**

- Encryption at rest and in transit
- Access control lists
- Data minimization
- Error message sanitization

**Denial of Service mitigations:**

- Rate limiting
- Input size limits
- Timeouts and circuit breakers
- Resource quotas
- CDN and DDoS protection

**Elevation of Privilege mitigations:**

- Principle of least privilege
- Role-based access control
- Input validation
- Secure defaults
- Privilege separation

### Prioritization Framework

Prioritize mitigations based on:

- Risk score of addressed threats (higher risk = higher priority)
- Implementation effort (quick wins vs. major refactors)
- Coverage (mitigations addressing multiple threats)
- Dependencies (some mitigations enable others)

### v1 Requirements vs. Deferrals

Classify mitigations into:

**v1 Requirements:** Must implement before release

- High-risk threats with feasible mitigations
- Compliance requirements
- Threats affecting core functionality

**Deferred:** Can implement in future versions

- Lower-risk threats
- Mitigations requiring significant infrastructure changes
- Defense-in-depth measures beyond minimum viable security

**Accepted Risks:** Documented decisions not to mitigate

- Very low likelihood threats
- Disproportionate mitigation cost
- Must include review date for reassessment

## Output Format

Threat modeling produces two primary outputs: a narrative document and a structured triage file.

### threat-model.md

```markdown
---
phase: threat-model
status: complete
trust_boundaries: [count]
threats_identified: [count]
high_risk: [count]
medium_risk: [count]
low_risk: [count]
---

# Threat Model

## Assets

### Data Assets

[Classified list of data assets with sensitivity levels]

### System Assets

[Infrastructure and services]

## Actors

[Enumerated actors by category with threat profiles]

## Trust Boundaries

### [Boundary ID]: [Name]

- **Source:** [context]
- **Destination:** [context]
- **Data Crossing:** [elements]
- **Controls:** [authentication, authorization, validation]

[Repeat for each boundary]

## Threats

### [THREAT-001]: [Title]

- **Category:** [STRIDE category]
- **Boundary:** [Boundary ID]
- **Description:** [Scenario description]
- **Likelihood:** [High/Medium/Low]
- **Impact:** [High/Medium/Low]
- **Risk:** [High/Medium/Low]
- **Mitigation:** [Proposed mitigation]

[Repeat for each threat]

## Mitigation Summary

### v1 Requirements

[Mitigations that must be implemented]

### Deferred

[Mitigations for future versions]

### Accepted Risks

[Documented risk acceptance decisions with review dates]
```

### triage.json

```json
{
  "v1_requirements": [
    {
      "id": "SEC-001",
      "threat_category": "spoofing",
      "description": "Implement JWT validation",
      "threats_addressed": ["THREAT-001", "THREAT-005"],
      "priority": 1,
      "source": "threat-model"
    }
  ],
  "deferred": [
    {
      "id": "SEC-010",
      "description": "Add rate limiting to all endpoints",
      "threats_addressed": ["THREAT-012"],
      "reason": "Low immediate risk, infrastructure changes required",
      "target_version": "v1.1"
    }
  ],
  "accepted_risks": [
    {
      "id": "RISK-001",
      "threat_id": "THREAT-015",
      "description": "Timing attacks on comparison operations",
      "justification": "Requires significant resources to exploit, low impact",
      "review_date": "2026-04-01"
    }
  ]
}
```

## Integration with Workflow

The threat-model skill integrates with Feature-Forge at specific phases.

### Triage Phase (Primary)

During Triage, apply comprehensive threat modeling to the proposed architecture:

1. Identify all assets in the feature design
2. Map actors who will interact with the feature
3. Document trust boundaries from the architecture
4. Enumerate threats systematically using STRIDE
5. Produce prioritized triage output

### Security Context Phase

Use threat modeling principles to inform the security context:

- Identify critical assets early
- Note potential trust boundaries
- Flag areas requiring deeper analysis

### Security Review Phase

Apply threat modeling to validate architecture decisions:

- Verify identified boundaries are properly protected
- Check for missing mitigations
- Identify new threats introduced by design choices

## Principles

### Be Systematic, Not Ad-Hoc

Follow the enumeration process completely. Ad-hoc threat identification misses categories and boundaries. The value of
STRIDE comes from comprehensive application, not selective use.

### Document Everything

Record all identified threats, even those deemed low risk. Threat models are living documents—risk assessments change as
the system evolves and threat landscape shifts.

### Prioritize by Risk

Not all threats require immediate mitigation. Focus effort on high-risk threats while documenting lower-risk items for
future consideration. Attempting to mitigate everything equally leads to incomplete coverage of critical areas.

### Assume Breach Mentality

When modeling threats, assume attackers will find vulnerabilities. Design defense in depth—multiple layers of protection
so a single failure does not lead to complete compromise.

### Update Iteratively

Threat models require updates as features evolve. Revisit the model when:

- New functionality is added
- Architecture changes
- New threat intelligence emerges
- Security incidents occur
