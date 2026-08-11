# my-scripts

Personal utility scripts for local developer tooling.

## Scripts & Commands

| Name | Type | Description |
|---|---|---|
| `claude-session-cleaner.sh` | Shell script | Clean up Claude Code session `.jsonl` files under `~/.claude/projects/` |
| `docker-elastic-mcp-clean` | Make target | Stop and remove orphaned Elastic MCP containers |
| `docker-dangling-list/clean` | Make targets | List and remove dangling (`<none>:<none>`) images |
| `docker-old-list/clean` | Make targets | List and remove unused images older than N months |
| `docker-repo-list/clean` | Make targets | List and remove images by repository pattern |

See [docs/reference.md](docs/reference.md) for full usage, flags, and examples.
