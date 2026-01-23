---
name: api-design
description:
  This skill should be used when designing REST or GraphQL APIs, defining endpoint contracts, planning request/response
  schemas, implementing versioning strategies, or establishing API error handling conventions.
---

# API Design Skill

## Overview

Design API contracts that are consistent, predictable, and easy to consume. This skill provides a methodology for
defining endpoints, structuring requests and responses, handling errors uniformly, and planning for evolution through
versioning. Effective API design enables clients to integrate confidently while allowing the backend to evolve without
breaking existing consumers.

API design is contract-first thinking. Define the interface before implementation. The contract becomes the source of
truth that guides both client and server development, documentation, and testing.

## REST Conventions

REST APIs follow resource-oriented design principles. Apply these conventions consistently across all endpoints.

### Resource Naming

Name resources using nouns, not verbs. Resources represent entities in the domain.

**Naming rules:**

- Use plural nouns for collections: `/users`, `/orders`, `/products`
- Use singular identifiers for specific resources: `/users/{id}`, `/orders/{orderId}`
- Nest resources to express relationships: `/users/{id}/orders`, `/orders/{id}/items`
- Keep URLs lowercase with hyphens for multi-word resources: `/order-items`, `/payment-methods`
- Avoid actions in URLs: use `/orders` with POST, not `/createOrder`

**Hierarchy depth:**

- Limit nesting to two levels maximum: `/users/{id}/orders` is acceptable
- Avoid deep nesting: `/users/{id}/orders/{orderId}/items/{itemId}/options` is too deep
- Provide direct access to deeply nested resources: `/order-items/{id}` instead of deep nesting

### HTTP Methods

Map HTTP methods to CRUD operations consistently.

| Method | Purpose                 | Idempotent | Safe |
| ------ | ----------------------- | ---------- | ---- |
| GET    | Retrieve resource(s)    | Yes        | Yes  |
| POST   | Create new resource     | No         | No   |
| PUT    | Replace entire resource | Yes        | No   |
| PATCH  | Partial update          | Yes        | No   |
| DELETE | Remove resource         | Yes        | No   |

**Method semantics:**

- GET never modifies state. Use query parameters for filtering, sorting, pagination.
- POST creates new resources. Return 201 with Location header pointing to new resource.
- PUT replaces the entire resource. Missing fields are set to defaults or null.
- PATCH updates only specified fields. Use JSON Patch or JSON Merge Patch format.
- DELETE removes the resource. Return 204 with no body on success.

### Status Codes

Return appropriate HTTP status codes that convey meaning to clients.

**Success codes:**

- 200 OK: Successful GET, PUT, PATCH, or DELETE with response body
- 201 Created: Successful POST creating new resource
- 204 No Content: Successful operation with no response body
- 206 Partial Content: Successful GET returning paginated results

**Client error codes:**

- 400 Bad Request: Malformed request syntax, invalid parameters
- 401 Unauthorized: Missing or invalid authentication
- 403 Forbidden: Authenticated but not authorized for this resource
- 404 Not Found: Resource does not exist
- 409 Conflict: Request conflicts with current state (duplicate, version mismatch)
- 422 Unprocessable Entity: Valid syntax but semantic errors in content
- 429 Too Many Requests: Rate limit exceeded

**Server error codes:**

- 500 Internal Server Error: Unexpected server failure
- 502 Bad Gateway: Upstream service failure
- 503 Service Unavailable: Server temporarily unavailable
- 504 Gateway Timeout: Upstream service timeout

### HATEOAS Principles

Hypermedia as the Engine of Application State enables discoverability and self-documentation.

**Include links in responses:**

```json
{
  "id": "order-123",
  "status": "pending",
  "_links": {
    "self": { "href": "/orders/order-123" },
    "cancel": { "href": "/orders/order-123/cancel", "method": "POST" },
    "items": { "href": "/orders/order-123/items" },
    "customer": { "href": "/users/user-456" }
  }
}
```

**Benefits:**

- Clients discover available actions from responses
- URLs can change without breaking clients that follow links
- API becomes self-documenting at runtime

## GraphQL Considerations

GraphQL offers an alternative to REST with a single endpoint and flexible queries.

### Schema Design

Design schemas around domain entities with clear type definitions.

**Type naming:**

- Use PascalCase for types: `User`, `Order`, `PaymentMethod`
- Use camelCase for fields: `firstName`, `createdAt`, `orderTotal`
- Suffix input types: `CreateUserInput`, `UpdateOrderInput`
- Suffix connection types for pagination: `UserConnection`, `OrderEdge`

**Schema structure:**

