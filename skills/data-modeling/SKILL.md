---
name: data-modeling
description:
  This skill should be used when designing database schemas, planning entity relationships, implementing migrations,
  establishing indexing strategies, or defining data constraints and validation rules.
---

# Data Modeling Skill

## Overview

Design database schemas that accurately represent the domain while supporting application performance requirements. This
skill provides a methodology for identifying entities, mapping relationships, applying normalization principles, and
planning for schema evolution through migrations.

Data modeling is the foundation of application architecture. A well-designed schema makes queries intuitive, enforces
data integrity at the database level, and scales with application growth. A poorly designed schema creates technical
debt that compounds over time.

## Entity Identification

Begin by identifying the core entities that make up the domain model.

### Domain Entities

Domain entities represent the primary concepts in the business domain. Each entity has identity, attributes, and
behavior.

**Identifying entities:**

- Extract nouns from requirements and user stories
- Look for concepts that have a lifecycle (created, modified, archived)
- Identify things that need to be referenced by other parts of the system
- Consider what users think of as distinct "things" in the domain

**Entity characteristics:**

- Has a unique identity (primary key)
- Has attributes that describe it
- Can exist independently or depend on other entities
- Participates in relationships with other entities

**Example entities:**

- User: account holder with credentials and profile
- Order: purchase transaction with line items
- Product: item available for sale with pricing
- Payment: financial transaction record

### Value Objects

Value objects represent concepts defined by their attributes rather than identity. Two value objects with the same
attributes are interchangeable.

**Value object characteristics:**

- No unique identity needed
- Immutable once created
- Defined by attribute values
- Often embedded within entities

**Example value objects:**

- Address: street, city, postal code, country
- Money: amount and currency
- DateRange: start date and end date
- Coordinates: latitude and longitude

**Storage approaches:**

- Embed as JSON within parent entity
- Flatten into parent table columns
- Create separate table with composite key

### Aggregates

Aggregates are clusters of entities treated as a single unit for data changes. The aggregate root is the entry point.

**Aggregate design rules:**

- Reference other aggregates by ID only
- Maintain consistency within aggregate boundaries
- Keep aggregates small for performance
- Design around transaction boundaries

**Example aggregate:**

```
Order (aggregate root)
├── OrderItem
├── ShippingAddress (value object)
└── BillingAddress (value object)
```

Changes to OrderItems go through the Order aggregate root, ensuring order totals remain consistent.

## Relationship Mapping

Define how entities relate to each other and implement those relationships in the schema.

### One-to-One Relationships

One entity instance relates to exactly one instance of another entity.

**Implementation options:**

- Same table: embed the related data as columns
- Foreign key: reference from child to parent table
- Shared primary key: child uses parent's PK as its own PK

**When to use separate tables:**

- Related data is optional (nullable relationship)
- Related data is accessed separately
- Different access patterns or security requirements
- Large columns that should not always be loaded

**Example:**

```sql
-- User has one Profile (optional, separate access patterns)
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE user_profiles (
  user_id UUID PRIMARY KEY REFERENCES users(id),
  bio TEXT,
  avatar_url VARCHAR(500),
  settings JSONB
);
```

### One-to-Many Relationships

One entity instance relates to multiple instances of another entity.

**Implementation:**

- Add foreign key column to the "many" side
- Foreign key references primary key of the "one" side
- Consider ON DELETE behavior (CASCADE, SET NULL, RESTRICT)

**Example:**

```sql
-- User has many Orders
CREATE TABLE orders (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  status VARCHAR(50) NOT NULL
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
```

### Many-to-Many Relationships

Multiple instances of one entity relate to multiple instances of another.

**Implementation:**

- Create a junction (join) table
- Junction table contains foreign keys to both entities
- Primary key can be composite or synthetic

**Junction table patterns:**

- Simple association: just the two foreign keys
- Association with attributes: additional columns for relationship metadata
- Temporal association: effective dates for historical tracking

**Example:**

```sql
-- Products have many Categories, Categories have many Products
CREATE TABLE product_categories (
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  display_order INT DEFAULT 0,
  PRIMARY KEY (product_id, category_id)
);

CREATE INDEX idx_product_categories_category ON product_categories(category_id);
```

### Polymorphic Relationships

One entity relates to multiple different entity types.

**Implementation approaches:**

**Single Table Inheritance:**

- All types in one table with a type discriminator column
- Unused columns are NULL for types that do not use them
- Simple queries but sparse data

**Class Table Inheritance:**

- Base table with common columns
- Separate tables for type-specific columns
- Normalized but requires joins

**Polymorphic Associations:**

- Foreign key plus type column indicating target table
- Flexible but loses referential integrity

**Example (polymorphic association):**

