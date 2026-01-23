---
name: docs-research
description:
  This skill should be used when researching external documentation, reading RFCs or specifications, understanding
  third-party APIs, digesting official library docs, or synthesizing information from multiple documentation sources. It
  teaches systematic extraction and synthesis of technical knowledge.
---

# Documentation Research Skill

## Overview

Apply systematic documentation research and synthesis methodology to extract actionable technical knowledge from
external sources. Transform raw documentation into structured understanding that informs design and implementation
decisions.

The core workflow follows: **Identify sources** - **Extract patterns** - **Synthesize knowledge**

## Source Identification

### Primary Sources (Highest Authority)

Locate and prioritize these authoritative documentation types:

**Official Documentation**

- Product documentation from the vendor or maintainer
- API reference documentation with method signatures and parameters
- Getting started guides and tutorials from official sources
- Migration guides and upgrade paths
- Changelog and release notes

**Technical Specifications**

- RFCs (Request for Comments) for protocol standards
- IETF, W3C, ECMA, and ISO specifications
- OpenAPI/Swagger specifications for APIs
- JSON Schema definitions
- Protocol buffer definitions

**Source Code as Documentation**

- Type definitions and interfaces (TypeScript `.d.ts`, Java interfaces)
- Inline documentation and docstrings
- Example code in official repositories
- Test suites demonstrating expected behavior
- Configuration file schemas

### Secondary Sources (Supplementary)

Consult these sources to fill gaps and understand real-world usage:

**Community Resources**

- Stack Overflow answers (verify recency and vote count)
- GitHub Issues and Discussions
- Official forums and community channels
- Blog posts from recognized experts
- Conference talks and presentations

**Practical Examples**

- Open source projects using the technology
- Official example repositories
- Tutorials from reputable sources
- Code samples in documentation

## Source Prioritization

Apply this hierarchy when sources conflict or overlap:

### Authority Ranking

1. **Official specification** (RFC, standard) - Canonical definition
2. **Official documentation** - Vendor-maintained reference
3. **Official examples/tutorials** - Vendor-sanctioned patterns
4. **Source code** - Ground truth implementation
5. **Reputable community content** - Real-world validation
6. **General community content** - Use with verification

### Recency Assessment

- Check publication or last-updated date for all sources
- Verify version compatibility (documentation for v2 may not apply to v3)
- Prefer actively maintained documentation over archived content
- Note deprecation warnings and migration paths
- Cross-reference changelogs when documentation seems outdated

### Specificity Selection

- Prefer documentation specific to the exact use case
- General overviews provide context but may lack implementation detail
- API references trump conceptual documentation for implementation
- Platform-specific guides over cross-platform generalizations

## Extraction Methodology

### Core Concepts and Terminology

Extract foundational knowledge:

- **Define key terms** - Build a glossary of domain-specific vocabulary
- **Identify abstractions** - Understand the mental model the documentation assumes
- **Map relationships** - How concepts connect and depend on each other
- **Note prerequisites** - What knowledge or setup the documentation assumes

### Key Patterns and Idioms

Recognize recommended approaches:

- **Initialization patterns** - Standard setup and configuration
- **Usage patterns** - Idiomatic ways to accomplish common tasks
- **Composition patterns** - How components combine and interact
- **Lifecycle patterns** - Resource management, cleanup, event handling
- **Error handling patterns** - Expected failure modes and recovery

### Configuration and Options

Document configurability:

- **Required configuration** - Mandatory settings with no defaults
- **Optional configuration** - Settings with sensible defaults
- **Environment variables** - Runtime configuration mechanisms
- **Feature flags** - Enabling/disabling functionality
- **Security-sensitive options** - Settings affecting security posture

### Common Pitfalls and Gotchas

Actively seek warnings:

- **Explicit warnings** - Documentation callouts about common mistakes
- **Migration notes** - Breaking changes from previous versions
- **Known limitations** - Documented constraints and unsupported scenarios
- **Performance considerations** - Scaling limits, resource consumption
- **Security advisories** - Known vulnerabilities and mitigations

### Error Handling Approaches

Understand failure modes:

- **Error types** - Classification of possible errors
- **Error messages** - What messages indicate which problems
- **Recovery strategies** - Recommended handling for each error type
- **Retry semantics** - Idempotency, backoff strategies
- **Debugging techniques** - Logging, tracing, diagnostic tools

### Performance Considerations

Note efficiency guidance:

- **Benchmarks** - Official performance characteristics
- **Optimization techniques** - Documented performance improvements
- **Resource limits** - Memory, connections, rate limits
- **Caching strategies** - Recommended caching approaches
- **Batch operations** - Efficient bulk processing

## Pattern Recognition

### Recommended Patterns

Identify what the documentation promotes:

- **Best practices sections** - Explicitly recommended approaches
- **Example code** - Patterns demonstrated in official examples
- **Architecture diagrams** - Suggested system structures
- **Integration patterns** - Recommended ways to combine with other systems
- **Testing patterns** - Suggested approaches for verification

