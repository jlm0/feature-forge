#!/bin/bash
# Feature-Forge Path Utilities
# Provides consistent path resolution for global state management

# Get project hash from project directory path
# Usage: PROJECT_HASH=$(get_project_hash "/path/to/project")
get_project_hash() {
    local project_dir="${1:-$CLAUDE_PROJECT_DIR}"
    project_dir="${project_dir:-.}"
    # Get absolute path and hash it
    local abs_path
    abs_path=$(cd "$project_dir" 2>/dev/null && pwd)
    echo -n "$abs_path" | shasum -a 256 | cut -c1-12
}

# Convert feature description to slug
# Usage: SLUG=$(slugify "Add user authentication")
slugify() {
    local input="$1"
    echo "$input" | \
        tr '[:upper:]' '[:lower:]' | \
        sed 's/[^a-z0-9]/-/g' | \
        sed 's/--*/-/g' | \
        sed 's/^-//' | \
        sed 's/-$//' | \
        cut -c1-50
}

# Get base directory for all feature-forge state
get_base_dir() {
    echo "$HOME/.claude/feature-forge"
}

# Get project directory for a specific project
# Usage: PROJECT_DIR=$(get_project_dir)
get_project_dir() {
    local project_hash
    project_hash=$(get_project_hash)
    echo "$(get_base_dir)/projects/$project_hash"
}

# Get feature workspace directory
# Usage: WORKSPACE=$(get_feature_dir "add-user-auth")
get_feature_dir() {
    local feature_slug="$1"
    echo "$(get_project_dir)/features/$feature_slug"
}

# Get the current active feature for this project (if only one)
# Returns feature slug or empty if none/multiple
get_active_feature() {
    local project_dir
    project_dir=$(get_project_dir)
    local features_dir="$project_dir/features"

    if [[ ! -d "$features_dir" ]]; then
        echo ""
        return
    fi

    # Count active features (directories with state.json where status != complete)
    local active_features=()
    for feature_dir in "$features_dir"/*/; do
        if [[ -d "$feature_dir" ]]; then
            local state_file="$feature_dir/state.json"
            if [[ -f "$state_file" ]]; then
                local status
                status=$(jq -r '.status // "pending"' "$state_file" 2>/dev/null || echo "pending")
                if [[ "$status" != "complete" && "$status" != "cancelled" ]]; then
                    active_features+=("$(basename "$feature_dir")")
                fi
            fi
        fi
    done

    if [[ ${#active_features[@]} -eq 1 ]]; then
        echo "${active_features[0]}"
    else
        echo ""
    fi
}

# List all features for current project with status
# Output: JSON array of {slug, status, phase, description}
list_features() {
    local project_dir
    project_dir=$(get_project_dir)
    local features_dir="$project_dir/features"

    if [[ ! -d "$features_dir" ]]; then
        echo "[]"
        return
    fi

    local features="[]"
    for feature_dir in "$features_dir"/*/; do
        if [[ -d "$feature_dir" ]]; then
            local slug
            slug=$(basename "$feature_dir")
            local state_file="$feature_dir/state.json"
            if [[ -f "$state_file" ]]; then
                local feature_json
                feature_json=$(jq -c --arg slug "$slug" '{
                    slug: $slug,
                    description: .feature,
                    status: (.status // "pending"),
                    phase: (.phase // "unknown"),
                    group: (.group // "unknown")
                }' "$state_file" 2>/dev/null)
                features=$(echo "$features" | jq --argjson f "$feature_json" '. + [$f]')
            fi
        fi
    done

    echo "$features"
}

# Ensure project.json exists with metadata
ensure_project_metadata() {
    local project_dir
    project_dir=$(get_project_dir)
    local project_json="$project_dir/project.json"

    mkdir -p "$project_dir"

    if [[ ! -f "$project_json" ]]; then
        local abs_path
        abs_path=$(cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null && pwd)
        local project_name
        project_name=$(basename "$abs_path")

        # Try to get git remote if available
        local git_remote=""
        if [[ -d "${CLAUDE_PROJECT_DIR:-.}/.git" ]]; then
            git_remote=$(cd "${CLAUDE_PROJECT_DIR:-.}" && git remote get-url origin 2>/dev/null || echo "")
        fi

        jq -n \
            --arg path "$abs_path" \
            --arg name "$project_name" \
            --arg remote "$git_remote" \
            '{
                path: $path,
                name: $name,
                git_remote: $remote,
                created_at: (now | todate)
            }' > "$project_json"
    fi
}