```sql
-- Comments can belong to Posts, Products, or Users
CREATE TABLE comments (
  id UUID PRIMARY KEY,
  body TEXT NOT NULL,
  commentable_type VARCHAR(50) NOT NULL,  -- 'Post', 'Product', 'User'
  commentable_id UUID NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_comments_target ON comments(commentable_type, commentable_id);
```

## Normalization

Apply normalization to eliminate redundancy and anomalies while balancing against query performance.

### First Normal Form (1NF)

Ensure atomic values and eliminate repeating groups.

**1NF requirements:**

- Each column contains only atomic (indivisible) values
- No repeating groups or arrays in columns
- Each row is unique (has a primary key)

**Violation example:**

```
| id | name | phone_numbers          |
|----|------|------------------------|
| 1  | Alice| 555-1234, 555-5678     |
```

**1NF solution:**

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE phone_numbers (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  phone_number VARCHAR(20) NOT NULL
);
```

### Second Normal Form (2NF)

Remove partial dependencies on composite keys.

**2NF requirements:**

- Must be in 1NF
- All non-key columns depend on the entire primary key
- Only relevant for tables with composite primary keys

**Violation example (composite key order_id, product_id):**

```
| order_id | product_id | product_name | quantity |
```

Product name depends only on product_id, not the full composite key.

**2NF solution:** Move product_name to a products table; keep only order-specific data in the junction table.

### Third Normal Form (3NF)

Remove transitive dependencies.

**3NF requirements:**

- Must be in 2NF
- No non-key column depends on another non-key column
- All columns depend directly on the primary key

**Violation example:**

```
| id | zip_code | city    | state   |
```

City and state depend on zip_code, which depends on id (transitive).

**3NF solution:**

```sql
CREATE TABLE addresses (
  id UUID PRIMARY KEY,
  zip_code VARCHAR(10) REFERENCES zip_codes(code)
);

CREATE TABLE zip_codes (
  code VARCHAR(10) PRIMARY KEY,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(50) NOT NULL
);
```

### Denormalization Trade-offs

Sometimes violate normalization intentionally for performance.

**When to denormalize:**

- Read-heavy workloads where join cost is significant
- Aggregated values that are expensive to compute
- Caching frequently accessed derived data
- Historical snapshots that should not change

**Denormalization strategies:**

- Duplicate columns to avoid joins
- Store computed aggregates (counts, totals)
- Materialize frequently-joined data
- Use read replicas with denormalized views

**Managing denormalized data:**

- Document the denormalization and reasoning
- Implement triggers or application logic to maintain consistency
- Consider eventual consistency where appropriate
- Monitor for drift between normalized and denormalized data

## Indexing Strategy

Design indexes to support query patterns while managing write overhead.

### Primary Keys

Every table needs a primary key for unique identification.

**Primary key options:**

- Natural key: meaningful business identifier (email, ISBN)
- Surrogate key: synthetic identifier (auto-increment, UUID)
- Composite key: multiple columns together

**UUID vs auto-increment:**

- UUID: globally unique, no coordination, larger storage
- Auto-increment: sequential, smaller, reveals ordering
- Consider ULID for sortable unique IDs

### Foreign Keys

Enforce referential integrity at the database level.

**Foreign key benefits:**

- Prevents orphaned records
- Documents relationships in schema
- Enables cascading operations

**CASCADE behavior:**

- ON DELETE CASCADE: delete children when parent deleted
- ON DELETE SET NULL: set FK to NULL when parent deleted
- ON DELETE RESTRICT: prevent deletion if children exist

### Secondary Indexes

Create indexes to support specific query patterns.

**Index selection criteria:**

- Columns frequently used in WHERE clauses
- Columns used in JOIN conditions
- Columns used in ORDER BY
- Columns with high cardinality (many distinct values)

**Index types:**

- B-tree: default, good for equality and range queries
- Hash: fast equality lookups only
- GIN: full-text search, JSONB, arrays
- GiST: geometric data, full-text search

### Composite Indexes

Multi-column indexes for queries filtering on multiple columns.

**Column ordering:**

- Place equality conditions first
- Place range conditions last
- Order matches most common query patterns

**Example:**

```sql
-- Supports: WHERE user_id = ? AND created_at > ?
-- Supports: WHERE user_id = ?
-- Does NOT support: WHERE created_at > ?
CREATE INDEX idx_orders_user_created ON orders(user_id, created_at);
```

### Partial Indexes

Index only rows matching a condition.

**Use cases:**

- Active records only: `WHERE deleted_at IS NULL`
- Recent data only: `WHERE created_at > '2025-01-01'`
- Specific statuses: `WHERE status = 'pending'`

**Example:**

```sql
CREATE INDEX idx_orders_pending ON orders(created_at)
WHERE status = 'pending';
```

## Constraints

Enforce data integrity through database constraints.

### NOT NULL Constraints

Require columns to have values.

**When to use:**

- Required business fields
- Foreign keys (unless nullable relationships)
- Columns that would break application logic if null

### UNIQUE Constraints

Prevent duplicate values.

**Single column:**

```sql
email VARCHAR(255) NOT NULL UNIQUE
```

**Composite unique:**

```sql
UNIQUE (organization_id, email)  -- Email unique within organization
```

### CHECK Constraints

Validate column values against conditions.

**Example constraints:**

```sql
CHECK (quantity > 0)
CHECK (status IN ('pending', 'processing', 'complete'))
CHECK (end_date > start_date)
CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
```

### Foreign Key Constraints

Enforce referential integrity between tables.

**Define relationships:**

```sql
user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE
```

**Cascade options:**

- CASCADE: propagate operation to related rows
- RESTRICT: prevent operation if related rows exist
- SET NULL: set foreign key to NULL
- SET DEFAULT: set foreign key to default value

## Migration Planning

Plan schema changes that can be safely deployed and rolled back.

### Forward-Only Migrations

Design migrations that move forward without backward compatibility requirements.

**Migration structure:**

```sql
-- Migration: 001_create_users.sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