### Anti-Patterns

Note what the documentation discourages:

- **Explicit warnings** - "Do not" or "Avoid" statements
- **Deprecation notices** - Patterns being phased out
- **Security warnings** - Approaches with security implications
- **Performance warnings** - Patterns that cause inefficiency
- **Compatibility warnings** - Patterns that limit portability

### Design Philosophy

Understand the underlying principles:

- **Goals and non-goals** - What the technology aims to achieve
- **Trade-offs** - Explicit decisions and their rationale
- **Conventions** - Expected naming, structure, organization
- **Extension points** - Where customization is intended
- **Boundaries** - Where the technology ends and others begin

## Synthesis Process

### Combining Multiple Sources

Merge information coherently:

1. **Start with authoritative sources** - Build foundation from official docs
2. **Layer in community knowledge** - Add practical insights
3. **Validate against source code** - Verify accuracy when uncertain
4. **Note discrepancies** - Document where sources disagree
5. **Prefer conservative interpretations** - When uncertain, choose safer path

### Resolving Contradictions

Handle conflicting information:

- **Check dates** - Newer authoritative source likely correct
- **Check versions** - Information may apply to different versions
- **Check context** - Contradictions may reflect different use cases
- **Prefer specification over implementation** - Spec defines intent
- **Note unresolved conflicts** - Flag for further investigation

### Building Mental Model

Construct actionable understanding:

- **Create concept map** - Visualize relationships between components
- **Identify decision points** - Where choices must be made
- **Map to existing knowledge** - Connect to familiar patterns
- **Anticipate questions** - What will implementers need to know
- **Validate completeness** - Ensure all necessary information captured

## Web Fetching Approach

### Using WebFetch

Apply WebFetch for external documentation:

- **Fetch official documentation** - Retrieve current authoritative content
- **Extract specific sections** - Focus on relevant portions
- **Verify page freshness** - Check for last-updated indicators
- **Follow canonical links** - Navigate to authoritative sources

### Using WebSearch

Apply WebSearch for discovery:

- **Find official documentation URLs** - Locate authoritative sources
- **Discover related resources** - Find supplementary material
- **Locate specific topics** - Find documentation for particular features
- **Verify current practices** - Check for recent community guidance

### Verification Practices

Ensure information quality:

- **Check publication dates** - Reject outdated information
- **Verify source authority** - Confirm official or reputable origin
- **Cross-reference claims** - Validate important information across sources
- **Test code samples** - Verify examples work as documented
- **Note version constraints** - Document which versions information applies to

## Output Format

Structure synthesized research as follows:

### Technology Overview

Provide executive summary:

- **Purpose** - What the technology does and why it exists
- **Scope** - What it handles and what it does not
- **Maturity** - Stability, adoption, maintenance status
- **Ecosystem** - Related tools, libraries, community

### Key Concepts and Terminology

Define foundational vocabulary:

- **Term definitions** - Clear explanations of domain terms
- **Concept relationships** - How concepts connect
- **Mental model** - Framework for understanding the technology

### Recommended Patterns

Document approved approaches:

- **Pattern name** - Clear identifier
- **When to use** - Appropriate scenarios
- **How to implement** - Step-by-step guidance
- **Code example** - Concrete demonstration
- **Variations** - Alternative approaches for different contexts

### Common Pitfalls to Avoid

Warn about known issues:

- **Pitfall description** - What can go wrong
- **Why it happens** - Root cause
- **How to avoid** - Prevention strategy
- **How to detect** - Signs of the problem
- **How to fix** - Recovery approach

### Relevant Code Examples

Provide actionable samples:

- **Working code** - Tested, runnable examples
- **Annotations** - Explanations of key lines
- **Context** - When and where to apply
- **Variations** - Adaptations for different scenarios

### Links to Authoritative Sources

Reference original documentation:

- **Official documentation** - Primary reference links
- **API references** - Detailed method documentation
- **Specifications** - Standards documents
- **Additional resources** - Supplementary reading

## Research Session Workflow

Execute documentation research in phases:

### Phase 1: Source Discovery

1. Identify the technology or API to research
2. Locate official documentation entry points
3. Find relevant specifications or standards
4. Discover community resources
5. Assess source quality and recency

### Phase 2: Systematic Extraction

1. Read official documentation thoroughly
2. Extract core concepts and terminology
3. Identify recommended patterns
4. Note warnings and pitfalls
5. Capture code examples

### Phase 3: Validation

1. Cross-reference multiple sources
2. Verify code examples function correctly
3. Resolve contradictions
4. Note gaps in documentation
5. Flag areas needing clarification

### Phase 4: Synthesis

1. Organize extracted knowledge
2. Build coherent mental model
3. Structure output document
4. Include actionable examples
5. Provide source references
