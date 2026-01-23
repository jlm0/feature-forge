---
name: ask-questions
description:
  This skill should be used when an agent encounters uncertainty, multiple valid interpretations exist, key details are
  unclear, decisions exceed delegated authority, or the user could provide valuable shortcuts. It teaches how to pause,
  ask targeted questions, and confirm understanding before proceeding.
---

# Ask Questions Skill

## Overview

Ask questions to resolve uncertainty before proceeding with work. This skill enables agents to pause, formulate targeted
questions, and confirm understanding rather than guessing or making assumptions that could lead to wasted effort or
incorrect outcomes.

The human is the orchestrating architect. Asking questions is not a sign of weakness—it demonstrates good judgment about
when human input adds value.

## When to Ask Questions

Ask questions when any of these conditions apply:

### Multiple Plausible Interpretations Exist

When a requirement, instruction, or discovered pattern could be interpreted in different valid ways, ask which
interpretation is correct. Guessing between equally plausible options wastes effort if the wrong path is chosen.

**Examples:**

- "This pattern is unusual—is it intentional or legacy code to be replaced?"
- "The spec mentions 'user data'—does this include profile metadata or just credentials?"

### Key Details Are Unclear

When the objective, scope, constraints, or acceptance criteria are ambiguous or incomplete, seek clarification.
Proceeding without clarity on fundamentals leads to rework.

**Key details to clarify:**

- Objective: What specific outcome is expected?
- Scope: What is included and excluded?
- Constraints: Performance requirements, compatibility needs, technology restrictions?
- Acceptance criteria: How will success be measured?

### Decision Exceeds Delegated Authority

When a choice has significant implications for architecture, security, cost, or user experience—and that choice was not
explicitly delegated—escalate to the human. Making high-impact decisions without authorization risks building the wrong
thing.

**Examples:**

- Choosing between fundamentally different architectural approaches
- Making security trade-offs (accepting risk, prioritizing mitigations)
- Decisions affecting user-facing behavior or experience
- Technology choices with long-term implications

### User Could Provide Valuable Shortcuts

When the human likely has information that would save significant exploration time, ask for it. Humans often know:

- Where similar functionality already exists in the codebase
- Relevant documentation, RFCs, or design docs
- Historical context about why things are done a certain way
- Organizational preferences or conventions

**Examples:**

- "Are there existing implementations of X I should reference?"
- "Is there documentation for this API I should read?"
- "Has this approach been tried before? Any lessons learned?"

### Conflicting Constraints Discovered

When requirements or constraints contradict each other, surface the conflict rather than silently choosing one over the
other. Only the human can make the trade-off decision.

**Examples:**

- Performance requirements conflict with simplicity goals
- Security requirements conflict with user experience preferences
- Scope includes features that exceed timeline constraints

## When NOT to Ask Questions

Avoid asking questions in these situations:

### Answer Is Discoverable Through Exploration

When the answer can be found by reading code, documentation, or configuration, find it rather than asking. Exercise the
code-exploration and docs-research skills first.

**Do not ask:**

- "What framework does this project use?" (Check package.json or equivalent)
- "How is authentication implemented?" (Trace the code)
- "What's the database schema?" (Read migration files or schema definitions)

### Reasonable Defaults Exist and Stakes Are Low

When a decision has low impact and a sensible default exists, proceed with the default rather than interrupting the
human. Reserve questions for decisions that matter.

**Proceed without asking:**

- Variable naming within established conventions
- File organization following existing patterns
- Implementation details with clear best practices
- Minor formatting or style decisions

### Question Was Already Answered

Check conversation history and project documentation before asking. Repeating questions wastes human time and signals
inattention.

**Before asking, check:**

- Previous messages in the current session
- Project documentation and README files
- State files from previous phases (discovery.md, exploration.md, etc.)

## Question Design Methodology

Design questions to maximize information gained while minimizing burden on the human.

### CRITICAL: Use the AskUserQuestion Tool

**Always use the `AskUserQuestion` tool for interactive questions.** This tool provides a proper UI with clickable
multiple-choice options rather than requiring the user to type responses.

**AskUserQuestion tool parameters:**
- `questions`: Array of 1-4 question objects
- Each question has: `question`, `header`, `options`, `multiSelect`
- Each option has: `label`, `description`
- Put the recommended option FIRST and add "(Recommended)" to its label

**Example tool usage:**
```json
{
  "questions": [
    {
      "question": "Which authentication approach should we use?",
      "header": "Auth method",
      "multiSelect": false,
      "options": [
        {"label": "JWT tokens (Recommended)", "description": "Stateless auth, scales horizontally without session store. Tokens stored client-side, supports mobile/SPA. Tradeoff: harder to revoke tokens immediately."},
        {"label": "Session cookies", "description": "Server-side sessions with HTTP-only cookies. Simpler revocation but requires session store (Redis/DB) and may need sticky sessions for scaling."},
        {"label": "OAuth only", "description": "Delegate auth to Google/GitHub/etc. No password management but depends on external provider availability. Users must have provider account."}
      ]
    }
  ]
}
```

**DO NOT** output questions as plain text and ask the user to type back. The interactive UI is faster and clearer.

### Ask 1-4 Questions Maximum

The AskUserQuestion tool supports 1-4 questions per call. Batch related questions together, but keep the total count
low. Prefer fewer, higher-impact questions over comprehensive lists.

### Prefer Questions That Eliminate Branches

Design questions to rule out entire categories of possibilities. A single well-chosen question can eliminate hours of
wasted exploration.

**High-value question:**

