#!/usr/bin/env bash
# shell-init.sh — exposes my-scripts Makefile targets as shell functions/aliases.
# Add to ~/.bashrc:
#   source /Users/hiteshpattanayak/Documents/personal/codebase/my-scripts/shell-init.sh

_MY_SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_ms() { make -C "$_MY_SCRIPTS_DIR" "$@"; }

# ── Claude session management ─────────────────────────────────────────────────
alias sessions-list='_ms list'
sessions-clean-project()       { _ms clean-project PROJECT="$1"; }
sessions-clean-project-force() { _ms clean-project-force PROJECT="$1"; }
sessions-clean-old()           { _ms clean-old ${1:+DAYS=$1}; }
sessions-clean-old-force()     { _ms clean-old-force ${1:+DAYS=$1}; }

# ── Docker — containers ───────────────────────────────────────────────────────
alias docker-elastic-mcp-clean='_ms docker-elastic-mcp-clean'

# ── Docker — images ───────────────────────────────────────────────────────────
alias docker-dangling-list='_ms docker-dangling-list'
alias docker-dangling-clean='_ms docker-dangling-clean'
docker-old-list()   { _ms docker-old-list  ${1:+MONTHS=$1}; }
docker-old-clean()  { _ms docker-old-clean ${1:+MONTHS=$1}; }
docker-repo-list()  { _ms docker-repo-list  REPO="$1"; }
docker-repo-clean() { _ms docker-repo-clean REPO="$1"; }

# ── Ollama ────────────────────────────────────────────────────────────────────
alias ollama-list-models='_ms ollama-list'
alias ollama-running='_ms ollama-ps'
ollama-old-list()  { _ms ollama-old-list  ${1:+MONTHS=$1}; }
ollama-old-clean() { _ms ollama-old-clean ${1:+MONTHS=$1}; }
ollama-remove()    { _ms ollama-rm MODEL="$1"; }
alias ollama-upgrade='_ms ollama-upgrade'
