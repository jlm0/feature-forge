#!/bin/bash
set -euo pipefail

# PreCompact hook for Feature-Forge
# Adds a note to progress.json before context compaction

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/paths.sh"

# Check for jq
if ! command -v jq &> /dev/null; then
    exit 0
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
FEATURES_DIR="$(get_project_dir)/features"

if [[ ! -d "$FEATURES_DIR" ]]; then
    exit 0
fi

# Update progress.json for each active feature
for feature_dir in "$FEATURES_DIR"/*/; do
    if [[ -d "$feature_dir" ]]; then
        STATE_FILE="$feature_dir/state.json"
        PROGRESS_FILE="$feature_dir/progress.json"

        if [[ -f "$STATE_FILE" ]]; then
            STATUS=$(jq -r '.status // "pending"' "$STATE_FILE" 2>/dev/null)

            if [[ "$STATUS" != "complete" && "$STATUS" != "cancelled" ]]; then
                PHASE=$(jq -r '.phase // "unknown"' "$STATE_FILE" 2>/dev/null)

                if [[ -f "$PROGRESS_FILE" ]]; then
                    TMP=$(mktemp)
                    jq --arg ts "$TIMESTAMP" --arg phase "$PHASE" \
                        '.current_session.notes += ["Context compacted at " + $ts + " during " + $phase + " phase"]' \
                        "$PROGRESS_FILE" > "$TMP" && mv "$TMP" "$PROGRESS_FILE"
                fi
            fi
        fi
    fi
done

echo '{"systemMessage": "Feature-Forge: State persisted before compaction"}'
