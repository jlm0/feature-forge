---
name: code-exploration
description:
  This skill should be used when exploring an unfamiliar codebase, tracing execution paths, mapping architecture layers,
  understanding how features are implemented, or building context before making changes. It teaches systematic
  navigation from entry points through call chains to dependencies.
---

# Code Exploration

## Overview

Code exploration is a systematic methodology for understanding unfamiliar codebases. Rather than reading code randomly,
follow a disciplined approach: identify entry points, trace call chains, map dependencies, and recognize architecture
patterns. This methodology applies to any codebase regardless of language, framework, or size.

The goal is to build a mental model of the system that enables confident navigation and informed decision-making before
making any changes. Effective exploration answers key questions: Where does execution begin? How does data flow? What
are the system boundaries? What patterns govern the design?

Resist the temptation to dive into implementation details immediately. Start broad, understand the shape of the system,
then progressively narrow focus to areas relevant to the task at hand.

## Entry Point Identification

Begin exploration at the natural starting points of execution. Entry points reveal the system's boundaries and primary
interfaces.

### Locate Primary Entry Points

Start with obvious execution entry points:

- Main files: `main.py`, `index.js`, `App.tsx`, `main.go`, `Program.cs`
- Package entry points: check `package.json` "main" field, `setup.py` entry_points, `Cargo.toml` [[bin]]
- Application bootstrapping: `app.py`, `server.js`, `Application.java`
- CLI entry points: argument parsers, command definitions

### Identify Request Handlers

For web applications and services, locate request handling:

- Router definitions: Express routes, Flask blueprints, Rails routes.rb
- API handlers: REST endpoints, GraphQL resolvers, gRPC service definitions
- Middleware chains: authentication, logging, error handling
- Event listeners: message queue consumers, webhook handlers

### Examine Configuration Files

Configuration files reveal architectural decisions:

- Build configuration: `webpack.config.js`, `tsconfig.json`, `Makefile`
- Dependency manifests: `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`
- Application config: `.env` patterns, `config/` directories, YAML/JSON settings
- Infrastructure: `docker-compose.yml`, Kubernetes manifests, terraform files

### Check Documentation First

Before diving into code, extract guidance from documentation:

- README files at repository root and in subdirectories
- CONTRIBUTING guides for development patterns
- Architecture Decision Records (ADRs) if present
- API documentation, OpenAPI/Swagger specs
- Inline architecture diagrams or design docs

## Call Chain Tracing

Once entry points are identified, trace how execution flows through the system. Follow the data, not just the code.

### Follow Function Calls

From each entry point, trace the call hierarchy:

1. Start at the entry point function
2. Identify each function call within it
3. Navigate to each called function
4. Repeat recursively until reaching leaf functions or external calls

Use IDE "go to definition" or grep patterns like `function_name\(` to locate definitions.

### Map Data Flow

Track how data transforms as it moves through the system:

- Input sources: request bodies, query parameters, environment variables, file reads
- Transformation points: parsing, validation, normalization, business logic
- Output destinations: database writes, API responses, file outputs, events emitted
- Data shapes: note how types/schemas change between layers

Pay particular attention to trust boundaries where external data enters the system. These are security-critical points
where validation and sanitization should occur. Note whether the codebase validates early (at entry) or late (at use).

### Identify Side Effects

Mark functions that produce side effects:

- Database operations: reads, writes, transactions
- External API calls: HTTP requests, service invocations
- File system operations: reads, writes, deletions
- State mutations: global variables, caches, sessions
- Event emissions: pub/sub, webhooks, notifications

### Note Control Flow Patterns

Observe how the code handles branching and error cases:

- Error handling: try/catch patterns, Result types, error propagation
- Conditional logic: feature flags, permission checks, A/B tests
- Async patterns: promises, async/await, callbacks, coroutines
- Loop patterns: iteration, recursion, generators

## Dependency Mapping

Catalog both external and internal dependencies to understand what the system relies on and how modules connect.

### External Dependencies

Document third-party dependencies:

- Read dependency manifests: `package.json`, `requirements.txt`, `go.mod`
- Note major frameworks: React, Django, Spring, Rails
- Identify utility libraries: lodash, moment, axios
- Catalog specialized dependencies: ORMs, authentication, caching, queuing
- Check for version constraints and security advisories
- Distinguish between runtime and development dependencies
- Note peer dependencies and version compatibility requirements

### Internal Module Dependencies

Map how internal modules connect:

- Trace import/require statements between files
- Identify shared utilities and common code
- Note which modules depend on which
- Build a dependency graph (even mentally)
- Look for layered architecture: controllers -> services -> repositories

### Detect Circular Dependencies

Watch for circular dependency patterns:

- Module A imports Module B which imports Module A
- Often indicates architectural issues
- Check for barrel files (index.js re-exports) that mask cycles
- Note any dependency injection patterns used to break cycles

### Understand Package Boundaries

Identify logical groupings:

- Monorepo packages in `packages/` or workspaces
- Feature-based directories: `features/auth/`, `features/billing/`
- Layer-based directories: `controllers/`, `services/`, `models/`
- Domain boundaries in domain-driven designs

## Architecture Layer Recognition

Identify the architectural patterns and layers to understand the system's design philosophy.

### Identify Architectural Patterns

Recognize common patterns:

- **MVC**: Models, Views, Controllers separation
- **Layered**: Presentation -> Business Logic -> Data Access
- **Hexagonal/Ports-Adapters**: Core domain isolated from infrastructure
- **Microservices**: Independent deployable services
- **Event-driven**: Pub/sub, message queues, event sourcing
- **Serverless**: Function-as-a-service handlers

### Map Layer Boundaries

For each layer, identify:

- Entry points into the layer
- Public interfaces exposed to other layers
- Dependencies on lower layers
- Data transformations at boundaries

