#!/bin/bash

SESSION_ID=$1
REMOVE=false

if [[ "$*" == *"--remove"* ]]; then
    REMOVE=true
fi

if [ -z "$SESSION_ID" ]; then
    echo "Usage: ./cleanup_claude.sh <session-id> [--remove]"
    exit 1
fi

CLAUDE_DIR="$HOME/.claude"

echo "Searching for Session ID: $SESSION_ID"
echo "------------------------------------------------"

# Find files and directories containing the ID
# -prune ensures if a directory matches, we don't look inside it
MATCHES=$(find "$CLAUDE_DIR" \( -name "*$SESSION_ID*" \) -prune)

if [ -z "$MATCHES" ]; then
    echo "No files or directories found."
else
    echo "$MATCHES" | while read -r item; do
        if [ "$REMOVE" = true ]; then
            echo "[DELETING] $item"
            rm -rf "$item"
        else
            echo "[FOUND] $item"
        fi
    done
fi

# Handle the index file (JSON)
INDEX_FILE="$CLAUDE_DIR/projects/sessions-index.json"
if [ -f "$INDEX_FILE" ] && grep -q "$SESSION_ID" "$INDEX_FILE"; then
    if [ "$REMOVE" = true ]; then
        echo "[CLEANING] Removing references from sessions-index.json"
        # Creates a backup (.bak) and removes the line containing the ID
        sed -i.bak "/$SESSION_ID/d" "$INDEX_FILE" && rm "${INDEX_FILE}.bak"
    else
        echo "[FOUND] Reference exists in $INDEX_FILE"
    fi
fi

if [ "$REMOVE" = false ]; then
    echo "------------------------------------------------"
    echo "Dry run complete. Use --remove to actually delete these items."
fi