```graphql
type User {
  id: ID!
  email: String!
  orders(first: Int, after: String): OrderConnection!
}

type Order {
  id: ID!
  status: OrderStatus!
  items: [OrderItem!]!
  total: Money!
}

enum OrderStatus {
  PENDING
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
}
```

### Queries vs Mutations

Separate read operations (queries) from write operations (mutations).

**Queries:**

- Read-only operations that fetch data
- Cacheable and safe to retry
- Support filtering, pagination, and field selection

**Mutations:**

- Write operations that modify state
- Return the modified entity for cache updates
- Use input types for complex parameters

**Mutation naming:**

- Use verb-noun format: `createUser`, `updateOrder`, `cancelSubscription`
- Return the affected entity: `createUser: User!`
- Include success/error information when needed

### Subscriptions

Use subscriptions for real-time updates.

**When to use subscriptions:**

- Live data feeds (stock prices, notifications)
- Collaborative features (document editing, chat)
- Progress tracking (upload status, job completion)

**Subscription design:**

- Keep payloads minimal—send deltas, not full objects
- Include event type to enable client-side filtering
- Provide filters at subscription time to reduce noise

## Request and Response Design

Structure requests and responses consistently across the API.

### Input Validation

Validate all input at the API boundary before processing.

**Validation layers:**

- Syntax validation: JSON well-formed, required fields present
- Type validation: Fields match expected types
- Business validation: Values within acceptable ranges, references exist

**Validation response:**

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      { "field": "email", "code": "INVALID_FORMAT", "message": "Invalid email format" },
      { "field": "quantity", "code": "OUT_OF_RANGE", "message": "Quantity must be between 1 and 100" }
    ]
  }
}
```

### Response Envelopes

Use consistent response structures across all endpoints.

**Success envelope:**

```json
{
  "data": { ... },
  "meta": {
    "requestId": "req-abc123",
    "timestamp": "2026-01-22T10:30:00Z"
  }
}
```

**Collection envelope:**

```json
{
  "data": [ ... ],
  "meta": {
    "total": 150,
    "page": 2,
    "pageSize": 20
  },
  "links": {
    "self": "/users?page=2",
    "first": "/users?page=1",
    "prev": "/users?page=1",
    "next": "/users?page=3",
    "last": "/users?page=8"
  }
}
```

### Pagination

Implement pagination for all collection endpoints.

**Offset-based pagination:**

- Use `page` and `pageSize` or `offset` and `limit` parameters
- Simple to implement, supports jumping to specific pages
- Performance degrades with deep offsets

**Cursor-based pagination:**

- Use opaque cursor tokens (`after`, `before`)
- Better performance for large datasets
- Cannot jump to arbitrary pages

**Pagination metadata:**

- Include total count when feasible (omit for expensive counts)
- Provide links to first, previous, next, last pages
- Return empty array (not error) for page beyond results

## Error Handling

Design error responses that help clients understand and recover from failures.

### Error Response Structure

Use a consistent error format across all endpoints.

```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "User not found",
    "details": {
      "resourceType": "User",
      "resourceId": "user-123"
    },
    "requestId": "req-abc123",
    "documentation": "https://api.example.com/docs/errors#RESOURCE_NOT_FOUND"
  }
}
```

**Error fields:**

- `code`: Machine-readable error identifier (constant across locales)
- `message`: Human-readable description (can be shown to users)
- `details`: Additional context specific to the error type
- `requestId`: Correlation ID for debugging
- `documentation`: Link to error documentation

### Error Codes

Define a catalog of error codes organized by category.

**Authentication errors:**

- `AUTH_TOKEN_MISSING`: No authentication token provided
- `AUTH_TOKEN_INVALID`: Token malformed or signature invalid
- `AUTH_TOKEN_EXPIRED`: Token has expired
- `AUTH_CREDENTIALS_INVALID`: Username or password incorrect

**Authorization errors:**

- `FORBIDDEN`: User lacks permission for this action
- `RESOURCE_ACCESS_DENIED`: User cannot access this specific resource
- `SCOPE_INSUFFICIENT`: Token lacks required scope

**Validation errors:**

- `VALIDATION_ERROR`: Request failed validation (details in array)
- `INVALID_FORMAT`: Field format is incorrect
- `REQUIRED_FIELD`: Required field is missing
- `OUT_OF_RANGE`: Value outside acceptable range

**Resource errors:**

- `RESOURCE_NOT_FOUND`: Requested resource does not exist
- `RESOURCE_ALREADY_EXISTS`: Conflict with existing resource
- `RESOURCE_CONFLICT`: State conflict prevents operation

### Rate Limiting

Communicate rate limits clearly to clients.

**Rate limit headers:**

- `X-RateLimit-Limit`: Maximum requests allowed in window
- `X-RateLimit-Remaining`: Requests remaining in current window
- `X-RateLimit-Reset`: Unix timestamp when window resets
- `Retry-After`: Seconds to wait before retrying (on 429)

**Rate limit error:**

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests",
    "details": {
      "limit": 100,
      "window": "1 minute",
      "retryAfter": 42
    }
  }
}
```

