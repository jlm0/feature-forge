#!/bin/bash
set -euo pipefail

# PreCompact hook for Feature-Forge
# Persists state before context compaction to ensure continuity

STATE_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/feature-forge"
STATE_FILE="${STATE_DIR}/state.json"
PROGRESS_FILE="${STATE_DIR}/progress.json"

# If no state file, workspace not initialized - nothing to persist
if [[ ! -f "$STATE_FILE" ]]; then
    exit 0
fi

# Check for jq
if ! command -v jq &> /dev/null; then
    echo '{"systemMessage": "Feature-Forge: jq not installed, state may not persist correctly"}'
    exit 0
fi

# Get current timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Read current phase for notes
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

# Check for uncommitted git changes in project directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
if [[ -d "$PROJECT_DIR/.git" ]]; then
    cd "$PROJECT_DIR"

    # Check if there are any changes (staged, unstaged, or untracked)
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null || [[ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]]; then
        # Stage all changes in the feature-forge state directory
        git add "$STATE_DIR" 2>/dev/null || true

        # Stage any other modified files
        git add -u 2>/dev/null || true

        # Check if there's anything to commit
        if ! git diff --cached --quiet 2>/dev/null; then
            git commit -m "chore: auto-save before context compaction

Phase: ${PHASE}
Iteration: ${ITERATION}
Timestamp: ${TIMESTAMP}" 2>/dev/null || true
        fi
    fi
fi

# Output confirmation
echo '{"systemMessage": "Feature-Forge: State persisted before compaction"}'