- "Should this be built as a new service or integrated into the existing monolith?"

**Low-value questions:**

- "What color should the button be?"
- "Should the variable be called 'userData' or 'userInfo'?"

### Offer 2-4 Options Per Question

The AskUserQuestion tool requires 2-4 options per question. Each option needs:
- `label`: Short display text (1-5 words)
- `description`: **CRITICAL** - Provide enough context for informed decision-making. Explain implications, trade-offs,
  and consequences. Users need to understand what they're choosing, not just the option name.

**Good descriptions:**
- "Stateless authentication, scales horizontally, requires client-side token storage"
- "Traditional sessions, simpler implementation, requires session store and sticky sessions"

**Bad descriptions:**
- "Use JWT" (no context)
- "The standard approach" (doesn't explain implications)

The user can always select "Other" to provide custom input, so don't include an "Other" option manually.

### Put Recommended Option First

When a clear best practice exists, make it the first option and add "(Recommended)" to the label. This signals
expertise and makes the default choice obvious.

### Use multiSelect When Appropriate

Set `multiSelect: true` when choices are not mutually exclusive. For example: "Which features should be included?"
allows selecting multiple items.

### Use Short Headers

The `header` field appears as a chip/tag (max 12 chars). Use brief labels like:
- "Auth method"
- "Scope"
- "Approach"
- "Database"

## Pause and Wait Pattern

**CRITICAL:** After asking questions, pause before acting until answers arrive.

### What Pausing Means

- Do not make decisions on the uncertain matters
- Do not write code that depends on the unclear requirements
- Do not proceed to subsequent phases that depend on the answers

### What Is Allowed While Waiting

Low-risk discovery activities that do not depend on the answers:

- Reading additional files for context
- Exploring related parts of the codebase
- Gathering information that will be useful regardless of the answers

### What Is NOT Allowed While Waiting

- Making assumptions about what the answers will be
- Writing implementation code
- Making architectural decisions
- Proceeding to the next phase

### Why Pausing Matters

Proceeding before receiving answers often leads to:

- Wasted effort on the wrong approach
- Need to discard and rewrite work
- Compounding errors as wrong assumptions propagate
- Loss of human trust in the workflow

## Confirmation Pattern

After receiving answers, confirm interpretation before proceeding.

### Restate Understanding

Summarize what was understood from the answers in concrete terms. This catches misunderstandings before they cause
problems.

```
Based on your answers:
- Scope: Only the authentication module, not payments
- Approach: JWT tokens with refresh token rotation
- Timeline: MVP for v1, can add SSO in v2

I'll proceed with this understanding. Let me know if I've misinterpreted anything.
```

### Catch Misunderstandings Early

If the human corrects the interpretation, update understanding before proceeding. A small delay for confirmation
prevents large rework cycles.

### Document for Future Reference

Record confirmed answers in appropriate state files so future phases and sessions have access to the decisions made.

## Output Format

### Presenting Questions

**Always use the AskUserQuestion tool.** Structure questions with:

- Clear `question` text ending with a question mark
- Short `header` for the chip/tag (max 12 chars)
- 2-4 `options` with label and description
- Recommended option listed first with "(Recommended)" in label
- `multiSelect: true` only when multiple selections make sense

**Example for clarification checkpoint:**
```json
{
  "questions": [
    {
      "question": "What is the scope of this feature?",
      "header": "Scope",
      "multiSelect": false,
      "options": [
        {"label": "Minimal (Recommended)", "description": "Only the core functionality, defer nice-to-haves"},
        {"label": "Full feature", "description": "Include all described functionality"},
        {"label": "MVP + one extension", "description": "Core plus one additional capability"}
      ]
    },
    {
      "question": "Which existing patterns should we follow?",
      "header": "Patterns",
      "multiSelect": false,
      "options": [
        {"label": "Match existing (Recommended)", "description": "Follow patterns already in the codebase"},
        {"label": "Introduce new pattern", "description": "Use a different approach with justification"}
      ]
    }
  ]
}
```

### After Receiving Answers

After answers are received:

1. Acknowledge the response
2. Restate interpretation for confirmation (as regular text output)
3. Note any follow-up clarifications needed
4. Proceed with work once confirmed

## Integration with Workflow

The ask-questions skill integrates with Feature-Forge phases:

| Phase            | Typical Questions                                              |
| ---------------- | -------------------------------------------------------------- |
| Discovery        | Sources to read, scope boundaries, constraints                 |
| Exploration      | Unusual patterns, historical context, existing implementations |
| Security Context | Risk tolerance, compliance requirements                        |
| Architecture     | Trade-offs between approaches, technology preferences          |
| Security Review  | Acceptable risks, mitigation priorities                        |
| Implementation   | Blockers, requirement clarifications                           |
| Remediation      | Fix approaches, remaining risk acceptance                      |

Questions are internal to phases—they pause the current agent's work, not the entire workflow. Checkpoints (distinct
from questions) are the explicit approval gates between phase groups.

## Principles

### Prefer Action When Appropriate

Asking questions is not an excuse for inaction. When the path forward is clear, proceed. Reserve questions for genuine
uncertainty that would benefit from human input.

### Respect Human Time

Batch questions, offer defaults, and provide fast-path responses. The human should be able to respond efficiently when
answers are straightforward.

### Surface Uncertainty, Not Ignorance

Questions should demonstrate that the problem space has been understood and that specific information is needed—not that
basic exploration has been skipped.

### Trust the Process

Questions enable better outcomes. The workflow is designed for human stewardship. Asking good questions is a feature,
not a limitation.
