---
name: triage
description:
  This skill should be used when prioritizing requirements for v1 vs later versions, making scope decisions under
  constraints, assessing impact and urgency of issues, or deciding what to defer vs what must ship.
---

# Triage Skill

## Overview

Triage is the methodology for making prioritization decisions under constraints. When requirements exceed available
time, budget, or complexity capacity, triage provides a disciplined approach to decide what must be in v1, what can be
deferred, and what risks are acceptable to ship with.

Triage is not about cutting features arbitrarily. It is about making explicit trade-off decisions with clear rationale,
stakeholder alignment, and documented implications. Poor triage leads to either shipping products that do not solve user
problems or never shipping at all.

The goal is a clear v1 scope that delivers core user value while remaining achievable within constraints. Everything
else receives explicit classification: deferred with a reason, or accepted as a risk with justification.

## Impact Assessment

Assess impact across three dimensions before prioritizing. High-impact items justify greater investment; low-impact
items are candidates for deferral.

### User Impact

Evaluate how the requirement affects end users:

**Critical user impact:**

- Feature enables the core user journey
- Absence prevents users from achieving their goal
- Workarounds do not exist or are unacceptable
- User safety or data security depends on it

**High user impact:**

- Feature significantly improves user experience
- Common workflows become notably easier
- User friction is substantially reduced
- Accessibility requirements are met

**Medium user impact:**

- Feature provides convenience but alternatives exist
- Edge case handling improves
- Power user functionality
- Aesthetic or polish improvements

**Low user impact:**

- Nice-to-have features
- Rare use cases
- Preferences rather than requirements
- Internal-facing improvements

**Assessment questions:**

- How many users are affected?
- How frequently do users encounter this need?
- What happens if users do not have this feature?
- What workarounds exist and how painful are they?

### Business Impact

Evaluate how the requirement affects business outcomes:

**Critical business impact:**

- Requirement is contractually obligated
- Compliance or legal mandate
- Revenue-critical functionality
- Partnership or integration requirement

**High business impact:**

- Differentiating feature affecting competitiveness
- Significant revenue opportunity
- Key stakeholder requirement
- Market timing sensitivity

**Medium business impact:**

- Incremental revenue opportunity
- Operational efficiency improvement
- Support cost reduction
- Brand or reputation benefit

**Low business impact:**

- Internal tooling improvement
- Technical preference
- Future-proofing without current need
- Developer convenience

**Assessment questions:**

- What is the revenue impact of inclusion vs. exclusion?
- Are there contractual or legal obligations?
- How does this affect competitive positioning?
- What are the costs of deferral?

### Technical Impact

Evaluate how the requirement affects the technical system:

**Critical technical impact:**

- Security vulnerability if absent
- Data integrity requirement
- System stability dependency
- Performance cliff if missing

**High technical impact:**

- Enables other important features
- Reduces significant technical debt
- Improves system maintainability
- Prevents future rework

**Medium technical impact:**

- Code quality improvement
- Testing infrastructure
- Developer experience
- Monitoring and observability

**Low technical impact:**

- Refactoring without functional change
- Alternative implementation approaches
- Tooling preferences
- Documentation improvements

**Assessment questions:**

- Does this block other features?
- What is the technical debt cost of deferral?
- Are there security implications?
- How does this affect system reliability?

## Urgency Evaluation

Urgency is separate from impact. High-impact items may not be urgent; urgent items may not be high-impact. Assess
urgency independently.

### Time Sensitivity

Evaluate deadline drivers:

**Fixed deadlines:**

- Contractual commitments with dates
- Regulatory compliance deadlines
- Event-driven launches (conferences, seasons)
- Coordination dependencies with other teams

**Opportunity windows:**

- Market timing advantages
- Competitive response requirements
- Partner availability constraints
- Resource availability windows

**Artificial urgency:**

- Arbitrary deadlines without business justification
- Pressure without rationale
- "Would be nice" timelines

**Assessment questions:**

- What happens if this misses the v1 deadline?
- Is the deadline negotiable?
- What is the cost of delay?
- Who set the deadline and why?

### Dependency Urgency

Evaluate blocking relationships:

**Blocking dependencies:**

- Required for other critical features to work
- External integration prerequisites
- Infrastructure that must exist first
- Data that must be available

**Blocked by dependencies:**

- Cannot begin until something else completes
- Waiting on external parties
- Requires decisions not yet made

**Assessment questions:**

- What does this block?
- What blocks this?
- Can dependencies be reordered?
- Are there parallel paths available?

### Degradation Over Time

Evaluate how deferral affects future implementation:

**Increasing difficulty:**

- Technical debt compounds
- Migration cost grows with data volume
- Integration becomes harder as systems diverge
- Knowledge decays as team changes

**Stable difficulty:**

- Feature remains equally implementable later
- No accumulating cost to deferral
- Clean integration point maintained

**Assessment questions:**

