---
name: variant-hunt
description:
  This skill should be used when hunting for similar vulnerabilities after finding an initial bug, searching for
  patterns that match a known CVE, building CodeQL or Semgrep queries for systematic scanning, or performing variant
  analysis across a codebase.
---

# Variant Hunt

## Overview

Find similar vulnerabilities and bugs across a codebase using pattern-based analysis. After discovering an initial
security issue, generalize the vulnerable pattern and systematically search for variants. This methodology transforms a
single finding into comprehensive coverage of a bug class.

Variant hunting follows a disciplined progression: start with the specific instance, understand its root cause,
generalize to a pattern signature, build queries, and search systematically. Stop expanding the search when false
positive rates indicate diminishing returns.

The goal is thoroughness without waste. A single vulnerability often indicates a systemic issue—the same mistake
repeated across multiple locations. Finding one SQL injection should trigger a hunt for all SQL injections. Finding one
missing authorization check should trigger a search for all missing authorization checks.

## Start Specific

Begin with deep understanding of the exact bug discovered. Surface-level understanding produces surface-level queries
that miss variants.

### Document the Exact Instance

Record the vulnerability with precision:

- **Location**: File path, line numbers, function name
- **Bug class**: Injection, auth bypass, race condition, etc.
- **Root cause**: Why does this code fail to be secure?
- **Trigger**: What input or conditions activate the vulnerability?
- **Impact**: What can an attacker achieve?

### Identify the Root Cause

Determine why the vulnerability exists, not just what it does:

- What security property was violated?
- What check or protection is missing?
- What assumption proved incorrect?
- What trust boundary was crossed without validation?

A SQL injection's root cause is not "user input in query"—it is "untrusted data concatenated into query string without
parameterization." Precision in root cause analysis produces precision in variant detection.

### Document the Vulnerable Pattern

Capture the code pattern that creates the vulnerability:

```
[Source of untrusted data] → [Missing sanitization/validation] → [Sensitive sink]
```

Note the specific API calls, function names, and code structures involved. These become the foundation for query
building.

### Understand Exploitability

Record what makes this instance exploitable:

- What input reaches the vulnerable code path?
- What conditions must hold for exploitation?
- Are there any partial mitigations that reduce impact?
- What does successful exploitation look like?

Understanding exploitability helps distinguish true positives from theoretical vulnerabilities during triage.

## Generalize the Pattern

Transform the specific instance into a reusable signature that can identify variants.

### Abstract from Specific Instance

Move from concrete code to pattern description:

**Specific:** `db.query("SELECT * FROM users WHERE id = " + userId)`

**Generalized:** String concatenation of user-controlled data into SQL query method

The generalized pattern captures the essence while allowing for variations in syntax, variable names, and query
structure.

### Identify Essential Characteristics

Determine what elements must be present for the bug class:

1. **Source**: Where does untrusted data originate?
2. **Propagation**: How does data flow to the sink?
3. **Sink**: What operation consumes the data unsafely?
4. **Missing defense**: What check or transformation is absent?

All four elements typically must align for a vulnerability to exist. Missing any one often indicates a false positive.

### Consider Variations

Enumerate how the pattern might appear differently:

- Different API methods for the same operation
- Wrapper functions that hide the sink
- Indirect data flow through variables or fields
- Framework-specific idioms
- Legacy code patterns vs modern patterns

Build a list of synonymous APIs and alternate code structures that produce the same vulnerability class.

### Build a Pattern Signature

Create a structured description:

```
Pattern: SQL Injection via String Concatenation
Sources: request.body.*, request.query.*, request.params.*
Sinks: db.query(), db.execute(), connection.query()
Vulnerable when: Source reaches sink without parameterization
Variations:
- Template literals: `SELECT ... ${var}`
- String concatenation: "SELECT ..." + var
- String formatting: "SELECT ... %s" % var
```

This signature guides query construction across multiple tools.

## Query Building

Translate the pattern signature into executable queries for different analysis tools.

### Grep/Ripgrep Patterns

For simple syntactic patterns, regex searches provide fast initial coverage:

```bash
# Find string concatenation in query calls
rg "\.query\s*\([^)]*\+" --type js

# Find template literals in execute methods
rg "\.execute\s*\(\s*\`" --type js

# Find format strings in SQL operations
rg "cursor\.execute.*%" --type py
```

**Limitations**: Grep cannot track data flow. Use for quick sweeps and pattern confirmation, not comprehensive analysis.
High false positive rates are expected.

### Semgrep Rules

