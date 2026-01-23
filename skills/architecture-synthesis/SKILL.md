---
name: architecture-synthesis
description:
  This skill should be used when combining inputs from multiple design specialists into a cohesive architecture
  blueprint, analyzing trade-offs between approaches, resolving conflicts between design proposals, or creating the
  final technical specification for implementation.
---

# Architecture Synthesis Skill

## Overview

Architecture synthesis is the methodology for combining inputs from multiple design specialists into a unified,
implementable blueprint. When UI/UX designers, frontend engineers, API designers, data modelers, and security analysts
each contribute their domain expertise, the architect must weave these perspectives into a coherent whole that respects
constraints, resolves conflicts, and produces an actionable specification.

This skill is not about design decisions in isolation—those belong to the specialists. Architecture synthesis is about
integration: finding where specialist outputs connect, identifying where they conflict, making trade-off decisions, and
producing a blueprint that implementation can follow without ambiguity.

The architect serves as the integrator, not the dictator. Specialist inputs represent domain expertise that must be
preserved where possible. The synthesis process should enhance and connect these inputs, overriding them only when
integration demands it.

## Input Gathering

Before synthesis can begin, gather all specialist outputs systematically. Missing inputs lead to incomplete blueprints
and implementation surprises.

### Specialist Contributions

Collect outputs from each design specialist:

**UI/UX Designer outputs:**

- User flow diagrams and interaction patterns
- Visual design specifications and component hierarchy
- Accessibility requirements and keyboard navigation
- Responsive breakpoints and device considerations
- Animation and transition specifications
- Error state designs and empty state handling

**Frontend Engineer outputs:**

- Component architecture and state management strategy
- Data fetching patterns and caching approach
- Routing structure and navigation guards
- Build and bundling considerations
- Performance requirements and optimization strategies
- Testing approach for frontend components

**API Designer outputs:**

- Endpoint specifications and HTTP contracts
- Request/response schemas and data formats
- Authentication and authorization requirements per endpoint
- Versioning strategy and deprecation policies
- Rate limiting and pagination approaches
- Error response formats and status codes

**Data Modeler outputs:**

- Entity relationship diagrams and schema definitions
- Indexing strategy and query patterns
- Migration approach and data seeding
- Normalization decisions and denormalization trade-offs
- Constraints, triggers, and stored procedures
- Backup and recovery considerations

**Security Analyst outputs:**

- Threat model and trust boundary analysis
- Required security controls and mitigations
- Authentication and session management requirements
- Data protection and encryption needs
- Audit logging requirements
- Compliance constraints and certifications

### Verification Checklist

Before proceeding with synthesis, verify completeness:

- All specialist areas have provided outputs
- Outputs include both requirements and rationale
- Constraints and assumptions are explicitly stated
- Open questions from specialists are documented
- Dependencies on external systems are identified

Flag missing inputs for clarification rather than proceeding with assumptions. Incomplete inputs produce incomplete
blueprints.

## Conflict Resolution

When specialist outputs contradict each other, apply a systematic resolution methodology rather than ad-hoc compromise.

### Identifying Conflicts

Conflicts manifest in several forms:

**Direct contradictions:**

- API designer specifies REST, frontend engineer assumes GraphQL
- Data model requires normalization, API design assumes denormalized responses
- Security requires MFA, UX specifies single-click login

**Resource conflicts:**

- Multiple features competing for limited API rate budget
- Performance requirements conflicting with functionality scope
- Timeline constraints conflicting with security requirements

**Implicit conflicts:**

- Assumptions in one design that invalidate another
- Dependencies that create circular requirements
- Scalability assumptions that differ between layers

### Resolution Process

For each conflict, apply this resolution sequence:

**Step 1: Clarify the conflict** Document precisely what contradicts what. Misunderstanding the conflict leads to poor
resolutions. State both positions clearly and identify the incompatibility.

**Step 2: Understand the rationale** Determine why each specialist made their choice. The rationale often reveals that
positions are not truly incompatible—just expressed differently. When rationale is missing, request clarification from
the specialist.

**Step 3: Identify stakeholders affected** Determine who is impacted by each resolution option. Some conflicts affect
end users; others affect only developers. User-facing impacts generally take priority over developer convenience.

**Step 4: Evaluate trade-offs** Apply the trade-off analysis methodology to each resolution option. Consider
second-order effects—resolving one conflict may create others.

**Step 5: Decide and document** Make the resolution decision. Document:

- What was decided
- Why this resolution was chosen
- What was given up
- Who must adapt their design as a result

### Escalation Criteria

Escalate to human decision when:

- Trade-offs affect user experience significantly
- Security mitigations are being deprioritized
- Resolution requires accepting risks
- Specialists cannot reach agreement through discussion
- Business or strategic implications exceed technical scope

## Trade-off Analysis

Most architectural decisions involve trade-offs. Systematic analysis prevents unconscious bias toward familiar
solutions.

### Performance vs. Simplicity

**When performance wins:**

- Measured bottlenecks with evidence
- Scale requirements with specific numbers
- User-facing latency affecting experience
- Cost implications at expected volumes

**When simplicity wins:**

- No evidence of performance problems
- Premature optimization without measurements
- Complexity that hinders maintainability
- Team unfamiliarity with complex approaches

**Analysis questions:**

- What evidence exists for performance requirements?
- What is the maintenance cost of the complex solution?
- Can performance be improved later without architectural change?
- What is the cost of being wrong in either direction?

### Flexibility vs. Constraints

**When flexibility wins:**

- Requirements likely to change
- Multiple valid implementation approaches
- Plugin or extension architectures
- Unknown future integration needs

**When constraints win:**

- Clear, stable requirements
- Security boundaries that must be enforced
- Compliance requirements with specific mandates
- Preventing misuse through design

**Analysis questions:**

- How confident are the requirements?
- What is the cost of changing a constrained design?
- Does flexibility create security or correctness risks?
- Who benefits from flexibility—users or developers?

### Build vs. Buy

**When building wins:**

- Core differentiating functionality
- Specific requirements not met by existing solutions
- Long-term ownership and control requirements
- Learning and capability building value

**When buying wins:**

- Commodity functionality (auth, payments, email)
- Time-to-market pressure
- Specialized domain expertise required
- Ongoing maintenance burden avoidance

**Analysis questions:**

- Is this functionality a competitive advantage?
- What is the total cost of ownership for building?
- What are the risks of vendor dependency?
- Does the team have expertise to build well?

### Cost vs. Features

**When reducing features wins:**

- Budget constraints are firm
- Timeline pressure with fixed deadline
- Features are "nice to have" not "must have"
- Quality would suffer from scope

**When increasing cost wins:**

- Features are critical to user value
- Cost is recoverable through feature value
- Reducing features would undermine the product
- Technical debt of cutting corners exceeds cost

## Integration Points

Map where components connect. Integration points are where implementations can diverge if not precisely specified.

### Identifying Integration Points

Integration points exist wherever:

- One component depends on output from another
- Data passes between different system boundaries
- Control flow transitions between domains
- Shared state is read or written by multiple components

### API Boundaries

For each API boundary, specify:

**Contract definition:**

- Endpoint URL and HTTP method
- Request headers, parameters, and body schema
- Response status codes and body schemas
- Error formats and codes

**Behavioral specification:**

- Authentication requirements
- Rate limiting behavior
- Pagination approach
- Caching headers and behavior

**Example interactions:**

- Success case with sample request and response
- Error cases with sample error responses
- Edge cases with expected behavior

### Data Flows

For each data flow, document:

**Source to destination:**

- Where data originates
- Transformation steps
- Where data terminates
- Who can access at each stage

**Format transformations:**

- Input format and validation
- Internal representation
- Output format and serialization
- Schema versioning approach

**Timing considerations:**

- Synchronous vs. asynchronous
- Expected latency bounds
- Retry and failure handling
- Ordering guarantees

### Shared State

For shared state, specify:

**Ownership:**

- Which component owns the state
- Read vs. write access per component
- Consistency requirements

**Synchronization:**

- How updates are coordinated
- Conflict resolution strategy
- Transaction boundaries

## Dependency Mapping

Understand what depends on what to enable parallel work and incremental delivery.

### Build Order Dependencies

Identify what must be built first:

**Foundation components:**

- Shared types and interfaces
- Common utilities and helpers
- Core abstractions other components depend on
- Database schema and migrations

**Dependent components:**

- Components that import foundation components
- Features that depend on core functionality
- Integrations that require APIs to exist

**Independent components:**

- Features that can be built in parallel
- Components with no shared dependencies
- Self-contained modules

### Deployment Dependencies

Map deployment ordering requirements:

**Database changes:**

- Schema migrations before application changes
- Data migrations and their timing
- Rollback dependencies

**Service dependencies:**

- Backend before frontend
- Core services before dependent services
- External service availability requirements

**Configuration dependencies:**

- Environment variables and secrets
- Feature flags and their states
- Infrastructure provisioning order

### Risk Dependencies

Identify components that concentrate risk:

**Single points of failure:**

