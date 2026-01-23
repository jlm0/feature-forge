---
name: frontend-engineering
description:
  This skill should be used when designing frontend architecture, planning state management, structuring components,
  implementing data fetching strategies, or optimizing frontend performance for a feature.
---

# Frontend Engineering Skill

## Overview

Apply frontend technical design methodology to create robust, maintainable, and performant user interfaces. This skill
provides a structured approach to state management, component architecture, data fetching, performance optimization,
testing strategy, and build configuration.

Frontend engineering is not simply translating designs to code. It is making architectural decisions that determine how
the interface scales, performs, and evolves. Poor frontend architecture creates technical debt that compounds with every
feature addition. The methodology addresses the unique challenges of frontend development: managing complex UI state,
coordinating asynchronous data, optimizing for perceived performance, and maintaining consistency across a growing
component library.

## State Management

State management determines how data flows through the application and how components stay synchronized.

### Local vs Global State

**Local state** stays within a component or its immediate children:

- Form input values during editing
- UI state (expanded/collapsed, selected tab)
- Temporary validation errors
- Animation state
- Component-specific loading indicators

**Global state** is accessed by distant parts of the application:

- Authenticated user information
- Application-wide settings and preferences
- Shared entity caches
- Cross-cutting UI state (theme, locale)
- Notification queues

Start with local state by default. Lift state only when sharing becomes necessary. Premature globalization creates
unnecessary coupling and re-render cascades.

### State Machines

Model complex state transitions explicitly:

- Multi-step processes (wizards, onboarding)
- States with specific allowed transitions
- Complex loading/error/success patterns
- Features where invalid state combinations cause bugs

State machine components: states (finite set of conditions), events (triggers), transitions (rules), guards
(conditions), actions (side effects).

State machines make impossible states impossible. Define valid states explicitly rather than tracking multiple boolean
flags that can combine incorrectly.

### Derived State

Compute values from source state rather than storing redundantly:

- Filtered lists from full data plus filter criteria
- Computed totals from line items
- Formatted display values from raw data
- Validation status from form values

Implement via selectors, memoized computations, or computed properties. Never store state that can be
calculated—redundant state creates synchronization bugs.

### State Normalization

Structure shared state for consistency and performance:

- Store entities in flat maps keyed by ID
- Store relationships as ID references, not nested objects
- Maintain separate collections for different entity types
- Denormalize at consumption, not storage

Benefits: single source of truth, efficient updates without deep cloning, consistent data across components, simpler
cache invalidation.

## Component Architecture

Component architecture determines code organization, reusability, and maintainability.

### Container and Presentational Pattern

**Container components:** Connect to state management, fetch and submit data, handle business logic, pass data and
callbacks to children, minimal rendering markup.

**Presentational components:** Receive all data via props, emit events for user actions, focus on visual rendering,
reusable across different data sources, easy to test in isolation.

This separation enables testing presentational logic without state management setup and reusing visual components with
different data sources.

### Composition Over Inheritance

Build complex components by combining simpler ones:

- Slot-based composition: Parent provides child content
- Render props: Parent provides render function
- Higher-order components: Functions that wrap components
- Hooks: Reusable stateful logic

Benefits: flexible recombination, clearer data flow, easier understanding of responsibilities, simpler testing. Avoid
deep inheritance hierarchies.

### Prop Drilling vs Context

**Prop drilling** (passing through intermediate components): Clear data flow, explicit dependencies, works for shallow
trees, verbose with deep nesting.

**Context** (implicit availability): Avoids intermediates, hidden dependencies, can cause unnecessary re-renders.

Guidelines: Prefer props for data varying between instances. Use context for ambient data (theme, locale, auth). Limit
context scope to minimize re-render impact.

### Component Boundaries

**Too large:** Multiple unrelated state variables, many pass-through props, difficult to name, changes risk breaking
unrelated parts.

**Too small:** Trivial implementation adding indirection, tightly coupled to single parent, no reuse potential.

Extract when extraction improves clarity, reusability, or testability—not merely to reduce line count.

## Data Fetching

Data fetching connects the frontend to backend services.

### Client Architecture

**REST clients:** Base URL and default headers, request/response interceptors, authentication token injection,
standardized error parsing.

**GraphQL clients:** Endpoint and cache configuration, queries and mutations as documents, cache policies per operation,
optimistic update support.

**Real-time connections:** WebSocket for bidirectional, Server-Sent Events for server push, polling when simplicity
preferred, reconnection with exponential backoff.

### Caching Strategies

- **Cache-first:** Return cached immediately, refresh in background. Use for slowly changing data.
- **Network-first:** Attempt network, fall back to cache. Use for data that must be fresh.
- **Stale-while-revalidate:** Return stale, update asynchronously. Balance freshness and responsiveness.
- **Network-only:** Always fetch. Use for sensitive or real-time critical data.

### Optimistic Updates

1. Apply change to local state immediately
2. Show change in UI
3. Send mutation to server
4. On success: Confirm local state
5. On failure: Rollback local state, notify user