For AST-aware pattern matching, Semgrep provides structural accuracy:

```yaml
rules:
  - id: sql-injection-concatenation
    patterns:
      - pattern-either:
          - pattern: $DB.query($X + ...)
          - pattern: $DB.query(`...${...}...`)
          - pattern: $DB.execute($X + ...)
    message: Potential SQL injection via string concatenation
    severity: ERROR
    languages: [javascript, typescript]
```

Semgrep understands code structure, matching regardless of whitespace or variable naming. Build rules that capture the
pattern signature's essential elements.

### CodeQL Queries

For data flow and taint analysis, CodeQL provides the deepest analysis:

```ql
import javascript
import semmle.javascript.security.dataflow.SqlInjectionQuery

from SqlInjectionConfiguration config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "SQL injection from $@.", source.getNode(), "user input"
```

CodeQL tracks taint through complex data flow, identifying vulnerabilities where source and sink are separated by many
function calls. Use for thorough analysis when initial sweeps indicate systemic issues.

### Custom Scripts

For complex patterns that tools cannot express, write targeted scripts:

```python
# Find all functions that accept user input and call database methods
# without intervening sanitization calls

def analyze_function(func):
    sources = find_parameter_uses(func)
    sinks = find_db_calls(func)
    sanitizers = find_sanitizer_calls(func)

    for source in sources:
        for sink in sinks:
            if reaches(source, sink) and not passes_through(source, sanitizers, sink):
                report(func, source, sink)
```

Custom analysis enables domain-specific checks that generic tools miss.

## Systematic Search Process

Execute the search with disciplined iteration, starting narrow and expanding based on results.

### Start with Tight, Specific Query

Begin with a query that closely matches the original vulnerability:

- Use exact function names from the original finding
- Limit to the same file type or module
- Include specific syntax patterns observed

The first query should have high precision (few false positives) even if it has low recall (misses some variants).
Confirm the query catches the original bug.

### Run Against Codebase

Execute the query and capture results:

```bash
# Semgrep example
semgrep --config sql-injection.yaml --json > results.json

# CodeQL example
codeql database analyze db queries/sql-injection.ql --format=sarif
```

Record the number of results and their distribution across the codebase.

### Triage Results

Classify each result:

- **True positive (TP)**: Confirmed vulnerability matching the pattern
- **False positive (FP)**: Not actually vulnerable (sanitization present, not reachable, etc.)
- **Needs review**: Cannot determine without deeper investigation

Document why false positives occur—this informs query refinement.

### Refine Based on False Positive Rate

Calculate the false positive rate: `FP / (TP + FP)`

- **High FP rate (>50%)**: Tighten the query. Add filters, require more specific patterns, exclude common FP sources.
- **Low FP rate (<25%)**: Query is effective. Consider expanding scope.
- **Moderate FP rate (25-50%)**: Query is usable. Document FP patterns for manual filtering.

### Expand Scope Incrementally

When a query shows good precision, gradually broaden:

1. Same pattern in related modules
2. Same pattern across the entire codebase
3. Synonymous APIs and alternative syntax
4. Related vulnerability classes

Each expansion step should be followed by triage. Never expand before triaging current results.

### Stop at Diminishing Returns

Terminate the hunt when:

- False positive rate exceeds 50% consistently
- Expanding scope yields only FPs
- All reasonable variations have been checked
- Time spent exceeds value of findings

The 50% FP threshold is a practical limit. Beyond this point, manual review effort exceeds the value of additional true
positives.

## False Positive Management

Effective variant hunting requires disciplined false positive tracking.

### Track False Positive Rate

Maintain running statistics:

```
Query v1: 12 results, 8 TP, 4 FP (33% FP rate)
Query v2: 28 results, 15 TP, 13 FP (46% FP rate)
Query v3: 45 results, 18 TP, 27 FP (60% FP rate) - STOP EXPANDING
```

Plot FP rate over query iterations. Stop when the trend goes wrong.

### Document False Positive Causes

For each false positive, record why it is not vulnerable:

- Sanitization present (which function?)
- Data is not user-controlled
- Code path is not reachable
- Hardcoded values only
- Framework provides protection
- Different context (test code, generated code)

These causes become exclusion patterns for query refinement.

### Refine Queries to Exclude Common FPs

Update queries based on FP patterns:

```yaml
# Before: matches all db.query with concatenation
- pattern: $DB.query($X + ...)

# After: excludes known safe patterns
- pattern: $DB.query($X + ...)
- pattern-not: $DB.query($SAFE.escape($X) + ...)
- pattern-not-inside: |
    if (validate($X)) {
      ...
      $DB.query(...)
    }
```