- Does delay make this harder to implement?
- What accumulates during deferral?
- Is there a point of no return?

## Risk Assessment

Assess risks of both inclusion and exclusion before prioritizing.

### Deferral Risks

Evaluate what happens if a requirement is deferred:

**User risks:**

- Users cannot complete their goals
- User trust or satisfaction declines
- Users choose competitor solutions
- User data is at risk

**Business risks:**

- Revenue impact from missing functionality
- Contractual breach or penalties
- Competitive disadvantage crystallizes
- Partnership opportunities lost

**Technical risks:**

- Technical debt accumulates
- Integration becomes harder
- Security exposure persists
- Performance degrades

**Assessment questions:**

- What is the worst-case outcome of deferral?
- How likely is the worst case?
- Is the risk recoverable later?
- Who bears the risk?

### Inclusion Risks

Evaluate what happens if a requirement is rushed to v1:

**Quality risks:**

- Insufficient testing time
- Technical debt introduced
- User experience suffers from incomplete polish
- Security vulnerabilities from rushed implementation

**Scope risks:**

- Other requirements squeezed out
- Core features receive less attention
- Integration quality suffers
- Team burnout from overcommitment

**Schedule risks:**

- v1 delivery delayed
- Parallel work blocked
- Dependencies missed
- Cascading schedule impacts

**Assessment questions:**

- Can this be implemented well in available time?
- What else is affected by inclusion?
- What quality shortcuts might occur?
- Is partial implementation worse than none?

## MoSCoW Method

Apply the MoSCoW framework to classify requirements systematically.

### Must Have

Requirements without which the product cannot ship.

**Criteria for Must Have:**

- Core user journey is impossible without it
- Legal or compliance mandate
- Security requirement at critical risk level
- Contractual obligation

**Test:** If removed, is the product viable for any user? If no, it is Must Have.

**Discipline:** Must Have should be approximately 60% of effort to allow buffer for unknowns. If Must Have exceeds
capacity, scope is too large—reduce requirements or extend timeline.

### Should Have

Important requirements that can be worked around if necessary.

**Criteria for Should Have:**

- Significant user value but workarounds exist
- Important business impact but not critical
- High technical value but not blocking

**Test:** If removed, is the product significantly worse but still usable? If yes, it is Should Have.

**Treatment:** Include if capacity allows after Must Have is secured. First candidates for deferral if constraints
tighten.

### Could Have

Desirable requirements with lower impact than Should Have.

**Criteria for Could Have:**

- Nice-to-have features
- Polish and refinement
- Edge case handling
- Convenience improvements

**Test:** Would users notice the absence? If unlikely, it is Could Have.

**Treatment:** Include only if significant capacity remains. Do not sacrifice quality of higher-priority items for Could
Have features.

### Won't Have (This Time)

Requirements explicitly excluded from current scope.

**Criteria for Won't Have:**

- Lower impact than available capacity
- Conflicts with higher-priority requirements
- Requires capabilities not yet available
- Strategic decision to exclude

**Treatment:** Document explicitly. Won't Have is a decision, not an oversight. Include reason and potential future
timing.

## v1 Criteria

Define what constitutes a viable v1 release. Clear criteria prevent scope creep and enable decision-making.

### Core User Journey

Define the minimum path a user must be able to complete:

**Journey definition:**

- Entry point: How does the user begin?
- Core actions: What steps must the user take?
- Success state: How does the user know they succeeded?
- Exit point: How does the user complete their task?

**Completeness test:**

- Can a new user complete the core journey?
- Is the journey achievable without workarounds?
- Does the journey deliver the promised value?

### Minimum Feature Set

Enumerate the features required to support the core journey:

**Feature enumeration:**

- List each feature supporting the core journey
- Note dependencies between features
- Identify minimum viable implementation for each

**Feature validation:**

- Each feature is necessary for the core journey
- No feature is included purely for "completeness"
- Features work together as a coherent whole

### Safety Requirements

Define non-negotiable safety constraints:

**Security requirements:**

- Authentication and authorization minimum
- Data protection minimum
- Vulnerability categories that block release

**Reliability requirements:**

- Availability targets
- Data integrity guarantees
- Failure handling minimum

**Compliance requirements:**

- Regulatory mandates
- Contractual requirements
- Industry standards

### Quality Gates

Define minimum quality for v1 release:

**Functional quality:**

- Core journey works without critical bugs
- Error handling prevents data loss
- Edge cases do not crash the system

**Non-functional quality:**

- Performance meets minimum thresholds
- Accessibility meets minimum standards
- Documentation enables user success

## Deferral Documentation

Document every deferred requirement explicitly. Deferrals without documentation become forgotten requirements.

### Deferral Record Structure

For each deferred requirement:

**Identification:**

- Requirement ID and title
- Original priority and category
- Source (who requested, why)

**Deferral rationale:**

- Why this was deferred
- What would be needed to include it
- Trade-offs considered

**Future timing:**

