#!/bin/bash
set -euo pipefail

# Stop hook for Feature-Forge Ralph loops
# Intercepts session exit to implement iterative implementation and remediation loops

STATE_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/feature-forge"
STATE_FILE="${STATE_DIR}/state.json"
FEATURE_LIST="${STATE_DIR}/feature-list.json"
FINDINGS_FILE="${STATE_DIR}/findings.json"

# Read hook input from stdin (contains transcript_path and other context)
HOOK_INPUT=$(cat)

# If no state file, workspace not initialized - allow exit
if [[ ! -f "$STATE_FILE" ]]; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Check for jq
if ! command -v jq &> /dev/null; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Read current phase and iteration
PHASE=$(jq -r '.phase // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
ITERATION=$(jq -r '.iteration // 0' "$STATE_FILE" 2>/dev/null || echo "0")
MAX_ITERATIONS=$(jq -r '.max_iterations // 50' "$STATE_FILE" 2>/dev/null || echo "50")

# Function to check if transcript contains DONE promise
check_done_promise() {
    local TRANSCRIPT_PATH
    TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // ""' 2>/dev/null || echo "")

    if [[ -n "$TRANSCRIPT_PATH" && -f "$TRANSCRIPT_PATH" ]]; then
        if grep -q '<promise>DONE</promise>' "$TRANSCRIPT_PATH" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Function to update iteration count
increment_iteration() {
    local NEW_ITERATION=$((ITERATION + 1))
    local TMP_FILE=$(mktemp)
    jq ".iteration = ${NEW_ITERATION}" "$STATE_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$STATE_FILE"
    echo "$NEW_ITERATION"
}

# Handle implementation phase Ralph loop
if [[ "$PHASE" == "implementation" ]]; then
    # Check iteration limit
    if [[ "$ITERATION" -ge "$MAX_ITERATIONS" ]]; then
        echo '{"decision": "approve", "systemMessage": "Max iterations reached. Review progress manually."}'
        exit 0
    fi

    # Check if feature list exists
    if [[ ! -f "$FEATURE_LIST" ]]; then
        echo '{"decision": "approve"}'
        exit 0
    fi

    # Count features
    TOTAL_FEATURES=$(jq '.features | length' "$FEATURE_LIST" 2>/dev/null || echo "0")
    COMPLETE_FEATURES=$(jq '[.features[] | select(.status == "complete")] | length' "$FEATURE_LIST" 2>/dev/null || echo "0")

    # Check if all features complete
    if [[ "$COMPLETE_FEATURES" -ge "$TOTAL_FEATURES" && "$TOTAL_FEATURES" -gt 0 ]]; then
        # All features complete - check for DONE promise
        if check_done_promise; then
            echo '{"decision": "approve"}'
            exit 0
        fi
    fi

    # Get next incomplete feature
    NEXT_FEATURE=$(jq -r '[.features[] | select(.status != "complete")][0].id // "unknown"' "$FEATURE_LIST" 2>/dev/null || echo "unknown")
    NEXT_DESC=$(jq -r '[.features[] | select(.status != "complete")][0].description // ""' "$FEATURE_LIST" 2>/dev/null || echo "")

    # Increment iteration
    NEW_ITERATION=$(increment_iteration)

    # Block exit and continue loop
    REASON="Continue implementing. Next feature: ${NEXT_FEATURE}"
    if [[ -n "$NEXT_DESC" ]]; then
        REASON="${REASON} - ${NEXT_DESC}"
    fi

    SYSTEM_MSG="Iteration ${NEW_ITERATION}/${MAX_ITERATIONS} | Features: ${COMPLETE_FEATURES}/${TOTAL_FEATURES} complete"

    # Output JSON
    jq -n \
        --arg decision "block" \
        --arg reason "$REASON" \
        --arg systemMessage "$SYSTEM_MSG" \
        '{decision: $decision, reason: $reason, systemMessage: $systemMessage}'
    exit 0
fi

# Handle remediation phase Ralph loop
if [[ "$PHASE" == "remediation" ]]; then
    # Check iteration limit (lower for remediation)
    REMEDIATION_MAX=$(jq -r '.remediation_max_iterations // 30' "$STATE_FILE" 2>/dev/null || echo "30")

    if [[ "$ITERATION" -ge "$REMEDIATION_MAX" ]]; then
        echo '{"decision": "approve", "systemMessage": "Max remediation iterations reached. Review findings manually."}'
        exit 0
    fi

    # Check if findings file exists
    if [[ ! -f "$FINDINGS_FILE" ]]; then
        echo '{"decision": "approve"}'
        exit 0
    fi

    # Count findings
    TOTAL_FINDINGS=$(jq '.findings | length' "$FINDINGS_FILE" 2>/dev/null || echo "0")
    RESOLVED_FINDINGS=$(jq '[.findings[] | select(.status == "resolved")] | length' "$FINDINGS_FILE" 2>/dev/null || echo "0")

    # Check if all findings resolved
    if [[ "$RESOLVED_FINDINGS" -ge "$TOTAL_FINDINGS" && "$TOTAL_FINDINGS" -gt 0 ]]; then
        # All findings resolved - check for DONE promise
        if check_done_promise; then
            echo '{"decision": "approve"}'
            exit 0
        fi
    fi

    # Get next unresolved finding
    NEXT_FINDING=$(jq -r '[.findings[] | select(.status != "resolved")][0].id // "unknown"' "$FINDINGS_FILE" 2>/dev/null || echo "unknown")
    NEXT_DESC=$(jq -r '[.findings[] | select(.status != "resolved")][0].description // ""' "$FINDINGS_FILE" 2>/dev/null || echo "")
    SEVERITY=$(jq -r '[.findings[] | select(.status != "resolved")][0].severity // "medium"' "$FINDINGS_FILE" 2>/dev/null || echo "medium")

    # Increment iteration
    NEW_ITERATION=$(increment_iteration)

    # Block exit and continue loop
    REASON="Continue remediation. Next finding: ${NEXT_FINDING} (${SEVERITY})"
    if [[ -n "$NEXT_DESC" ]]; then
        REASON="${REASON} - ${NEXT_DESC}"
    fi

    SYSTEM_MSG="Iteration ${NEW_ITERATION}/${REMEDIATION_MAX} | Findings: ${RESOLVED_FINDINGS}/${TOTAL_FINDINGS} resolved"

    # Output JSON
    jq -n \
        --arg decision "block" \
        --arg reason "$REASON" \
        --arg systemMessage "$SYSTEM_MSG" \
        '{decision: $decision, reason: $reason, systemMessage: $systemMessage}'
    exit 0
fi

# For all other phases, allow exit (non-loop phases)
echo '{"decision": "approve"}'
