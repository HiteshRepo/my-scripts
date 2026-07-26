# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Personal utility scripts for managing local developer tooling. Currently contains one script: `claude-session-cleaner.sh`, which manages Claude Code session `.jsonl` files under `~/.claude/projects/` without touching `memory/` directories.

## Commands

```bash
# List all targets
make help

# List Claude projects by session size
make list

# Dry-run: show sessions for a matched project (keyword match on directory name)
make clean-project PROJECT=<keyword>

# Delete sessions for a matched project (preserves memory/)
make clean-project-force PROJECT=<keyword>

# Dry-run: find sessions older than N days (default 30)
make clean-old [DAYS=30]

# Delete sessions older than N days
make clean-old-force [DAYS=30]
```

Or invoke the script directly:

```bash
./claude-session-cleaner.sh --list
./claude-session-cleaner.sh --project <keyword> [--remove]
./claude-session-cleaner.sh --older-than <days> [--remove]
```

## Script Behavior

- `--list`: uses `du -sh` on `~/.claude/projects/*/`, sorted by size descending
- `--project`: matches project directory names by substring (partial match), always dry-runs unless `--remove` is passed
- `--older-than`: uses `find -mtime +N` across all projects; `--remove` to actually delete
- `memory/` subdirectories are **never** deleted by any mode