- Target version or timeframe
- Conditions that would change priority
- Dependencies on v1 features

**Dependencies:**

- What this depends on
- What depends on this
- v1 features affected by deferral

### Revisit Triggers

Define when to revisit deferred requirements:

**Time-based triggers:**

- Review all deferrals after v1 ships
- Quarterly prioritization reviews
- Version planning milestones

**Event-based triggers:**

- User feedback requesting deferred feature
- Business conditions change
- Technical dependencies resolved
- Competitive pressure emerges

## Stakeholder Alignment

Triage decisions require stakeholder buy-in. Unilateral prioritization creates conflict.

### Communicating Trade-offs

Present triage decisions with context:

**For each decision, communicate:**

- What is being decided
- What the alternatives were
- Why this option was chosen
- What is given up with this decision

**Format for communication:**

- Lead with user impact, not technical rationale
- Quantify where possible (users affected, revenue impact)
- Show work—demonstrate systematic analysis
- Invite challenge on rationale, not just conclusion

### Handling Disagreement

When stakeholders disagree with triage:

**First:** Ensure understanding is shared. Disagreements often stem from different information or assumptions.

**Second:** Examine the rationale. Is the disagreement about impact assessment, urgency evaluation, or risk tolerance?

**Third:** Identify the actual trade-off. What would need to change to accommodate the different priority?

**Fourth:** Escalate if unresolved. Triage decisions within delegated authority can proceed; decisions affecting
business strategy require appropriate decision-makers.

### Approval Checkpoints

Triage decisions are checkpoints requiring explicit approval:

**Approval scope:**

- v1 scope definition
- Must Have vs. Should Have classification
- Accepted risks
- Deferral decisions

**Approval process:**

- Present triage output with rationale
- Request explicit approval or changes
- Document approved decisions
- Limit iteration to prevent analysis paralysis (max 2 rounds)

## Output Format

Triage produces structured output enabling implementation and future reference.

### triage.json Structure

```json
{
  "metadata": {
    "phase": "triage",
    "status": "approved",
    "approved_by": "[stakeholder]",
    "approved_date": "[date]",
    "iteration_count": 1
  },
  "v1_requirements": [
    {
      "id": "REQ-001",
      "title": "[requirement title]",
      "category": "must_have",
      "user_impact": "critical",
      "business_impact": "high",
      "technical_impact": "medium",
      "urgency": "high",
      "rationale": "[why this is v1]",
      "acceptance_criteria": "[how to verify completion]",
      "dependencies": ["REQ-002"]
    }
  ],
  "deferred": [
    {
      "id": "REQ-015",
      "title": "[requirement title]",
      "original_category": "should_have",
      "user_impact": "medium",
      "business_impact": "medium",
      "deferral_reason": "[why deferred]",
      "target_version": "v1.1",
      "revisit_trigger": "[when to reconsider]",
      "cost_of_deferral": "[what is lost by waiting]",
      "dependencies_affected": []
    }
  ],
  "accepted_risks": [
    {
      "id": "RISK-001",
      "description": "[risk description]",
      "likelihood": "low",
      "impact": "medium",
      "justification": "[why accepting this risk]",
      "mitigation": "[partial mitigation if any]",
      "monitoring": "[how to detect if risk materializes]",
      "review_date": "[when to reassess]"
    }
  ],
  "scope_summary": {
    "must_have_count": 12,
    "should_have_count": 5,
    "deferred_count": 8,
    "accepted_risks_count": 3,
    "estimated_effort": "[effort estimate]",
    "core_journey": "[brief description of core user journey]"
  }
}
```

### triage-rationale.md

Supplementary document with narrative explanation:

**Scope decisions:**

- Why this v1 scope was chosen
- Major trade-offs made
- Stakeholder input incorporated

**Deferral rationale:**

- Why each category of items was deferred
- What would change the deferral decision
- Relationship to future versions

**Risk acceptance rationale:**

- Why each risk is acceptable
- What monitoring is in place
- When risks will be reassessed

## Principles

### Defer Explicitly, Not Implicitly

Every requirement not in v1 should be explicitly deferred with rationale. Implicit omission leads to forgotten
requirements and stakeholder surprise. Explicit deferral demonstrates disciplined prioritization.

### Protect Must Have

Never compromise Must Have quality to squeeze in Should Have features. The core user journey must work well. A polished
subset is better than a buggy superset.

### Document the Trade-offs

Stakeholders will question prioritization decisions later. Documentation protects against revisionism and enables
informed future decisions. Capture the context that made the decision reasonable.

### Time-box Iteration

Triage can iterate indefinitely if allowed. Set limits: maximum two rounds of stakeholder feedback before final
decision. Perfect prioritization does not exist; good-enough prioritization enables progress.

### Validate Against Reality

Triage based on estimated effort often proves wrong. Build feedback loops: compare actual effort to estimates, actual
user impact to predicted impact. Use learnings to improve future triage accuracy.