Iteratively improve queries until FP rate is acceptable.

### Know When to Accept Imperfection

Perfect queries are rarely achievable. Accept that:

- Some true positives will be missed (false negatives)
- Some false positives will remain
- Manual review is part of the process
- 80% coverage with 30% FP rate is often optimal

The goal is efficient vulnerability discovery, not academic perfection.

## When to Use Variant Hunting

Apply variant hunting in these scenarios:

### After Discovering a Vulnerability

The most common trigger. A single finding indicates a potential systemic issue:

- Security researcher reports a bug
- Automated scanner finds an issue
- Code review identifies a vulnerability
- Penetration test reveals a weakness

Ask: "If this mistake was made once, where else might it have been made?"

### After Fixing a Bug

Verify fixes are comprehensive:

- Before closing the ticket, search for variants
- Ensure all instances of the pattern are addressed
- Prevent fix for one instance while others remain

### When a CVE Affects Used Patterns

External vulnerability disclosures may apply to similar code:

- Library vulnerability patterns may exist in application code
- Framework issues may have been replicated manually
- Industry-wide vulnerability classes warrant systematic checks

### During Systematic Security Sweeps

Proactive security initiatives:

- Pre-release security audits
- Periodic security reviews
- New team member onboarding (learning the codebase's weak patterns)
- Compliance-driven assessments

## Scope Management

Control the search space to maintain focus and efficiency.

### Start in Same File/Module

Begin where the original bug was found:

- Other functions in the same file
- Related files in the same directory
- Code written by the same author or team
- Code from the same time period

Nearby code often shares patterns and mistakes.

### Expand to Related Modules

Move to code with functional relationships:

- Modules that handle similar data types
- Code that uses the same libraries or APIs
- Features that share architectural patterns
- Code that was copied or templated from the vulnerable area

### Then Project-Wide

Broaden to the entire codebase:

- All files matching the language/type
- All modules regardless of relationship
- Shared libraries and utilities
- Generated code and migrations

### Consider Dependencies

When appropriate, extend beyond the immediate codebase:

- Internal shared libraries
- Forked dependencies
- Vendored code
- Monorepo packages

External dependencies are typically out of scope for fixes but may warrant vulnerability reports.

## Output Format

Document variant hunting results in a structured format for tracking and remediation.

### Variant Hunt Report

```markdown
## Variant Analysis Report

**Original Finding**: SQL injection in src/api/users.ts:42 **Root Cause**: User input concatenated into query string
**Pattern**: String concatenation/interpolation in db.query() calls

### Queries Used

1. Semgrep: sql-injection-concatenation.yaml
2. Grep: `\.query\s*\([^)]*[\+\`]`
3. CodeQL: SqlInjectionQuery.ql

### Results Summary

| Location                 | Status         | Notes                      |
| ------------------------ | -------------- | -------------------------- |
| src/api/users.ts:42      | Original       | Fixed in commit abc123     |
| src/api/products.ts:78   | Confirmed      | Same pattern               |
| src/api/orders.ts:156    | Confirmed      | Template literal variant   |
| src/legacy/search.ts:23  | Confirmed      | Legacy code, high priority |
| src/utils/reports.ts:89  | False Positive | Uses parameterized query   |
| src/tests/fixtures.ts:12 | Out of Scope   | Test code only             |

### Statistics

- Total results: 15
- True positives: 4
- False positives: 8
- Out of scope: 3
- FP Rate: 67% (stopped expansion after query v3)

### Recommendations

1. Fix all confirmed variants before closing original finding
2. Add Semgrep rule to CI to prevent regression
3. Create parameterized query helper to make safe path easy
```

### Per-Finding Details

For each confirmed variant:

```markdown
### VARIANT-001: src/api/products.ts:78

**Pattern match**: db.query("SELECT \* FROM products WHERE category = '" + category + "'") **Status**: Confirmed
vulnerable **Triage notes**: User-controlled category parameter from request.query **Recommended fix**: Use
parameterized query with $1 placeholder **Blocked by**: None **Assigned to**: [developer]
```

### Query Artifacts

Preserve queries for future use:

- Semgrep rules in `.semgrep/` or security config
- CodeQL queries in `security/queries/`
- Grep patterns documented in runbooks
- Custom scripts in `tools/security/`

Effective queries become reusable assets for ongoing security hygiene and CI integration.
