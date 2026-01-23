#!/bin/bash
set -euo pipefail

# Session start hook for Feature-Forge
# Loads existing state and provides context to new sessions

STATE_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/feature-forge"
STATE_FILE="${STATE_DIR}/state.json"

# Exit silently if workspace not initialized yet
if [[ ! -f "$STATE_FILE" ]]; then
    exit 0
fi

# Read current state using jq
if ! command -v jq &> /dev/null; then
    echo '{"systemMessage": "Feature-Forge: jq not installed, cannot read state"}'
    exit 0
fi

# Extract phase and build progress summary
PHASE=$(jq -r '.phase // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
ITERATION=$(jq -r '.iteration // 0' "$STATE_FILE" 2>/dev/null || echo "0")

# Build progress summary based on phase
PROGRESS_SUMMARY=""

case "$PHASE" in
    "discovery"|"exploration"|"security-context")
        PROGRESS_SUMMARY="UNDERSTANDING group in progress"
        ;;
    "clarification")
        PROGRESS_SUMMARY="Awaiting human clarification"
        ;;
    "design"|"architecture"|"hardening")
        DESIGN_ITERATION=$(jq -r '.design_iteration // 1' "$STATE_FILE" 2>/dev/null || echo "1")
        PROGRESS_SUMMARY="DESIGN group, iteration ${DESIGN_ITERATION}"
        ;;
    "implementation")
        FEATURE_LIST="${STATE_DIR}/feature-list.json"
        if [[ -f "$FEATURE_LIST" ]]; then
            TOTAL=$(jq '.features | length' "$FEATURE_LIST" 2>/dev/null || echo "0")
            COMPLETE=$(jq '[.features[] | select(.status == "complete")] | length' "$FEATURE_LIST" 2>/dev/null || echo "0")
            PROGRESS_SUMMARY="Features: ${COMPLETE}/${TOTAL} complete, iteration ${ITERATION}"
        else
            PROGRESS_SUMMARY="Implementation starting, iteration ${ITERATION}"
        fi
        ;;
    "review")
        PROGRESS_SUMMARY="Review phase in progress"
        ;;
    "remediation")
        FINDINGS_FILE="${STATE_DIR}/findings.json"
        if [[ -f "$FINDINGS_FILE" ]]; then
            TOTAL=$(jq '.findings | length' "$FINDINGS_FILE" 2>/dev/null || echo "0")
            RESOLVED=$(jq '[.findings[] | select(.status == "resolved")] | length' "$FINDINGS_FILE" 2>/dev/null || echo "0")
            PROGRESS_SUMMARY="Findings: ${RESOLVED}/${TOTAL} resolved, iteration ${ITERATION}"
        else
            PROGRESS_SUMMARY="Remediation starting, iteration ${ITERATION}"
        fi
        ;;
    "summary")
        PROGRESS_SUMMARY="Final summary generation"
        ;;
    *)
        PROGRESS_SUMMARY="Phase: ${PHASE}"
        ;;
esac

# Output JSON with system message
echo "{\"systemMessage\": \"Feature-Forge: Resuming ${PHASE} phase. ${PROGRESS_SUMMARY}\"}"