## Versioning Strategy

Plan for API evolution from the start.

### URL Versioning

Include version in the URL path.

```
/v1/users
/v2/users
```

**Advantages:**

- Explicit and visible in requests
- Easy to route at infrastructure level
- Clear documentation per version

**Disadvantages:**

- Requires URL changes when upgrading
- Can lead to version proliferation

### Header Versioning

Specify version in request headers.

```
Accept: application/vnd.api.v1+json
API-Version: 2
```

**Advantages:**

- Clean URLs that remain stable
- Version as content negotiation

**Disadvantages:**

- Less visible and harder to test
- Requires header management

### Deprecation Strategy

Manage the lifecycle of API versions.

**Deprecation process:**

1. Announce deprecation with timeline (minimum 6 months)
2. Add `Deprecation` header to responses with sunset date
3. Update documentation to recommend migration
4. Provide migration guides and tooling
5. Monitor usage and reach out to remaining consumers
6. Remove version after sunset date

**Deprecation headers:**

```
Deprecation: true
Sunset: Sat, 01 Jul 2026 00:00:00 GMT
Link: <https://api.example.com/docs/migration/v1-to-v2>; rel="deprecation"
```

## Authentication

Secure API access with appropriate authentication mechanisms.

### API Keys

Use API keys for server-to-server communication.

**API key best practices:**

- Transmit in headers, not query strings: `X-API-Key: key123`
- Support key rotation with overlap period
- Scope keys to specific permissions
- Set expiration dates on keys
- Log key usage for auditing

### OAuth 2.0 and JWT

Use OAuth for user-context authentication.

**Token handling:**

- Access tokens: Short-lived (15 minutes to 1 hour)
- Refresh tokens: Long-lived, stored securely
- Token placement: `Authorization: Bearer {token}`

**JWT claims:**

- `sub`: Subject (user ID)
- `iss`: Issuer (identity provider)
- `exp`: Expiration timestamp
- `scope`: Granted permissions
- `aud`: Intended audience (API identifier)

### Security Headers

Include security headers in all responses.

```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Cache-Control: no-store
```

## Documentation

Document APIs thoroughly for consumer success.

### OpenAPI Specification

Use OpenAPI (Swagger) for REST API documentation.

**Document comprehensively:**

- All endpoints with descriptions
- Request and response schemas
- Authentication requirements
- Error responses with examples
- Rate limits and quotas

**Example OpenAPI structure:**

```yaml
openapi: 3.0.3
info:
  title: User Service API
  version: 1.0.0
paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
      responses:
        "200":
          description: User list
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/UserList"
```

### GraphQL Introspection

Leverage GraphQL's built-in documentation capabilities.

**Documentation features:**

- Schema introspection queries
- Field and type descriptions
- Deprecation annotations
- Tools like GraphiQL and GraphQL Playground

## Output Format

API design produces specification documents and contracts.

### api-design.md

```markdown
---
phase: api-design
status: complete
endpoints: [count]
authentication: [method]
versioning: [strategy]
---

# API Design

## Overview

[Brief description of the API purpose and scope]

## Authentication

[Authentication mechanism and flow]

## Endpoints

### [Resource Name]

#### GET /resource

[Description, parameters, responses]

#### POST /resource

[Description, request body, responses]

[Continue for all endpoints]

## Error Codes

[Error code catalog with descriptions]

## Rate Limits

[Rate limiting policy]

## Versioning

[Versioning strategy and deprecation policy]
```

### openapi.yaml

Provide a complete OpenAPI specification that can be used for:

- Documentation generation
- Client SDK generation
- Request validation
- Mock server creation

## Principles

### Design for Consumers

Prioritize developer experience. The API should be intuitive to use without constantly referencing documentation.
Consistent patterns reduce cognitive load and accelerate integration.

### Be Explicit, Not Clever

Avoid ambiguity. Explicit naming and clear semantics prevent misuse. When in doubt, choose the more verbose but clearer
option.

### Plan for Evolution

Assume requirements will change. Design contracts that can evolve without breaking existing consumers. Versioning and
deprecation strategies are not afterthoughts—they are core to sustainable API design.

### Fail Gracefully

Provide actionable error messages. Clients should understand what went wrong and how to fix it. Include error codes,
field references, and documentation links.
