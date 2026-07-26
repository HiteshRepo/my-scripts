SCRIPT := ./claude-session-cleaner.sh
DAYS    ?= 30
PROJECT ?=

.PHONY: help list clean-project clean-old clean-old-force

help:
	@echo "Usage:"
	@echo "  make list                          List all Claude projects by session size"
	@echo "  make clean-project PROJECT=<kw>    Dry-run: show sessions for matched project"
	@echo "  make clean-project-force PROJECT=<kw>  Delete sessions for matched project"
	@echo "  make clean-old [DAYS=30]           Dry-run: find sessions older than DAYS days"
	@echo "  make clean-old-force [DAYS=30]     Delete sessions older than DAYS days"

list:
	$(SCRIPT) --list

clean-project:
	@[ -n "$(PROJECT)" ] || (echo "Error: PROJECT is required. Usage: make clean-project PROJECT=<keyword>"; exit 1)
	$(SCRIPT) --project $(PROJECT)

clean-project-force:
	@[ -n "$(PROJECT)" ] || (echo "Error: PROJECT is required. Usage: make clean-project-force PROJECT=<keyword>"; exit 1)
	$(SCRIPT) --project $(PROJECT) --remove

clean-old:
	$(SCRIPT) --older-than $(DAYS)

clean-old-force:
	$(SCRIPT) --older-than $(DAYS) --remove
