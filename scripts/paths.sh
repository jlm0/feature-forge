#!/bin/bash
# Feature-Forge Path Utilities
# Used by hooks only - orchestrator uses direct file operations
#
# Hooks need these utilities because they're bash scripts that run automatically
# and need to find state files without access to Claude's Glob/Read tools.

# Get project hash from project directory path
# Usage: PROJECT_HASH=$(get_project_hash)
get_project_hash() {
    local project_dir="${CLAUDE_PROJECT_DIR:-.}"
    local abs_path
    abs_path=$(cd "$project_dir" 2>/dev/null && pwd)
    echo -n "$abs_path" | shasum -a 256 | cut -c1-12
}

# Get base directory for all feature-forge state
get_base_dir() {
    echo "$HOME/.claude/feature-forge"
}

# Get project directory for current project
# Usage: PROJECT_DIR=$(get_project_dir)
get_project_dir() {
    echo "$(get_base_dir)/projects/$(get_project_hash)"
}

# Get feature workspace directory
# Usage: WORKSPACE=$(get_feature_dir "add-user-auth")
get_feature_dir() {
    local feature_slug="$1"
    echo "$(get_project_dir)/features/$feature_slug"
}

# Find the active feature in a Ralph loop phase (implementation or remediation)
# Returns feature slug or empty if none found
# Used by stop-check.sh to know which feature to check
get_looping_feature() {
    local features_dir
    features_dir="$(get_project_dir)/features"

    if [[ ! -d "$features_dir" ]]; then
        echo ""
        return
    fi

    for feature_dir in "$features_dir"/*/; do
        if [[ -d "$feature_dir" ]]; then
            local state_file="$feature_dir/state.json"
            if [[ -f "$state_file" ]]; then
                local phase status
                phase=$(jq -r '.phase // ""' "$state_file" 2>/dev/null)
                status=$(jq -r '.status // ""' "$state_file" 2>/dev/null)

                # Only return features in loop phases that aren't complete/cancelled
                if [[ ("$phase" == "implementation" || "$phase" == "remediation") &&
                      "$status" != "complete" && "$status" != "cancelled" ]]; then
                    basename "$feature_dir"
                    return
                fi
            fi
        fi
    done

    echo ""
}

# List all active features (for session-start hook message)
# Returns newline-separated list of "slug:phase" pairs
list_active_features() {
    local features_dir
    features_dir="$(get_project_dir)/features"

    if [[ ! -d "$features_dir" ]]; then
        return
    fi

    for feature_dir in "$features_dir"/*/; do
        if [[ -d "$feature_dir" ]]; then
            local state_file="$feature_dir/state.json"
            if [[ -f "$state_file" ]]; then
                local status phase slug
                status=$(jq -r '.status // "pending"' "$state_file" 2>/dev/null)
                phase=$(jq -r '.phase // "unknown"' "$state_file" 2>/dev/null)
                slug=$(basename "$feature_dir")

                if [[ "$status" != "complete" && "$status" != "cancelled" ]]; then
                    echo "$slug:$phase"
                fi
            fi
        fi
    done
}