- Components with many dependents
- Shared infrastructure without redundancy
- External dependencies without fallbacks

**Complexity concentrations:**

- Components with complex logic
- Integration points with many edge cases
- Areas with unclear requirements

## Risk Assessment

Identify technical risks before implementation begins. Unknowns become problems during implementation.

### Technical Risks

Catalog technical risks by category:

**Complexity risks:**

- Algorithms with uncertain performance characteristics
- Integrations with undocumented external systems
- State management in distributed scenarios
- Concurrent access patterns

**Dependency risks:**

- External services with uncertain reliability
- Libraries with unclear maintenance status
- Platform features with compatibility concerns
- Vendor lock-in implications

**Scale risks:**

- Untested performance at expected load
- Data volumes exceeding design assumptions
- Growth rate uncertainty
- Resource cost at scale

### Unknown Unknowns

Acknowledge areas of uncertainty:

**Explicitly document:**

- Assumptions that could not be validated
- Questions that remain unanswered
- Decisions made with incomplete information
- Areas requiring prototype validation

**For each unknown:**

- State what is not known
- Describe potential impact if assumptions are wrong
- Identify when the unknown will be resolved
- Define contingency if resolution is unfavorable

### Mitigation Strategies

For each identified risk:

**Risk acceptance:**

- Document accepted risks explicitly
- Require review date for reassessment
- Define monitoring for early warning

**Risk mitigation:**

- Specific technical approaches to reduce risk
- Validation steps to confirm mitigation
- Fallback plans if mitigation fails

**Risk avoidance:**

- Design changes to eliminate risk
- Alternative approaches without the risk
- Scope reduction to exclude risky areas

## Blueprint Creation

Combine all inputs, resolutions, and mappings into a single actionable specification.

### architecture.md Structure

Produce the architecture document with these sections:

**Header metadata:**

```markdown
---
phase: architecture
status: complete
specialists_integrated:
  - ui-ux-designer
  - frontend-engineer
  - api-designer
  - data-modeler
  - security-analyst
conflicts_resolved: [count]
risks_identified: [count]
---
```

**Executive Summary:** Brief overview of the architecture in one to two paragraphs. State the core approach, key
technologies, and primary trade-offs made.

**Component Overview:** High-level diagram or description of major components and their relationships. Include both
logical and physical views if they differ.

**Specialist Sections:** For each specialist area, include:

- Design summary from specialist input
- Integration notes added by architect
- Conflicts resolved and decisions made
- Dependencies on other areas

**Integration Specifications:** Detailed specifications for each integration point:

- API contracts with schemas
- Data flow diagrams
- Shared state specifications
- Event contracts

**Dependency Graph:** Visual or textual representation of:

- Build order dependencies
- Deployment dependencies
- Runtime dependencies

**Risk Register:** All identified risks with:

- Risk ID and description
- Likelihood and impact
- Mitigation strategy
- Owner and review date

**Implementation Sequence:** Recommended order of implementation:

- Foundation phase (what to build first)
- Core features phase (essential functionality)
- Enhancement phase (additional features)
- Hardening phase (security and performance)

**Open Items:** Questions requiring resolution during implementation:

- Technical unknowns to investigate
- Decisions deferred to implementation
- Dependencies on external parties

## Output Format

The architecture synthesis process produces the following artifacts:

### architecture.md

The primary blueprint document structured as specified above. This is the authoritative reference for implementation.

### architecture-decisions.md

Supplementary document capturing:

- Each significant decision made
- Alternatives considered
- Rationale for the decision
- Consequences and trade-offs

### integration-specs/

Directory containing detailed specifications for each integration point:

- API contracts as OpenAPI or similar
- Data schemas as JSON Schema or similar
- Event contracts with payload definitions

## Principles

### Preserve Specialist Intent

Override specialist decisions only when integration requires it. The specialist understands their domain better than the
architect. Preserve their intent even when adapting their output for integration.

### Make Trade-offs Explicit

Hidden trade-offs become implementation surprises. Document every significant trade-off with its rationale. Future
developers and maintainers need to understand not just what was decided but why.

### Specify Boundaries Precisely

Ambiguous integration points cause implementation conflicts. Be precise about contracts, formats, and behaviors at every
boundary. Precision at boundaries enables parallelism in implementation.

### Plan for Change

Architectures evolve. Design for change by identifying stable vs. volatile elements. Invest in abstraction at change
points while avoiding unnecessary flexibility elsewhere.

### Enable Verification

Include acceptance criteria and verification approaches in the blueprint. Implementation teams should know how to verify
they have built what was specified. Unverifiable specifications are incomplete specifications.
