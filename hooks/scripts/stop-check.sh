#!/bin/bash
set -euo pipefail

# Stop hook for Feature-Forge Ralph loops
# Blocks exit during implementation/remediation until work is complete

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/paths.sh"

# Read hook input from stdin
HOOK_INPUT=$(cat)

# Check for jq
if ! command -v jq &> /dev/null; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Find feature in a loop phase
FEATURE_SLUG=$(get_looping_feature)

if [[ -z "$FEATURE_SLUG" ]]; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Get workspace paths
WORKSPACE=$(get_feature_dir "$FEATURE_SLUG")
STATE_FILE="$WORKSPACE/state.json"
FEATURE_LIST="$WORKSPACE/feature-list.json"
FINDINGS_FILE="$WORKSPACE/findings.json"

# Read state
PHASE=$(jq -r '.phase // ""' "$STATE_FILE" 2>/dev/null)
ITERATION=$(jq -r '.iteration // 0' "$STATE_FILE" 2>/dev/null)
FEATURE_NAME=$(jq -r '.feature // "feature"' "$STATE_FILE" 2>/dev/null)

# Check for DONE promise in transcript
check_done_promise() {
    local transcript
    transcript=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // ""' 2>/dev/null)
    if [[ -n "$transcript" && -f "$transcript" ]]; then
        grep -q '<promise>DONE</promise>' "$transcript" 2>/dev/null
        return $?
    fi
    return 1
}

# Implementation loop
if [[ "$PHASE" == "implementation" ]]; then
    MAX=50

    if [[ "$ITERATION" -ge "$MAX" ]]; then
        echo '{"decision": "approve", "systemMessage": "Max iterations reached."}'
        exit 0
    fi

    if [[ -f "$FEATURE_LIST" ]]; then
        TOTAL=$(jq '.features | length' "$FEATURE_LIST" 2>/dev/null || echo "0")
        COMPLETE=$(jq '[.features[] | select(.status == "complete")] | length' "$FEATURE_LIST" 2>/dev/null || echo "0")

        if [[ "$COMPLETE" -ge "$TOTAL" && "$TOTAL" -gt 0 ]]; then
            if check_done_promise; then
                echo '{"decision": "approve"}'
                exit 0
            fi
        fi

        # Get next feature
        NEXT=$(jq -r '[.features[] | select(.status != "complete")][0].id // "next"' "$FEATURE_LIST" 2>/dev/null)

        # Increment iteration
        NEW_ITER=$((ITERATION + 1))
        TMP=$(mktemp)
        jq ".iteration = $NEW_ITER" "$STATE_FILE" > "$TMP" && mv "$TMP" "$STATE_FILE"

        jq -n \
            --arg decision "block" \
            --arg reason "Continue implementing. Next: $NEXT" \
            --arg msg "[$FEATURE_SLUG] $NEW_ITER/$MAX | Features: $COMPLETE/$TOTAL" \
            '{decision: $decision, reason: $reason, systemMessage: $msg}'
        exit 0
    fi
fi

# Remediation loop
if [[ "$PHASE" == "remediation" ]]; then
    MAX=30

    if [[ "$ITERATION" -ge "$MAX" ]]; then
        echo '{"decision": "approve", "systemMessage": "Max remediation iterations reached."}'
        exit 0
    fi

    if [[ -f "$FINDINGS_FILE" ]]; then
        TOTAL=$(jq '.findings | length' "$FINDINGS_FILE" 2>/dev/null || echo "0")
        RESOLVED=$(jq '[.findings[] | select(.status == "resolved")] | length' "$FINDINGS_FILE" 2>/dev/null || echo "0")

        if [[ "$RESOLVED" -ge "$TOTAL" && "$TOTAL" -gt 0 ]]; then
            if check_done_promise; then
                echo '{"decision": "approve"}'
                exit 0
            fi
        fi

        # Get next finding
        NEXT=$(jq -r '[.findings[] | select(.status != "resolved")][0].id // "next"' "$FINDINGS_FILE" 2>/dev/null)

        # Increment iteration
        NEW_ITER=$((ITERATION + 1))
        TMP=$(mktemp)
        jq ".iteration = $NEW_ITER" "$STATE_FILE" > "$TMP" && mv "$TMP" "$STATE_FILE"

        jq -n \
            --arg decision "block" \
            --arg reason "Continue remediation. Next: $NEXT" \
            --arg msg "[$FEATURE_SLUG] $NEW_ITER/$MAX | Findings: $RESOLVED/$TOTAL" \
            '{decision: $decision, reason: $reason, systemMessage: $msg}'
        exit 0
    fi
fi

echo '{"decision": "approve"}'
