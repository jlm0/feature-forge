#!/bin/bash
# Feature-Forge Workspace Initialization
# Creates the .claude/feature-forge/ directory structure for a new feature

set -euo pipefail

# Use CLAUDE_PROJECT_DIR if set, otherwise use current directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
WORKSPACE_DIR="$PROJECT_DIR/.claude/feature-forge"

FEATURE_DESCRIPTION="${1:-Unnamed feature}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create workspace directory structure
mkdir -p "$WORKSPACE_DIR"
mkdir -p "$WORKSPACE_DIR/archive"

# Initialize state.json
# Note: branch field populated by orchestrator after branch creation
cat > "$WORKSPACE_DIR/state.json" << EOF
{
  "feature": "$FEATURE_DESCRIPTION",
  "branch": "",
  "group": "understanding",
  "phase": "discovery",
  "status": "pending",
  "iteration": 0,
  "started_at": "$TIMESTAMP",
  "approvals": {}
}
EOF

# Initialize progress.json
cat > "$WORKSPACE_DIR/progress.json" << EOF
{
  "sessions": [],
  "current_session": {
    "started": "$TIMESTAMP",
    "notes": []
  }
}
EOF

# Initialize feature-list.json (empty until design phase)
cat > "$WORKSPACE_DIR/feature-list.json" << EOF
{
  "features": []
}
EOF

# Initialize findings.json (empty until review phase)
cat > "$WORKSPACE_DIR/findings.json" << EOF
{
  "findings": []
}
EOF

# Create placeholder phase output files
touch "$WORKSPACE_DIR/discovery.md"
touch "$WORKSPACE_DIR/exploration.md"
touch "$WORKSPACE_DIR/security-context.md"
touch "$WORKSPACE_DIR/architecture.md"
touch "$WORKSPACE_DIR/hardening-review.md"
touch "$WORKSPACE_DIR/summary.md"

echo "Feature-Forge workspace initialized at $WORKSPACE_DIR"
echo "Feature: $FEATURE_DESCRIPTION"
echo "Ready to begin UNDERSTANDING group"
