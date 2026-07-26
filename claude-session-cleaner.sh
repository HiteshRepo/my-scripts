#!/bin/bash

# Claude Session Cleaner
# Usage:
#   List all projects with session sizes:
#     ./claude-session-cleaner.sh --list
#
#   Dry-run for a specific project (by partial path match):
#     ./claude-session-cleaner.sh --project <keyword>
#
#   Delete sessions for a specific project (keeps memory/):
#     ./claude-session-cleaner.sh --project <keyword> --remove
#
#   Delete sessions older than N days across all projects:
#     ./claude-session-cleaner.sh --older-than <days> [--remove]

CLAUDE_DIR="$HOME/.claude/projects"
REMOVE=false
MODE=""
PROJECT_KEYWORD=""
OLDER_THAN_DAYS=""

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --list)
            MODE="list"
            shift
            ;;
        --project)
            MODE="project"
            PROJECT_KEYWORD="$2"
            shift 2
            ;;
        --older-than)
            MODE="older-than"
            OLDER_THAN_DAYS="$2"
            shift 2
            ;;
        --remove)
            REMOVE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo ""
            echo "Usage:"
            echo "  $0 --list"
            echo "  $0 --project <keyword> [--remove]"
            echo "  $0 --older-than <days> [--remove]"
            exit 1
            ;;
    esac
done

if [ -z "$MODE" ]; then
    echo "Usage:"
    echo "  $0 --list"
    echo "  $0 --project <keyword> [--remove]"
    echo "  $0 --older-than <days> [--remove]"
    exit 1
fi

# --list: show all projects with session sizes
if [ "$MODE" = "list" ]; then
    echo "Claude project sessions (sorted by size):"
    echo "------------------------------------------------"
    du -sh "$CLAUDE_DIR"/*/  2>/dev/null | sort -rh | while read -r size path; do
        proj=$(basename "$path")
        session_count=$(find "$path" -maxdepth 1 -name "*.jsonl" | wc -l | tr -d ' ')
        echo "$size  sessions=$session_count  $proj"
    done
    exit 0
fi

# --project: clean sessions for a matched project directory
if [ "$MODE" = "project" ]; then
    MATCHES=$(find "$CLAUDE_DIR" -maxdepth 1 -type d -name "*$PROJECT_KEYWORD*")

    if [ -z "$MATCHES" ]; then
        echo "No project directories matching: $PROJECT_KEYWORD"
        exit 1
    fi

    echo "Matched projects:"
    echo "------------------------------------------------"
    echo "$MATCHES" | while read -r proj_dir; do
        sessions=$(find "$proj_dir" -maxdepth 1 -name "*.jsonl")
        session_count=$(echo "$sessions" | grep -c '.jsonl' || true)
        size=$(du -sh "$proj_dir" 2>/dev/null | cut -f1)
        echo "  $proj_dir  (size=$size, sessions=$session_count)"

        if [ "$REMOVE" = true ]; then
            echo "$sessions" | while read -r f; do
                [ -z "$f" ] && continue
                echo "  [DELETING] $f"
                rm -f "$f"
            done
            echo "  [KEPT] memory/ directory preserved"
        fi
    done

    if [ "$REMOVE" = false ]; then
        echo "------------------------------------------------"
        echo "Dry run. Use --remove to delete .jsonl session files (memory/ is always preserved)."
    fi
    exit 0
fi

# --older-than: clean sessions older than N days across all projects
if [ "$MODE" = "older-than" ]; then
    if ! [[ "$OLDER_THAN_DAYS" =~ ^[0-9]+$ ]]; then
        echo "Error: --older-than requires a positive integer (number of days)"
        exit 1
    fi

    MATCHES=$(find "$CLAUDE_DIR" -name "*.jsonl" -mtime +"$OLDER_THAN_DAYS")

    if [ -z "$MATCHES" ]; then
        echo "No session files older than $OLDER_THAN_DAYS days found."
        exit 0
    fi

    total=$(echo "$MATCHES" | wc -l | tr -d ' ')
    echo "Found $total session file(s) older than $OLDER_THAN_DAYS days:"
    echo "------------------------------------------------"
    echo "$MATCHES" | while read -r f; do
        if [ "$REMOVE" = true ]; then
            echo "[DELETING] $f"
            rm -f "$f"
        else
            echo "[FOUND] $f"
        fi
    done

    if [ "$REMOVE" = false ]; then
        echo "------------------------------------------------"
        echo "Dry run. Use --remove to delete these files."
    fi
    exit 0
fi
