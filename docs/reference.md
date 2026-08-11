# Reference

Detailed documentation for all scripts and Makefile targets.

---

## Claude Session Cleaner

**Script:** `claude-session-cleaner.sh`  
**Purpose:** Manages Claude Code session files (`.jsonl`) under `~/.claude/projects/` without touching `memory/` directories.

### Flags

| Flag | Argument | Description |
|---|---|---|
| `--list` | — | Show all projects sorted by disk size, with session count |
| `--project` | `<keyword>` | Dry-run: show sessions for projects matching the keyword |
| `--older-than` | `<days>` | Dry-run: find session files older than N days across all projects |
| `--remove` | — | Modifier: actually delete (use with `--project` or `--older-than`) |

### Make targets

| Target | Variables | Description |
|---|---|---|
| `make list` | — | List all Claude projects by session size |
| `make clean-project` | `PROJECT=<keyword>` | Dry-run: show sessions for matched project |
| `make clean-project-force` | `PROJECT=<keyword>` | Delete sessions for matched project |
| `make clean-old` | `DAYS=30` | Dry-run: find sessions older than DAYS days |
| `make clean-old-force` | `DAYS=30` | Delete sessions older than DAYS days |

### Examples

```bash
# See what's taking up space
./claude-session-cleaner.sh --list

# Inspect sessions for a specific project (dry run)
./claude-session-cleaner.sh --project k3s-homelab

# Clean sessions for a specific project
./claude-session-cleaner.sh --project k3s-homelab --remove

# Clean all sessions older than 30 days (dry run, then delete)
./claude-session-cleaner.sh --older-than 30
./claude-session-cleaner.sh --older-than 30 --remove
```

### What gets deleted vs preserved

| Path | Action |
|---|---|
| `~/.claude/projects/<project>/*.jsonl` | Deleted (conversation history) |
| `~/.claude/projects/<project>/memory/` | Always preserved (project-scoped Claude memory) |

---

## Docker — Containers

### Elastic MCP Cleanup

**Purpose:** Claude Code's Elastic MCP integration spawns a `docker.elastic.co/mcp/elasticsearch` container per session and doesn't clean them up on exit, leaving orphaned containers accumulating over time.

| Target | Description |
|---|---|
| `make docker-elastic-mcp-clean` | Stop and remove all orphaned Elastic MCP containers |

```bash
# Manual equivalent
docker ps -q --filter ancestor=docker.elastic.co/mcp/elasticsearch | xargs docker rm -f
```

---

## Docker — Images

### Dangling images

Intermediate build layers no longer referenced by any tag (`<none>:<none>`). Safe to remove at any time.

| Target | Description |
|---|---|
| `make docker-dangling-list` | List all dangling images |
| `make docker-dangling-clean` | Remove all dangling images |

```bash
# Manual equivalents
docker images -f "dangling=true"
docker image prune -f
```

### Old unused images

Images not referenced by any container, older than N months. Useful for cleaning up superseded image versions (e.g. old OTel collector tags).

| Target | Variables | Description |
|---|---|---|
| `make docker-old-list` | `MONTHS=6` | List unused images older than MONTHS months |
| `make docker-old-clean` | `MONTHS=6` | Remove unused images older than MONTHS months |

```bash
# Example: list images older than 3 months
make docker-old-list MONTHS=3

# Example: remove images older than 6 months (default)
make docker-old-clean
```

> Uses `docker image prune -a --filter "until=Nh"` under the hood — only removes images not in use by any container.

### Images by repository pattern

Removes all tags for a given repository pattern. Useful for clearing stale ACR or registry-specific images.

| Target | Variables | Description |
|---|---|---|
| `make docker-repo-list` | `REPO=<pattern>` | List images matching a repository pattern |
| `make docker-repo-clean` | `REPO=<pattern>` | Remove images matching a repository pattern |

```bash
# Example: inspect stale workload-data-discovery tags
make docker-repo-list REPO=crdatapipelinedev.azurecr.io/workload-data-discovery

# Example: remove them
make docker-repo-clean REPO=crdatapipelinedev.azurecr.io/workload-data-discovery
```
