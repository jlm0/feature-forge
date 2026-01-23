#!/bin/bash
# Feature-Forge Workspace Initialization
# Creates a new feature workspace in global state directory

set -euo pipefail

# Source path utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/paths.sh"

FEATURE_DESCRIPTION="${1:-Unnamed feature}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Generate feature slug from description
FEATURE_SLUG=$(slugify "$FEATURE_DESCRIPTION")

# Ensure project metadata exists
ensure_project_metadata

# Get workspace directory
WORKSPACE_DIR=$(get_feature_dir "$FEATURE_SLUG")

# Check if feature already exists
if [[ -d "$WORKSPACE_DIR" ]]; then
    STATE_FILE="$WORKSPACE_DIR/state.json"
    if [[ -f "$STATE_FILE" ]]; then
        STATUS=$(jq -r '.status // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
        if [[ "$STATUS" == "complete" || "$STATUS" == "cancelled" ]]; then
            echo "Feature '$FEATURE_SLUG' already exists and is $STATUS."
            echo "To start fresh, delete: $WORKSPACE_DIR"
            exit 1
        else
            echo "Feature '$FEATURE_SLUG' already exists and is in progress."
            echo "Use 'resume $FEATURE_SLUG' to continue working on it."
            exit 1
        fi
    fi
fi

# Create workspace directory structure
mkdir -p "$WORKSPACE_DIR"
mkdir -p "$WORKSPACE_DIR/archive"

# Initialize state.json
# Note: branch field populated by orchestrator after branch creation
cat > "$WORKSPACE_DIR/state.json" << EOF
{
  "feature": "$FEATURE_DESCRIPTION",
  "slug": "$FEATURE_SLUG",
  "branch": "",
  "group": "understanding",
  "phase": "discovery",
  "status": "pending",
  "iteration": 0,
  "design_iteration": 0,
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

# Note: Phase output files (discovery.md, exploration.md, etc.) are created
# by agents when they have content. File presence indicates phase completion.

echo "Feature-Forge workspace initialized"
echo "  Feature: $FEATURE_DESCRIPTION"
echo "  Slug: $FEATURE_SLUG"
echo "  Workspace: $WORKSPACE_DIR"
echo "Ready to begin UNDERSTANDING group"

# Output JSON for orchestrator consumption
echo "---"
jq -n \
    --arg slug "$FEATURE_SLUG" \
    --arg workspace "$WORKSPACE_DIR" \
    --arg description "$FEATURE_DESCRIPTION" \
    '{slug: $slug, workspace: $workspace, description: $description}'