Use for high-confidence operations (toggling, incrementing) with low-cost rollback. Avoid for complex validation or
significant consequences.

### Error Handling

**Error categories:** Network errors (connection, timeout), client errors (4xx: validation, auth), server errors (5xx:
backend failures).

**Handling patterns:** User-friendly messages, retry actions for transient failures, preserve user input, log for
debugging, circuit breakers for repeated failures.

### Loading States

- Track loading state per query, not globally
- Show indicators appropriate to expected duration
- Skeleton screens for predictable content shapes
- Debounce rapid changes to prevent flicker
- Progressive loading for large datasets

## Performance

Optimize frontend performance for user experience.

### Bundle Size

**Analysis:** Audit bundle composition with source maps, identify large dependencies, detect duplicate code.

**Reduction:** Replace heavy libraries with lighter alternatives, import only needed functions, remove unused code,
defer rarely-used features.

### Lazy Loading

**Code splitting:** By route (each page separate), by feature (load when accessed), by component (large components on
render).

**Asset loading:** Images below fold, defer non-critical CSS, preload likely navigations, intersection observers for
scroll-triggered loads.

### Memoization

**Component memoization:** Memoize components rendering frequently with same props. Define comparison functions for
complex props.

**Computation memoization:** Memoize derived state calculations, cache expensive transformations, invalidate
appropriately.

**Function memoization:** Stabilize callback references, memoize event handlers with dependencies, avoid creating
functions on every render.

### Virtualization

Render only visible items in large lists (100+ items). Calculate visible window based on scroll, render items in view
plus buffer, recycle DOM elements. Handle variable-height items with measurement.

### Rendering Performance

- Minimize render count through memoization
- Batch state updates to reduce render passes
- Avoid layout thrashing (read then write, not interleaved)
- CSS transforms for animations, not layout properties
- Profile with browser DevTools

## Testing Strategy

Verify frontend functionality at appropriate levels.

### Unit Tests

Test utility functions, state management logic (reducers, selectors), component rendering with various props, event
handlers, data transformations.

Characteristics: Fast execution (milliseconds), no external dependencies, deterministic results, one concern per test.

### Integration Tests

Test component trees rendering together, state management integration, form submission flows, multi-step interactions,
component communication.

Characteristics: Realistic component combinations, mock external services not internal modules, verify user-perceivable
outcomes, test error states.

### End-to-End Tests

Test critical user journeys, authentication flows, payment and checkout, core feature happy paths, cross-browser
compatibility.

Characteristics: Real or realistic backend, interact through actual UI, slower execution (acceptable for critical
paths).

### Coverage Strategy

- High coverage of business logic and state management
- Moderate coverage of component behavior
- Selective E2E coverage of critical paths
- Focus on behavior, not implementation details

## Build Considerations

Configure build processes for development efficiency and production optimization.

### Bundling

- Development: Fast rebuilds, source maps, hot reload
- Production: Minification, optimization, cache busting
- Environment-specific configurations
- Asset handling (images, fonts, styles)
- Path aliases for cleaner imports

### Tree Shaking

Use ES modules for static analysis. Avoid side effects in module scope. Mark packages as side-effect-free. Verify
effectiveness in bundle analysis.

### Code Splitting

- Route-based for page separation
- Component-based for large features
- Vendor splitting for stable dependencies
- Configure chunk naming for caching
- Set appropriate size thresholds

### Environment Configuration

- Environment variables for configuration
- Separate development, staging, production configs
- Feature flags for gradual rollout
- Never bundle secrets

## Output Format

Produce a `frontend-design.md` file documenting the complete frontend architecture.

```markdown
---
phase: frontend-design
status: complete
components: [count]
state_stores: [count]
api_integrations: [count]
---

# Frontend Design

## State Architecture

### Global State

- **[Store Name]:** [Purpose, shape, update patterns]

### State Machines

- **[Machine Name]:** [States, transitions, guards]

### Derived State

- **[Selector Name]:** [Source data, computation]

## Component Architecture

### Component Tree

[Hierarchical structure]

### [Component Name]

**Type:** [Container/Presentational] **Purpose:** [What it does] **Props:** [Input properties] **State:** [Local state
if any] **Data Flow:** [How data enters and exits]

## Data Fetching

### API Client Configuration

- Base URL: [endpoint]
- Authentication: [strategy]
- Error handling: [approach]

### [Query/Mutation Name]

**Endpoint:** [URL and method] **Caching:** [Strategy] **Error States:** [Handling]

## Performance Considerations

### Code Splitting

- [Chunk]: [Contents, loading trigger]

### Memoization

- [Component/Selector]: [Why memoized, dependencies]

## Testing Plan

### Unit Tests

- [Module]: [Coverage focus]

### Integration Tests

- [Flow]: [Components, assertions]

### E2E Tests

- [Journey]: [Steps, success criteria]

## Build Configuration

### Dependencies

- [Package]: [Purpose, version constraints]

### Environment Variables

- [Variable]: [Purpose, default]
```

Include architecture diagrams where helpful. Reference UI design document for component specifications.
