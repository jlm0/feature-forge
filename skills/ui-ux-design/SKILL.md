---
name: ui-ux-design
description:
  This skill should be used when designing user interfaces, creating user flows, planning interaction patterns,
  establishing visual hierarchy, ensuring accessibility compliance, or defining component layouts for a feature.
---

# UI/UX Design Skill

## Overview

Apply visual and interaction design methodology to create user-centered interfaces. This skill provides a structured
approach to designing user flows, defining interaction patterns, establishing visual hierarchy, organizing components,
ensuring accessibility, and planning responsive layouts.

UI/UX design is not decoration added after functionality is built. It is a systematic process that shapes how users
perceive, understand, and interact with a feature. Good design makes complex systems feel simple. Poor design makes
simple systems feel impossible. The methodology proceeds from user goals to interaction patterns to visual
implementation.

## User Flow Mapping

User flows document how users navigate through a feature to accomplish goals. A complete flow captures entry points,
decision branches, success paths, and error recovery.

### Entry Points

Identify all ways users arrive at the feature:

**Direct entry:**

- Navigation menu selections
- URL deep links
- Dashboard shortcuts
- Search results
- Notification actions

**Contextual entry:**

- Links from related features
- Actions from list views
- Redirect from authentication
- Progressive disclosure expansions

**External entry:**

- Email links and shared URLs
- Third-party integrations
- Mobile app deep links

Document each entry point with its expected user state: What do users know when they arrive? What context should carry
forward?

### Primary Paths

Map the main routes through the feature:

1. Define the starting state and user goal
2. List each screen or state in sequence
3. Identify the action triggering each transition
4. Note what data carries between states
5. Define the success endpoint and confirmation

Primary paths should be short. Count the steps. If a common task requires more than three steps, investigate whether
steps can be combined or eliminated.

### Exit Points

Map all ways users leave the feature:

**Success exits:** Task completed, save and return later, delegate to another user.

**Abandonment exits:** Cancel action, navigate away, browser close, session timeout.

**Error exits:** Validation failure, permission denied, system error, resource not found.

For each exit, define what state persists. Can users return to exactly where they left off?

### Error States

Design error handling as part of the flow:

- What errors can occur at each step?
- How are errors communicated?
- What recovery options exist?
- How does the user return to a valid state?

Errors should be specific, actionable, and recoverable. "Something went wrong" helps no one. "Email already
registered—log in instead?" provides a path forward.

## Interaction Patterns

Interaction patterns define how users manipulate interface elements.

### Click/Tap Interactions

- Touch targets minimum 44x44 pixels
- Visual feedback on press (hover, press, active states)
- Distinguish single-click from double-click actions
- Confirm destructive actions before execution

### Hover Interactions

- Reveal additional options (with touch alternatives)
- Show tooltips for icon-only controls
- Preview content before navigation
- Highlight related elements

Never hide critical functionality behind hover alone. Touch devices have no hover state.

### Drag Interactions

- Reordering lists and moving between containers
- Resizing elements
- Clear affordances for draggable elements
- Show drop targets during drag
- Keyboard alternatives for all drag operations

### Gesture Support

- Swipe for navigation and dismissal
- Pinch for zoom
- Pull for refresh
- Long press for context menus

Gestures must be discoverable. Provide visual hints or onboarding. Always provide button alternatives.

### Keyboard Navigation

- Logical and complete tab order
- Visible focus indicators
- Arrow keys navigate within components
- Escape dismisses modals and menus
- Enter activates focused elements
- Shortcuts accelerate common actions

Document the keyboard model for each interactive component.

## Visual Hierarchy

Visual hierarchy guides attention and communicates importance.

### Layout Principles

**Proximity:** Group related elements. Space separates unrelated elements. Users perceive proximity as relationship.

**Alignment:** Establish clear alignment axes. Misalignment creates visual noise. Use a grid system for consistency.

**Repetition:** Consistent patterns reduce cognitive load. Same types of elements should look the same throughout.

**Contrast:** Important elements stand out. De-emphasize secondary elements. Use contrast to create visual entry points.

### Typography

- Clear type scale with distinct levels (headline, title, body, caption)
- Consistent heading hierarchy throughout
- 4.5:1 contrast minimum for body text
- Line length 45-75 characters for comfortable reading
- Weight and size for hierarchy, not decoration

### Spacing System

- Define a spacing scale (4px, 8px, 16px, 24px, 32px, 48px)
- Consistent spacing between elements
- Increase spacing to separate major sections
- Decrease spacing to group related elements
- Consistent padding within components

### Color Application

