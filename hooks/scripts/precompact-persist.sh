#!/bin/bash
set -euo pipefail

# PreCompact hook for Feature-Forge
# Persists state before context compaction to ensure continuity

# Source path utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/paths.sh"

# Check for jq
if ! command -v jq &> /dev/null; then
    echo '{"systemMessage": "Feature-Forge: jq not installed, state may not persist correctly"}'
    exit 0
fi

# Get project directory
PROJECT_DIR=$(get_project_dir)
FEATURES_DIR="$PROJECT_DIR/features"

# If no features exist, nothing to persist
if [[ ! -d "$FEATURES_DIR" ]]; then
    exit 0
fi

# Get current timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Find and update all active features
UPDATED_FEATURES=()
for feature_dir in "$FEATURES_DIR"/*/; do
    if [[ -d "$feature_dir" ]]; then
        STATE_FILE="$feature_dir/state.json"
        PROGRESS_FILE="$feature_dir/progress.json"

        if [[ -f "$STATE_FILE" ]]; then
            status=$(jq -r '.status // "pending"' "$STATE_FILE" 2>/dev/null || echo "pending")

            # Only update active features
            if [[ "$status" != "complete" && "$status" != "cancelled" ]]; then
                FEATURE_SLUG=$(basename "$feature_dir")
                PHASE=$(jq -r '.phase // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
                ITERATION=$(jq -r '.iteration // 0' "$STATE_FILE" 2>/dev/null || echo "0")

                # Update progress.json with session notes
                if [[ -f "$PROGRESS_FILE" ]]; then
                    # Add compaction note to current session
                    TMP_FILE=$(mktemp)
                    jq --arg ts "$TIMESTAMP" --arg phase "$PHASE" --arg iter "$ITERATION" \
                        '.current_session.notes += ["Context compacted at " + $ts + " during " + $phase + " phase (iteration " + $iter + ")"]' \
                        "$PROGRESS_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$PROGRESS_FILE"
                else
                    # Create progress.json if it doesn't exist
                    jq -n --arg ts "$TIMESTAMP" --arg phase "$PHASE" --arg iter "$ITERATION" '{
                        "current_session": {
                            "started": $ts,
                            "phase": $phase,
                            "completed_this_session": [],
                            "in_progress": null,
                            "notes": ["Session created during compaction at " + $ts + " in " + $phase + " phase"]
                        },
                        "history": []
                    }' > "$PROGRESS_FILE"
                fi

                UPDATED_FEATURES+=("$FEATURE_SLUG")
            fi
        fi
    fi
done

# Check for uncommitted git changes in project directory
SOURCE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
if [[ -d "$SOURCE_PROJECT_DIR/.git" ]]; then
    cd "$SOURCE_PROJECT_DIR"

    # Check if there are any changes (staged, unstaged, or untracked)
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null || [[ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]]; then
        # Stage any modified files
        git add -u 2>/dev/null || true

        # Check if there's anything to commit
        if ! git diff --cached --quiet 2>/dev/null; then
            git commit -m "chore: auto-save before context compaction

Timestamp: ${TIMESTAMP}
Active features: ${UPDATED_FEATURES[*]:-none}" 2>/dev/null || true
        fi
    fi
fi

# Output confirmation
if [[ ${#UPDATED_FEATURES[@]} -gt 0 ]]; then
    echo "{\"systemMessage\": \"Feature-Forge: State persisted for ${#UPDATED_FEATURES[@]} active feature(s) before compaction\"}"
else
    echo '{"systemMessage": "Feature-Forge: No active features to persist"}'
fi
