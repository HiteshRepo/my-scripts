SCRIPT        := ./claude-session-cleaner.sh
DAYS          ?= 30
PROJECT       ?=
ELASTIC_IMAGE := docker.elastic.co/mcp/elasticsearch
MONTHS        ?= 6
REPO          ?=

.PHONY: help \
        list clean-project clean-project-force clean-old clean-old-force \
        docker-elastic-mcp-clean \
        docker-dangling-list docker-dangling-clean \
        docker-old-list docker-old-clean \
        docker-repo-list docker-repo-clean

help:
	@echo ""
	@echo "Claude session management:"
	@echo "  make list                                List all Claude projects by session size"
	@echo "  make clean-project PROJECT=<kw>          Dry-run: show sessions for matched project"
	@echo "  make clean-project-force PROJECT=<kw>    Delete sessions for matched project"
	@echo "  make clean-old [DAYS=30]                 Dry-run: find sessions older than DAYS days"
	@echo "  make clean-old-force [DAYS=30]           Delete sessions older than DAYS days"
	@echo ""
	@echo "Docker — containers:"
	@echo "  make docker-elastic-mcp-clean            Stop and remove orphaned Elastic MCP containers"
	@echo ""
	@echo "Docker — images:"
	@echo "  make docker-dangling-list                List dangling (<none>:<none>) images"
	@echo "  make docker-dangling-clean               Remove all dangling images"
	@echo "  make docker-old-list [MONTHS=6]          List unused images older than MONTHS months"
	@echo "  make docker-old-clean [MONTHS=6]         Remove unused images older than MONTHS months"
	@echo "  make docker-repo-list REPO=<pattern>     List images matching a repository pattern"
	@echo "  make docker-repo-clean REPO=<pattern>    Remove images matching a repository pattern"
	@echo ""

# ── Claude session management ────────────────────────────────────────────────

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

# ── Docker — containers ──────────────────────────────────────────────────────

docker-elastic-mcp-clean:
	@count=$$(docker ps -q --filter ancestor=$(ELASTIC_IMAGE) | wc -l | tr -d ' '); \
	if [ "$$count" -eq 0 ]; then \
		echo "No orphaned $(ELASTIC_IMAGE) containers found."; \
	else \
		echo "Stopping and removing $$count orphaned container(s)..."; \
		docker ps -q --filter ancestor=$(ELASTIC_IMAGE) | xargs docker rm -f; \
		echo "Done."; \
	fi

# ── Docker — images ──────────────────────────────────────────────────────────

docker-dangling-list:
	@echo "Dangling images:"; \
	docker images -f "dangling=true"

docker-dangling-clean:
	@count=$$(docker images -f "dangling=true" -q | wc -l | tr -d ' '); \
	if [ "$$count" -eq 0 ]; then \
		echo "No dangling images found."; \
	else \
		echo "Removing $$count dangling image(s)..."; \
		docker image prune -f; \
		echo "Done."; \
	fi

docker-old-list:
	@CUTOFF=$$(date -v-$(MONTHS)m +%Y-%m-%d); \
	echo "Images created before $$CUTOFF:"; \
	echo ""; \
	printf "%-70s %-15s %s\n" "REPOSITORY:TAG" "IMAGE ID" "CREATED"; \
	docker images --format "{{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}" | \
	while IFS=$$'\t' read repo tag id created_at; do \
		img_date=$${created_at%% *}; \
		if [[ "$$img_date" < "$$CUTOFF" ]]; then \
			printf "%-70s %-15s %s\n" "$$repo:$$tag" "$$id" "$$img_date"; \
		fi; \
	done

docker-old-clean:
	@hours=$$(( $(MONTHS) * 730 )); \
	echo "Removing unused images older than $(MONTHS) month(s) ($${hours}h)..."; \
	docker image prune -a --filter "until=$${hours}h" -f; \
	echo "Done."

docker-repo-list:
	@[ -n "$(REPO)" ] || (echo "Error: REPO is required. Usage: make docker-repo-list REPO=<pattern>"; exit 1)
	@docker images "$(REPO)"

docker-repo-clean:
	@[ -n "$(REPO)" ] || (echo "Error: REPO is required. Usage: make docker-repo-clean REPO=<pattern>"; exit 1)
	@count=$$(docker images -q "$(REPO)" | wc -l | tr -d ' '); \
	if [ "$$count" -eq 0 ]; then \
		echo "No images found matching '$(REPO)'."; \
	else \
		echo "Removing $$count image(s) matching '$(REPO)'..."; \
		docker images -q "$(REPO)" | xargs docker rmi -f; \
		echo "Done."; \
	fi