- Limited palette with clear purposes
- Reserve bright colors for calls-to-action
- Consistent color for state (success, warning, error)
- Sufficient contrast for all color combinations
- Never rely on color alone to convey information

## Component Hierarchy

Organize interface elements using atomic design principles.

### Atoms

Smallest indivisible elements: buttons, input fields, labels, icons, checkboxes, radio buttons, toggles. Define all
states: default, hover, focus, active, disabled, error, success.

### Molecules

Functional combinations of atoms: search field (input + button + icon), form field (label + input + help text + error
message), card header (icon + title + action button), navigation item (icon + label + badge).

### Organisms

Complex components forming distinct sections: navigation bar, form sections, data tables, card grids, modal dialogs,
sidebars. Document variants, states, and responsive behavior.

### Templates and Pages

Templates define page-level structure: layout grids, content regions, navigation placement. Pages are template instances
with real content that validate the design system works with actual data.

## Accessibility

Design for all users, including those using assistive technologies.

### WCAG Guidelines

**Perceivable:** Text alternatives for non-text content, captions for multimedia, content presentable in different ways,
distinguishable content.

**Operable:** Keyboard accessible, sufficient time to interact, no seizure triggers, navigation aids.

**Understandable:** Readable text, predictable operation, error prevention and correction.

**Robust:** Compatible with assistive technologies, valid semantic markup.

### Keyboard Navigation

- Logical tab order matching visual layout
- Visible focus indicators on all interactive elements
- Skip links for repeated navigation
- Focus trapping within modals
- Focus management on dynamic content changes

### Screen Reader Support

- Semantic HTML structure (headings, landmarks, lists)
- ARIA labels for icons and interactive elements
- Live regions for dynamic updates
- Alternative text for images
- Table headers for data tables

### Color Contrast

- 4.5:1 for normal text
- 3:1 for large text and UI components
- Do not convey information through color alone
- Test with color blindness simulators

## Responsive Design

Design interfaces that adapt to any screen size.

### Breakpoints

- Small: 320px-767px (phones)
- Medium: 768px-1023px (tablets)
- Large: 1024px-1439px (laptops)
- Extra large: 1440px+ (monitors)

Document how layouts transform at each breakpoint.

### Mobile-First Approach

1. Design mobile experience first
2. Ensure core functionality at minimum width
3. Progressively enhance for larger screens
4. Add complexity only when space permits

Mobile-first forces focus on essential content and actions.

### Progressive Enhancement

- Core content and functionality work everywhere
- Enhanced interactions for capable browsers
- Advanced features for desktop users
- Graceful degradation when features unavailable

### Touch Considerations

- 44x44 pixel minimum touch targets
- Adequate spacing between targets
- Bottom-of-screen placement for primary actions (thumb-friendly)
- Avoid hover-dependent interactions
- Support native platform gestures

## Output Format

Produce a `ui-design.md` file documenting the complete interface design.

```markdown
---
phase: ui-design
status: complete
screens: [count]
components: [count]
flows: [count]
---

# UI/UX Design

## User Flows

### [Flow Name]

**Goal:** [What users accomplish] **Entry:** [How users arrive] **Steps:**

1. [Screen/State] — [User action] → [Next screen]
2. [Screen/State] — [User action] → [Next screen] **Success:** [Completion state and confirmation] **Errors:** [Error
   states and recovery]

## Screen Designs

### [Screen Name]

**Purpose:** [What this screen accomplishes] **Entry:** [How users arrive] **Layout:** [Description or wireframe
reference] **Components:** [Component list with purposes] **Actions:** [Available actions and results] **States:**
Default, Loading, Empty, Error

## Component Specifications

### [Component Name]

**Type:** [Atom/Molecule/Organism] **Purpose:** [What it does] **Variants:** [List of variants] **States:** [With
descriptions] **Accessibility:** [ARIA requirements, keyboard behavior]

## Interaction Patterns

### [Pattern Name]

**Trigger:** [What initiates] **Behavior:** [What happens] **Feedback:** [Visual feedback] **Keyboard:** [Keyboard
equivalent]

## Responsive Behavior

### Small (320-767px)

[Layout adaptations]

### Medium (768-1023px)

[Layout adaptations]

### Large (1024px+)

[Layout adaptations]

## Accessibility Checklist

- [ ] All interactive elements keyboard accessible
- [ ] Focus indicators visible
- [ ] Color contrast ratios met
- [ ] Screen reader labels complete
- [ ] Error messages descriptive
```

Include wireframes or mockups as appropriate. Document all states and edge cases.
