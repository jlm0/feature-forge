#!/bin/bash
# Feature-Forge State Manager
# Functions for managing state.json
# Source this script: source state-manager.sh

set -euo pipefail

# Use CLAUDE_PROJECT_DIR if set, otherwise use current directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
STATE_FILE="$PROJECT_DIR/.claude/feature-forge/state.json"

# Ensure state file exists
_ensure_state_file() {
    if [[ ! -f "$STATE_FILE" ]]; then
        echo "Error: state.json not found at $STATE_FILE" >&2
        echo "Run init-workspace.sh first" >&2
        return 1
    fi
}

# Atomic write: write to temp file, then move
_atomic_write() {
    local file="$1"
    local content="$2"
    local temp_file
    temp_file=$(mktemp)
    echo "$content" > "$temp_file"
    mv "$temp_file" "$file"
}

# Read and output entire state.json
read_state() {
    _ensure_state_file || return 1
    cat "$STATE_FILE"
}

# Get current phase from state.json
get_phase() {
    _ensure_state_file || return 1
    jq -r '.phase' "$STATE_FILE"
}

# Set phase in state.json
set_phase() {
    local phase="$1"
    _ensure_state_file || return 1

    local updated
    updated=$(jq --arg phase "$phase" '.phase = $phase' "$STATE_FILE")
    _atomic_write "$STATE_FILE" "$updated"
}

# Get current group from state.json
get_group() {
    _ensure_state_file || return 1
    jq -r '.group' "$STATE_FILE"
}

# Set group in state.json
set_group() {
    local group="$1"
    _ensure_state_file || return 1

    local updated
    updated=$(jq --arg group "$group" '.group = $group' "$STATE_FILE")
    _atomic_write "$STATE_FILE" "$updated"
}

# Get current status from state.json
get_status() {
    _ensure_state_file || return 1
    jq -r '.status' "$STATE_FILE"
}

# Set status in state.json (pending, running, waiting_approval, complete)
set_status() {
    local new_status="$1"
    _ensure_state_file || return 1

    # Validate status value
    case "$new_status" in
        pending|running|waiting_approval|complete)
            ;;
        *)
            echo "Error: Invalid status '$new_status'. Must be: pending, running, waiting_approval, complete" >&2
            return 1
            ;;
    esac

    local updated
    updated=$(jq --arg s "$new_status" '.status = $s' "$STATE_FILE")
    _atomic_write "$STATE_FILE" "$updated"
}

# Get current iteration count
get_iteration() {
    _ensure_state_file || return 1
    jq -r '.iteration' "$STATE_FILE"
}

# Increment iteration counter
increment_iteration() {
    _ensure_state_file || return 1

    local updated
    updated=$(jq '.iteration = .iteration + 1' "$STATE_FILE")
    _atomic_write "$STATE_FILE" "$updated"
}

# Reset iteration counter to 0
reset_iteration() {
    _ensure_state_file || return 1

    local updated
    updated=$(jq '.iteration = 0' "$STATE_FILE")
    _atomic_write "$STATE_FILE" "$updated"
}

# Update approval decision for a checkpoint
# Usage: update_approval <checkpoint> <approved> [notes]
# Example: update_approval "design_v1" true "Approved with minor changes"
update_approval() {
    local checkpoint="$1"
    local approved="$2"
    local notes="${3:-}"

    _ensure_state_file || return 1

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local updated
    if [[ -n "$notes" ]]; then
        updated=$(jq --arg cp "$checkpoint" \
                     --argjson approved "$approved" \
                     --arg notes "$notes" \
                     --arg ts "$timestamp" \
                     '.approvals[$cp] = {"approved": $approved, "notes": $notes, "timestamp": $ts}' \
                     "$STATE_FILE")
    else
        updated=$(jq --arg cp "$checkpoint" \
                     --argjson approved "$approved" \
                     --arg ts "$timestamp" \
                     '.approvals[$cp] = {"approved": $approved, "timestamp": $ts}' \
                     "$STATE_FILE")
    fi
    _atomic_write "$STATE_FILE" "$updated"
}

# Get approval status for a checkpoint
get_approval() {
    local checkpoint="$1"
    _ensure_state_file || return 1
    jq -r --arg cp "$checkpoint" '.approvals[$cp] // empty' "$STATE_FILE"
}

# Check if a checkpoint was approved
is_approved() {
    local checkpoint="$1"
    _ensure_state_file || return 1
    local result
    result=$(jq -r --arg cp "$checkpoint" '.approvals[$cp].approved // false' "$STATE_FILE")
    [[ "$result" == "true" ]]
}

# Get feature description
get_feature() {
    _ensure_state_file || return 1
    jq -r '.feature' "$STATE_FILE"
}

# Update multiple fields at once
# Usage: update_state '{"phase": "design", "status": "running"}'
update_state() {
    local updates="$1"
    _ensure_state_file || return 1

    local updated
    updated=$(jq --argjson updates "$updates" '. * $updates' "$STATE_FILE")
    _atomic_write "$STATE_FILE" "$updated"
}
