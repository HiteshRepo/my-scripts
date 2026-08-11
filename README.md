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
| `ollama-list` | Make target | List all locally pulled models |
| `ollama-ps` | Make target | Show models currently loaded in memory |
| `ollama-old-list/clean` | Make targets | List and remove models not modified in N months |
| `ollama-rm` | Make target | Remove a specific model by name |
| `ollama-upgrade` | Make target | Upgrade ollama via brew |

See [docs/reference.md](docs/reference.md) for full usage, flags, and examples.