### Rollback Support

Include down migrations for reversibility.

**Rollback considerations:**

- Not all migrations are reversible (data loss)
- Test rollback procedures before deployment
- Document data loss implications

**Reversible migration:**

```sql
-- Up
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- Down
ALTER TABLE users DROP COLUMN phone;
```

### Data Migrations

Handle existing data during schema changes.

**Safe data migration pattern:**

1. Add new column as nullable
2. Backfill data from old column
3. Add NOT NULL constraint
4. Remove old column in separate migration

**Example:**

```sql
-- Step 1: Add nullable column
ALTER TABLE users ADD COLUMN full_name VARCHAR(200);

-- Step 2: Backfill (separate migration or script)
UPDATE users SET full_name = first_name || ' ' || last_name;

-- Step 3: Make required
ALTER TABLE users ALTER COLUMN full_name SET NOT NULL;

-- Step 4: Remove old columns (separate migration, after verification)
ALTER TABLE users DROP COLUMN first_name, DROP COLUMN last_name;
```

## Query Patterns

Design schemas that support efficient query patterns.

### Read vs Write Optimization

Balance schema design for the dominant access pattern.

**Read-optimized patterns:**

- Denormalize frequently joined data
- Add covering indexes
- Precompute aggregates
- Consider materialized views

**Write-optimized patterns:**

- Normalize to reduce update scope
- Minimize indexes
- Use append-only tables
- Consider write-ahead logging

### N+1 Query Prevention

Design schemas and queries to avoid N+1 patterns.

**Problem:**

```python
users = query("SELECT * FROM users")
for user in users:
    orders = query("SELECT * FROM orders WHERE user_id = ?", user.id)  # N queries
```

**Solutions:**

- Eager loading with JOIN
- Batch loading with IN clause
- Denormalize into parent record
- Use data loaders or batch resolvers

**Schema design support:**

- Ensure indexes exist on foreign keys
- Consider embedding small related data
- Design for batch query patterns

## Output Format

Data modeling produces schema documentation and migration files.

### data-model.md

```markdown
---
phase: data-modeling
status: complete
entities: [count]
relationships: [count]
migrations: [count]
---

# Data Model

## Overview

[Brief description of the domain and data requirements]

## Entities

### [Entity Name]

[Description and purpose]

**Attributes:** | Column | Type | Constraints | Description | |--------|------|-------------|-------------| | id | UUID
| PK | Unique identifier | | ... | ... | ... | ... |

**Relationships:**

- Has many [related entity]
- Belongs to [parent entity]

[Continue for all entities]

## Indexes

[Index definitions with rationale]

## Migrations

[Migration sequence with descriptions]
```

### schema.sql

Provide a complete schema definition:

```sql
-- Schema version: 1.0.0
-- Generated: [date]

CREATE TABLE entity_name (
  -- columns
);

CREATE INDEX idx_name ON table(columns);
```

## Principles

### Model the Domain First

Start with business concepts, not database features. The schema should reflect how the business thinks about its data.
Technical optimizations come after the domain model is clear.

### Enforce Integrity at the Database

Use constraints, foreign keys, and checks. The database is the last line of defense for data integrity. Application bugs
should not be able to corrupt data.

### Plan for Change

Assume the schema will evolve. Design migrations that can be applied incrementally. Avoid irreversible operations when
possible. Document decisions for future maintainers.

### Measure Before Optimizing

Start with a normalized schema. Add denormalization and indexes based on measured performance, not speculation. Profile
actual queries before adding complexity.
