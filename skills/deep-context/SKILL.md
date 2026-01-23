---
name: deep-context
description:
  This skill should be used when building deep architectural context before vulnerability hunting, performing
  ultra-granular code analysis, mapping trust boundaries and attack surfaces, or understanding security-critical code
  paths. Inspired by Trail of Bits audit-context-building methodology.
---

# Deep Context

## Overview

Deep context is an ultra-granular analysis methodology for building security context BEFORE finding vulnerabilities. The
goal is not to discover bugs or recommend fixes—it is to understand the system at a level of detail that makes
subsequent vulnerability hunting effective.

This skill produces a comprehensive map of trust boundaries, attack surfaces, data flows, invariants, and reasoning
hazards. Think of it as creating the terrain map before the battle. Without this context, vulnerability hunting becomes
a random walk through code. With it, analysis becomes targeted and efficient.

The methodology operates at the micro scale: line-by-line, block-by-block, function-by-function. Apply First Principles
thinking to decompose assumptions. Use the 5 Whys to understand decisions. Use the 5 Hows to trace implementation
details. Build understanding from the bottom up, then map insights across the entire system.

## Analysis Approach

### Line-by-Line and Block-by-Block Analysis

Examine code at the smallest meaningful unit. Read each line. Understand what it does. Ask why it exists. Consider what
could go wrong.

**For each code block:**

1. Identify the purpose—what is this block trying to accomplish?
2. Trace inputs—where does data come from?
3. Trace outputs—where does data go?
4. Note assumptions—what must be true for this to work correctly?
5. Consider failures—what happens when assumptions are violated?

Do not skim. Do not summarize. Read the actual code. Security vulnerabilities hide in the details that summaries omit.

### First Principles Thinking at Micro Scale

Decompose each component to its fundamental assumptions. Question everything that is not explicitly proven.

**Questions to ask:**

- What is this code actually doing, independent of comments or names?
- What inputs does this accept? Are all input sources identified?
- What outputs does this produce? Who consumes them?
- What state does this read? What state does this modify?
- What are the implicit contracts with callers and callees?

Avoid accepting abstractions at face value. A function named `sanitizeInput` may not actually sanitize. Verify behavior
through code, not through names.

### 5 Whys for Understanding Decisions

When encountering a design decision or unusual pattern, ask "why" repeatedly until reaching the root reason.

**Example chain:**

1. Why is there a delay before password comparison? — To prevent timing attacks.
2. Why does timing matter here? — Attackers can measure response times.
3. Why this implementation over constant-time comparison? — Legacy code.
4. Why has migration not occurred? — Low priority, no incidents.
5. Why is this considered low priority? — Risk assessment incomplete.

Each "why" reveals context that informs security analysis.

### 5 Hows for Implementation Details

When understanding how security controls work, trace the implementation path through all its mechanisms.

**Example chain:**

1. How does authentication work? — JWT tokens validated on each request.
2. How are JWTs validated? — Middleware checks signature and expiration.
3. How is the signing key managed? — Environment variable loaded at startup.
4. How is key rotation handled? — Manual process, requires restart.
5. How are revoked tokens handled? — No revocation mechanism exists.

Each "how" exposes implementation details where vulnerabilities may lurk.

## Trust Boundary Mapping

Trust boundaries are points where the level of trust changes. Data crossing these boundaries requires validation.
Privileges crossing these boundaries require authorization checks.

### Identify Where Trust Levels Change

Map every point where trust assumptions shift:

- **External to Internal**: User input entering the system, API requests, file uploads, webhooks
- **Internal to External**: Database queries, external API calls, files written, events published
- **Between Components**: Service-to-service calls, inter-process communication
- **Between Privilege Levels**: User to admin, guest to authenticated, service to infrastructure

### Map Data Crossing Boundaries

For each trust boundary, document:

- What data crosses the boundary?
- In which direction does it flow?
- What validation occurs at the crossing point?
- What happens if validation fails?

Data crossing trust boundaries without validation is a primary source of security vulnerabilities.

### Document Authentication and Authorization Points

Identify every authentication checkpoint: where identity is established, how credentials are verified, how sessions are
managed, where authentication can be bypassed.

Identify every authorization checkpoint: where permissions are checked, what permission model is used (RBAC, ABAC, ACL),
what the default permission is (deny or allow).

### Note Encryption Boundaries

Document where cryptographic protection applies:

- Data encrypted at rest: What fields? What algorithm? Where are keys stored?
- Data encrypted in transit: What protocols? Certificate validation?
- Cryptographic operations: Signing, hashing, MAC generation—where do these occur?

Note where encryption boundaries do not align with trust boundaries.

## Attack Surface Identification

The attack surface comprises all points where an attacker could interact with the system.

### Entry Points

Catalog every way data enters the system:

- **API Endpoints**: REST endpoints, GraphQL queries/mutations, WebSocket handlers, gRPC services
- **User Input**: Form submissions, query parameters, HTTP headers, cookies
- **File Uploads**: Upload endpoints, accepted types, size limits, processing pipelines
- **External Data Sources**: Third-party API responses, webhook payloads, message queue consumers

### External Interfaces

Document interfaces with external systems:

- Outbound API calls: What data is sent? What is received?
- Database connections: Parameterized or dynamic queries?
- File system access: What paths? What permissions?
- Network services: DNS, SMTP, cloud services

### Data Parsing Points

Identify where complex data formats are parsed:

- JSON/XML/YAML parsers
- Image/video/document processors
- Archive handlers (ZIP, TAR)
- Protocol parsers
- Custom binary formats

Parsing is inherently dangerous. Note which parsers are used and whether they are configured securely.

### Privilege Transitions

Map where privilege levels change:

- Elevation: User actions that gain higher privileges
- De-escalation: Actions that drop privileges
- Impersonation: Acting as another user or service
- Delegation: Passing credentials to other components

## Data Flow Analysis

Trace sensitive data through the entire system lifecycle.

### Trace Sensitive Data Through System

Identify categories of sensitive data:

- Authentication credentials: passwords, tokens, keys
- Personal information: names, emails, addresses
- Financial data: payment cards, bank accounts
- Business secrets: proprietary algorithms, customer lists

For each category, trace the complete lifecycle: creation, transport, processing, storage, retrieval, deletion.

### Identify Transformation Points

Document where data changes form:

- Encoding: Base64, URL encoding, HTML entities
- Serialization: JSON, Protocol Buffers
- Encryption/Hashing: At what points? With what algorithms?
- Sanitization: What characters or patterns are filtered?

Transformation points are where security controls are applied—and where they can fail.

### Map Storage Locations

Identify all places where data persists: databases, cache layers, search indices, log files, temporary files, browser
storage, session stores, message queues, backup systems.

Data often exists in more locations than intended. Sensitive data in logs is a common finding.

### Note Exposure Points

Document where data becomes visible: API responses, error messages, logs, debugging endpoints, client-side code, HTTP
headers.

## Invariant Documentation

Invariants are conditions that must always be true for the system to be secure.

### What Must Always Be True for Security

Document security invariants:

- "All database queries must use parameterized statements"
- "User passwords must never appear in logs"
- "Admin actions must be authenticated and authorized"
- "Rate limiting must be enforced on authentication endpoints"

Express invariants as absolute statements.

### Assumptions the Code Relies On

Document implicit assumptions:

- "Callers will validate input before passing it"
- "The database connection is always authenticated"
- "Environment variables contain valid configuration"
- "Clock skew between servers is less than 5 seconds"

Assumptions that are not enforced are potential vulnerability sources.

### Constraints That Must Hold

Document system constraints:

- "Session tokens must expire within 24 hours"
- "File uploads must not exceed 10MB"
- "API rate limits must not exceed 1000 requests per minute"

Constraint violations may enable attacks like resource exhaustion.

## Reasoning Hazards

Reasoning hazards are aspects of the system that could mislead analysis or create false confidence.

### Non-Obvious Security Implications

Note where security implications are not apparent from the code:

- A caching layer that returns stale authorization decisions
- A retry mechanism that amplifies denial-of-service attacks
- A logging statement that captures sensitive data in debug mode
- An optimization that introduces timing side channels

These are not vulnerabilities in themselves—they are areas requiring careful analysis.

### Subtle Edge Cases

Document edge cases that may be overlooked:

- Empty strings versus null versus missing parameters
- Unicode edge cases: homoglyphs, zero-width characters
- Numeric edge cases: overflow, underflow, floating-point precision
- Encoding edge cases: multi-byte characters split across boundaries

### Race Conditions

Identify potential race conditions:

- Check-then-act patterns without locking
- Shared mutable state accessed from multiple threads
- File operations without atomic guarantees
- Database operations outside transactions

### Time-of-Check-Time-of-Use Issues

Document TOCTOU vulnerabilities:

- Permission checks followed by file operations
- Authorization checks followed by data access
- Validation followed by processing

Any gap between checking a condition and acting on it is a potential TOCTOU vulnerability.

## What This Skill Does NOT Do

Maintain strict boundaries around the purpose of this skill.

### Does NOT Produce Vulnerability Findings

This skill does not identify specific vulnerabilities. It does not say "SQL injection at line 42." It says "Line 42
constructs a database query; the input comes from user request at line 15; validation occurs at line 20 but does not
cover this code path."

### Does NOT Make Fix Recommendations

This skill does not prescribe solutions. It documents the current implementation and its characteristics.

### Does NOT Assess Severity

This skill does not rate findings by severity or impact. It provides a comprehensive map without judgment about what
matters most.

### ONLY Builds Context for Subsequent Analysis

The sole output of this skill is context. The context enables:

- Targeted vulnerability hunting (threat-model, footgun-detection skills)
- Efficient code review (differential-review skill)
- Accurate fix verification (fix-verify skill)
- Systematic variant analysis (variant-hunt skill)

## Output Format

Produce a `security-context.md` file with the following structure:

```markdown
---
phase: security-context
status: complete
trust_boundaries: [count]
attack_surfaces: [count]
critical_assumptions: [count]
---

# Security Context

## Trust Boundaries

### [Boundary Name]

- **Transition**: [From trust level] -> [To trust level]
- **Location**: [File:line or component]
- **Data crossing**: [What data crosses]
- **Controls**: [What validation/authorization exists]

## Attack Surfaces

### Entry Points

[Catalog of API endpoints, user inputs, file uploads, external data sources]

### External Interfaces

[Catalog of outbound connections and their data]

### Data Parsing Points

[Catalog of parsers and their configurations]

### Privilege Transitions

[Catalog of elevation, de-escalation, impersonation, delegation points]

## Data Flows

### [Sensitive Data Category]

- **Sources**: [Where it enters]
- **Processing**: [How it transforms]
- **Storage**: [Where it persists]
- **Exposure**: [Where it may leak]

## Invariants and Assumptions

### Security Invariants

[List of conditions that must always be true]

### Code Assumptions

[List of implicit assumptions the code relies on]

### System Constraints

[List of boundaries that must hold]

## Reasoning Hazards

### Non-Obvious Implications

[List of areas where security impact is not apparent]

### Edge Cases

[List of subtle conditions requiring analysis]

### Concurrency Concerns

[List of race conditions and TOCTOU patterns]

## Open Questions

[Questions that arose during analysis but could not be answered]
```

Include specific file paths, line numbers, and code snippets where relevant. The output should enable another analyst to
understand the security-relevant aspects of the system without re-reading all the code.
