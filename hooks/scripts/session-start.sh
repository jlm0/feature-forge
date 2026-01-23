#!/bin/bash
set -euo pipefail

# Session start hook for Feature-Forge
# Provides context message about active features

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/paths.sh"

# Check for jq
if ! command -v jq &> /dev/null; then
    exit 0
fi

# Get active features
ACTIVE=$(list_active_features)

if [[ -z "$ACTIVE" ]]; then
    exit 0
fi

# Count features
COUNT=$(echo "$ACTIVE" | wc -l | tr -d ' ')

if [[ "$COUNT" -eq 1 ]]; then
    # Single feature - show details
    SLUG=$(echo "$ACTIVE" | cut -d: -f1)
    PHASE=$(echo "$ACTIVE" | cut -d: -f2)

    jq -n \
        --arg slug "$SLUG" \
        --arg phase "$PHASE" \
        '{systemMessage: "Feature-Forge: Active feature \"\($slug)\" in \($phase) phase. Use /feature-forge resume to continue."}'
else
    # Multiple features
    jq -n \
        --arg count "$COUNT" \
        '{systemMessage: "Feature-Forge: \($count) active features. Use /feature-forge status to see them."}'
fi
