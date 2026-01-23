#!/bin/bash
set -euo pipefail

# Session start hook for Feature-Forge
# Loads existing state and provides context to new sessions

# Source path utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/paths.sh"

# Check for jq
if ! command -v jq &> /dev/null; then
    exit 0
fi

# Get project directory
PROJECT_DIR=$(get_project_dir)
FEATURES_DIR="$PROJECT_DIR/features"

# Exit silently if no features exist for this project
if [[ ! -d "$FEATURES_DIR" ]]; then
    exit 0
fi

# Find active features
ACTIVE_FEATURES=()
for feature_dir in "$FEATURES_DIR"/*/; do
    if [[ -d "$feature_dir" ]]; then
        state_file="$feature_dir/state.json"
        if [[ -f "$state_file" ]]; then
            status=$(jq -r '.status // "pending"' "$state_file" 2>/dev/null || echo "pending")
            if [[ "$status" != "complete" && "$status" != "cancelled" ]]; then
                ACTIVE_FEATURES+=("$(basename "$feature_dir")")
            fi
        fi
    fi
done

# Exit silently if no active features
if [[ ${#ACTIVE_FEATURES[@]} -eq 0 ]]; then
    exit 0
fi

# Build status message
if [[ ${#ACTIVE_FEATURES[@]} -eq 1 ]]; then
    FEATURE_SLUG="${ACTIVE_FEATURES[0]}"
    STATE_FILE="$FEATURES_DIR/$FEATURE_SLUG/state.json"

    PHASE=$(jq -r '.phase // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
    ITERATION=$(jq -r '.iteration // 0' "$STATE_FILE" 2>/dev/null || echo "0")
    FEATURE_NAME=$(jq -r '.feature // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")

    # Build progress summary based on phase
    PROGRESS_SUMMARY=""

    case "$PHASE" in
        "discovery"|"exploration"|"security-context")
            PROGRESS_SUMMARY="UNDERSTANDING group in progress"
            ;;
        "clarification")
            PROGRESS_SUMMARY="Awaiting human clarification"
            ;;
        "design"|"architecture"|"synthesis"|"hardening")
            DESIGN_ITERATION=$(jq -r '.design_iteration // 1' "$STATE_FILE" 2>/dev/null || echo "1")
            PROGRESS_SUMMARY="DESIGN group, iteration ${DESIGN_ITERATION}"
            ;;
        "triage")
            PROGRESS_SUMMARY="Awaiting design approval"
            ;;
        "implementation")
            FEATURE_LIST="$FEATURES_DIR/$FEATURE_SLUG/feature-list.json"
            if [[ -f "$FEATURE_LIST" ]]; then
                TOTAL=$(jq '.features | length' "$FEATURE_LIST" 2>/dev/null || echo "0")
                COMPLETE=$(jq '[.features[] | select(.status == "complete")] | length' "$FEATURE_LIST" 2>/dev/null || echo "0")
                PROGRESS_SUMMARY="Features: ${COMPLETE}/${TOTAL} complete, iteration ${ITERATION}"
            else
                PROGRESS_SUMMARY="Implementation starting, iteration ${ITERATION}"
            fi
            ;;
        "review"|"review-checkpoint")
            PROGRESS_SUMMARY="Review phase in progress"
            ;;
        "remediation")
            FINDINGS_FILE="$FEATURES_DIR/$FEATURE_SLUG/findings.json"
            if [[ -f "$FINDINGS_FILE" ]]; then
                TOTAL=$(jq '.findings | length' "$FINDINGS_FILE" 2>/dev/null || echo "0")
                RESOLVED=$(jq '[.findings[] | select(.status == "resolved")] | length' "$FINDINGS_FILE" 2>/dev/null || echo "0")
                PROGRESS_SUMMARY="Findings: ${RESOLVED}/${TOTAL} resolved, iteration ${ITERATION}"
            else
                PROGRESS_SUMMARY="Remediation starting, iteration ${ITERATION}"
            fi
            ;;
        "summary"|"completion")
            PROGRESS_SUMMARY="Final summary generation"
            ;;
        *)
            PROGRESS_SUMMARY="Phase: ${PHASE}"
            ;;
    esac

    # Output JSON with system message
    jq -n \
        --arg feature "$FEATURE_NAME" \
        --arg slug "$FEATURE_SLUG" \
        --arg phase "$PHASE" \
        --arg progress "$PROGRESS_SUMMARY" \
        '{systemMessage: "Feature-Forge: Active feature \"\(.feature)\" (\(.slug)) - \(.phase) phase. \(.progress). Use /feature-forge resume to continue."}'
else
    # Multiple active features
    FEATURE_LIST=""
    for slug in "${ACTIVE_FEATURES[@]}"; do
        state_file="$FEATURES_DIR/$slug/state.json"
        phase=$(jq -r '.phase // "unknown"' "$state_file" 2>/dev/null || echo "unknown")
        FEATURE_LIST="$FEATURE_LIST\n  - $slug ($phase)"
    done

    jq -n \
        --arg count "${#ACTIVE_FEATURES[@]}" \
        --arg features "$FEATURE_LIST" \
        '{systemMessage: "Feature-Forge: \(.count) active features. Use /feature-forge resume <slug> to continue one:\(.features)"}'
fi
