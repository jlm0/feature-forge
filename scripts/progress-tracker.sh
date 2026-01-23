#!/bin/bash
# Feature-Forge Progress Tracker
# Functions for tracking progress and session handoffs
# Source this script: source progress-tracker.sh

set -euo pipefail

# Use CLAUDE_PROJECT_DIR if set, otherwise use current directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
WORKSPACE_DIR="$PROJECT_DIR/.claude/feature-forge"
PROGRESS_FILE="$WORKSPACE_DIR/progress.json"
STATE_FILE="$WORKSPACE_DIR/state.json"
ARCHIVE_DIR="$WORKSPACE_DIR/archive"

# Ensure progress file exists
_ensure_progress_file() {
    if [[ ! -f "$PROGRESS_FILE" ]]; then
        echo "Error: progress.json not found at $PROGRESS_FILE" >&2
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

# Add a note to the current session
# Usage: add_session_note "Completed JWT validation implementation"
add_session_note() {
    local note="$1"
    _ensure_progress_file || return 1

    local updated
    updated=$(jq --arg note "$note" '.current_session.notes += [$note]' "$PROGRESS_FILE")
    _atomic_write "$PROGRESS_FILE" "$updated"
}

# Get current session notes
get_session_notes() {
    _ensure_progress_file || return 1
    jq -r '.current_session.notes[]' "$PROGRESS_FILE" 2>/dev/null || true
}

# Create a handoff note for session end
# Usage: create_handoff "Completed auth implementation, ready for review"
create_handoff() {
    local summary="$1"
    _ensure_progress_file || return 1

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Get current phase from state.json if available
    local phase_at_end="unknown"
    if [[ -f "$STATE_FILE" ]]; then
        phase_at_end=$(jq -r '.phase' "$STATE_FILE")
    fi

    # Get current session notes
    local notes
    notes=$(jq '.current_session.notes' "$PROGRESS_FILE")

    # Create handoff object in current session
    local updated
    updated=$(jq --arg ts "$timestamp" \
                 --arg summary "$summary" \
                 --arg phase "$phase_at_end" \
                 '.current_session.ended_at = $ts |
                  .current_session.summary = $summary |
                  .current_session.phase_at_end = $phase' \
                 "$PROGRESS_FILE")
    _atomic_write "$PROGRESS_FILE" "$updated"

    echo "Handoff created at $timestamp"
}

# Archive the current session and start a new one
# Moves current session to history and optionally archives detailed logs
archive_session() {
    _ensure_progress_file || return 1

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Ensure archive directory exists
    mkdir -p "$ARCHIVE_DIR"

    # Get current session
    local current_session
    current_session=$(jq '.current_session' "$PROGRESS_FILE")

    # Check if session has content worth archiving
    local has_content
    has_content=$(echo "$current_session" | jq 'has("summary") or (.notes | length > 0)')

    if [[ "$has_content" == "true" ]]; then
        # Generate archive filename
        local session_start
        session_start=$(echo "$current_session" | jq -r '.started // "unknown"' | tr ':' '-' | tr 'T' '_')
        local archive_file="$ARCHIVE_DIR/session-${session_start}.json"

        # Write detailed session to archive
        echo "$current_session" | jq '.' > "$archive_file"

        # Create summary for history
        local summary
        summary=$(echo "$current_session" | jq -r '.summary // "Session archived"')

        # Move to sessions array with archive reference, start new session
        local updated
        updated=$(jq --arg ts "$timestamp" \
                     --arg archive "$archive_file" \
                     --arg summary "$summary" \
                     '.sessions += [{
                        "session": .current_session.started,
                        "summary": $summary,
                        "details_archived": $archive
                      }] |
                      .current_session = {
                        "started": $ts,
                        "notes": []
                      }' \
                     "$PROGRESS_FILE")
        _atomic_write "$PROGRESS_FILE" "$updated"

        echo "Session archived to $archive_file"
        echo "New session started at $timestamp"
    else
        # Just start a new session without archiving empty one
        local updated
        updated=$(jq --arg ts "$timestamp" \
                     '.current_session = {
                        "started": $ts,
                        "notes": []
                      }' \
                     "$PROGRESS_FILE")
        _atomic_write "$PROGRESS_FILE" "$updated"

        echo "New session started at $timestamp (previous session was empty)"
    fi
}

# Get session history
get_history() {
    _ensure_progress_file || return 1
    jq '.sessions' "$PROGRESS_FILE"
}

# Get current session info
get_current_session() {
    _ensure_progress_file || return 1
    jq '.current_session' "$PROGRESS_FILE"
}

# Get count of completed sessions
get_session_count() {
    _ensure_progress_file || return 1
    jq '.sessions | length' "$PROGRESS_FILE"
}

# Update current session with additional metadata
# Usage: update_current_session '{"in_progress": "auth-002"}'
update_current_session() {
    local updates="$1"
    _ensure_progress_file || return 1

    local updated
    updated=$(jq --argjson updates "$updates" '.current_session *= $updates' "$PROGRESS_FILE")
    _atomic_write "$PROGRESS_FILE" "$updated"
}

# Read a specific archived session
# Usage: read_archived_session "archive/session-2026-01-22_10-00-00Z.json"
read_archived_session() {
    local archive_path="$1"

    # Handle relative or absolute paths
    if [[ "$archive_path" != /* ]]; then
        archive_path="$WORKSPACE_DIR/$archive_path"
    fi

    if [[ ! -f "$archive_path" ]]; then
        echo "Error: Archive file not found: $archive_path" >&2
        return 1
    fi

    cat "$archive_path"
}