### Recognize Abstraction Levels

Note how abstraction is used:

- Interface definitions vs implementations
- Abstract base classes and inheritance hierarchies
- Dependency injection and inversion of control
- Repository patterns abstracting data access
- Facade patterns simplifying complex subsystems

### Identify Cross-Cutting Concerns

Find aspects that span multiple layers:

- Logging and observability
- Authentication and authorization
- Caching strategies
- Transaction management
- Error handling and reporting
- Rate limiting and throttling
- Feature flags and configuration
- Internationalization and localization

Cross-cutting concerns often appear as middleware, decorators, aspects, or interceptors. Understanding how these are
implemented reveals important patterns for adding similar functionality.

## Search Techniques

Use targeted search strategies to find specific patterns and understand relationships.

### Grep Patterns for Discovery

Effective search patterns:

```bash
# Find function definitions
grep -rn "function functionName" --include="*.js"
grep -rn "def function_name" --include="*.py"
grep -rn "func FunctionName" --include="*.go"

# Find class definitions
grep -rn "class ClassName" --include="*.{ts,js,py}"

# Find imports of a module
grep -rn "from module import\|import module" --include="*.py"
grep -rn "require.*module\|import.*module" --include="*.js"

# Find usages of a function
grep -rn "functionName\s*(" --include="*.{ts,js}"

# Find TODO/FIXME comments
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.{ts,js,py}"

# Find error handling
grep -rn "catch\s*(\|except\s" --include="*.{ts,js,py}"
```

### Glob Patterns for Structure

Use file patterns to understand structure:

```bash
# Find all entry points
**/main.{js,ts,py,go}
**/index.{js,ts}
**/app.{js,ts,py}

# Find all test files
**/*test*.{js,ts,py}
**/*spec*.{js,ts,py}
**/test_*.py

# Find configuration files
**/*.config.{js,ts,json}
**/config/**/*.{yml,yaml,json}

# Find type definitions
**/*.d.ts
**/types/**/*.ts
**/interfaces/**/*.ts
```

### Symbol Navigation

When tools support it, use symbol-based navigation:

- Find all references to a symbol
- Go to definition/implementation
- Find all implementations of an interface
- Call hierarchy (incoming/outgoing calls)
- Type hierarchy for class inheritance

## Documentation as Context

Extract intent and history from documentation sources.

### Inline Comments

Look for comments that explain "why" not "what":

- Function docstrings explaining purpose and usage
- Complex algorithm explanations
- Historical context for unusual code
- Warning comments about edge cases

### Formal Documentation

Check for structured documentation:

- JSDoc, docstrings, godoc comments
- README files in subdirectories explaining module purpose
- CHANGELOG for feature history
- Architecture decision records for design rationale

### Code Annotations

Note special markers:

- `TODO`: Planned work
- `FIXME`: Known bugs or issues
- `HACK`: Workarounds requiring attention
- `DEPRECATED`: Features being phased out
- `@security`: Security-sensitive code
- `@performance`: Performance-critical sections

### Git History as Documentation

Use version control for context:

- Blame to understand who changed what and when
- Commit messages explaining changes
- PR descriptions for feature context
- Tags marking releases and milestones
- Branch naming conventions revealing workflow
- Merge commit messages for feature integration history

When encountering unusual or confusing code, check the git history. The original commit message or PR often explains the
reasoning behind the implementation choice.

## Output Format

Produce an exploration.md file containing the following sections. This document serves as the foundation for all
subsequent work in the codebase, providing context that other agents and future sessions can reference.

### Project Structure Overview

Document the high-level directory structure:

```markdown
## Project Structure

- `/src` - Main application source
  - `/api` - REST API handlers
  - `/services` - Business logic
  - `/models` - Data models and database
  - `/utils` - Shared utilities
- `/tests` - Test suites
- `/config` - Configuration files
- `/scripts` - Build and deployment scripts
```

### Key Entry Points Identified

List discovered entry points with their purpose:

```markdown
## Entry Points

- `src/index.ts` - Application bootstrap, server startup
- `src/api/routes.ts` - API route definitions
- `src/workers/processor.ts` - Background job processor
- `scripts/migrate.ts` - Database migration runner
```

### Architecture Patterns Recognized

Document identified patterns:

```markdown
## Architecture

**Pattern**: Layered architecture with repository pattern

**Layers**:

1. API Layer (`/api`) - HTTP handlers, request validation
2. Service Layer (`/services`) - Business logic, orchestration
3. Repository Layer (`/repositories`) - Data access, queries
4. Model Layer (`/models`) - Domain entities, schemas

**Cross-cutting**: Middleware for auth, logging, error handling
```

### Module Dependency Map

Describe how modules connect:

```markdown
## Dependencies

**External**:

- Express 4.x - HTTP server
- Prisma 4.x - Database ORM
- Redis - Caching and sessions

**Internal Module Flow**: API Routes -> Controllers -> Services -> Repositories -> Database

**Key Relationships**:

- AuthService depends on UserRepository, TokenService
- OrderService depends on ProductService, PaymentService
```

### Notable Findings and Patterns

Record observations that inform future work:

```markdown
## Notable Findings

- Authentication uses JWT with refresh token rotation
- All database writes go through transaction wrapper
- Feature flags controlled via environment variables
- Legacy code in `/src/legacy` - migration in progress
- Circular dependency between User and Team modules
- No integration tests for payment flow
```

### Areas Requiring Further Investigation

Note questions that arose during exploration but could not be answered:

```markdown
## Open Questions

- How is session invalidation handled on password change?
- What triggers the background job processor?
- Is there rate limiting on the public API?
- How are database migrations handled in production?
```

Include confidence levels where appropriate. Mark assumptions clearly so they can be validated during implementation.
