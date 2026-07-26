# my-scripts

Personal utility scripts for local developer tooling.

## Scripts

### `claude-session-cleaner.sh`

Manages Claude Code session files stored under `~/.claude/projects/`. Sessions accumulate as `.jsonl` files per project and can grow large over time. This script helps you inspect and clean them up without touching the `memory/` directories (project-scoped Claude memory is always preserved).

**Modes:**

| Command | Description |
|---|---|
| `--list` | Show all projects sorted by disk size, with session count |
| `--project <keyword>` | Dry-run: show sessions for projects matching the keyword |
| `--project <keyword> --remove` | Delete `.jsonl` session files for matched project(s) |
| `--older-than <days>` | Dry-run: find session files older than N days (all projects) |
| `--older-than <days> --remove` | Delete session files older than N days (all projects) |

**Examples:**

```bash
# See what's taking up space
./claude-session-cleaner.sh --list

# Inspect sessions for a specific project (dry run)
./claude-session-cleaner.sh --project k3s-homelab

# Clean sessions for a specific project
./claude-session-cleaner.sh --project k3s-homelab --remove

# Clean all sessions older than 30 days (dry run first)
./claude-session-cleaner.sh --older-than 30
./claude-session-cleaner.sh --older-than 30 --remove
```

**What gets deleted vs preserved:**

- Deleted: `~/.claude/projects/<project>/*.jsonl` (conversation history)
- Preserved: `~/.claude/projects/<project>/memory/` (project-scoped Claude memory)

## Usage via Makefile

```bash
make list
make clean-project PROJECT=k3s-homelab
make clean-old DAYS=30
make clean-old-force DAYS=30
```

See `Makefile` for all targets.
