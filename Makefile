COMPOSE_BASE = docker compose -f srcs/docker-compose.yml --env-file srcs/.env
COMPOSE = $(COMPOSE_BASE) --profile bonus

USERNAME := $(shell sed -n 's/^LOGIN=//p' srcs/.env)
BACKUP_DIR := /home/$(USERNAME)/data/backups

.PHONY: all setup build up bonus down stop start restart logs ps clean fclean re backup backup-list backup-check backup-restore backup-restore-wp backup-delete

all: up

setup:
	sh srcs/requirements/tools/init.sh

build: setup
	$(COMPOSE_BASE) build

up: build
	$(COMPOSE_BASE) build

bonus: setup
	WP_REDIS_ENABLED=1 $(COMPOSE) up -d --build

start: setup
	$(COMPOSE) start

stop: setup
	$(COMPOSE) stop

down:
	$(COMPOSE) down

restart: setup
	$(COMPOSE) restart

logs: setup
	$(COMPOSE) logs -f

ps: setup
	$(COMPOSE) ps

backup: setup
	$(COMPOSE) exec backup backup

backup-list: setup
	@if [ ! -d "$(BACKUP_DIR)" ]; then \
		echo "No backup directory found: $(BACKUP_DIR)"; \
		exit 1; \
	fi
	@echo "Available database backups:"
	@find "$(BACKUP_DIR)" -maxdepth 1 -type f -name 'db-*.sql.gz' -printf '  %f\n' | sort
	@echo ""
	@echo "Available WordPress backups:"
	@find "$(BACKUP_DIR)" -maxdepth 1 -type f -name 'wordpress-*.tar.gz' -printf '  %f\n' | sort



backup-check: setup
	@set -e; \
	invalid=0; \
	if ! find "$(BACKUP_DIR)" -maxdepth 1 -type f -name 'db-*.sql.gz' | grep -q .; then \
		echo "No database backups found"; exit 1; \
	fi; \
	for file in "$(BACKUP_DIR)"/db-*.sql.gz; do \
		echo "Checking $$file"; \
		if ! sudo gunzip -t "$$file"; then \
			echo "ERROR: Invalid or corrupted backup: $$file"; \
			echo "You can delete it with: make backup-delete BACKUP=$$(basename "$$file")"; \
			invalid=1; \
		fi; \
	done; \
	for file in "$(BACKUP_DIR)"/wordpress-*.tar.gz; do \
		if [ -f "$$file" ]; then \
			echo "Checking $$file"; \
			if ! sudo tar -tzf "$$file" > /dev/null; then \
				echo "ERROR: Invalid or corrupted backup: $$file"; \
				echo "You can delete it with: make backup-delete BACKUP=$$(basename "$$file")"; \
				invalid=1; \
			fi; \
		fi; \
	done; \
	if [ "$$invalid" -ne 0 ]; then \
		echo "Backup check completed with errors"; \
		exit 1; \
	fi; \
	echo "All backups checked successfully"

backup-restore: setup
	@set -e; \
	backup="$(BACKUP)"; \
	if [ -z "$$backup" ]; then \
		echo "Usage: make backup-restore BACKUP=db-YYYYMMDD-HHMMSS.sql.gz"; \
		exit 1; \
	fi; \
	case "$$backup" in db-*.sql.gz) ;; \
		*) echo "Invalid database backup filename"; exit 1 ;; \
	esac; \
	if [ "$${backup##*/}" != "$$backup" ]; then \
		echo "Please provide a filename, not a path"; exit 1; \
	fi; \
	file="$(BACKUP_DIR)/$$backup"; \
	if [ ! -f "$$file" ]; then \
		echo "Backup not found: $$file"; exit 1; \
	fi; \
	echo "Restoring database from $$backup..."; \
	sudo sh -c 'gunzip -c "$$1"' sh "$$file" | \
		$(COMPOSE) exec -T mariadb sh -c \
		'mariadb -uroot -p"$$(cat /run/secrets/db_root_password)" wordpress'
	echo "Database restored successfully!"

backup-restore-wp: setup
	@set -e; \
	backup="$(BACKUP)"; \
	if [ -z "$$backup" ]; then \
		echo "Usage: make backup-restore-wp BACKUP=wordpress-YYYYMMDD-HHMMSS.tar.gz"; \
		exit 1; \
	fi; \
	case "$$backup" in wordpress-*.tar.gz) ;; \
		*) echo "Invalid WordPress backup filename"; exit 1 ;; \
	esac; \
	if [ "$${backup##*/}" != "$$backup" ]; then \
		echo "Please provide a filename, not a path"; exit 1; \
	fi; \
	file="$(BACKUP_DIR)/$$backup"; \
	if [ ! -f "$$file" ]; then \
		echo "Backup not found: $$file"; exit 1; \
	fi; \
	echo "Restoring WordPress from $$backup..."; \
	$(COMPOSE) stop wordpress nginx; \
	trap '$(COMPOSE) start wordpress nginx' EXIT; \
	sudo tar -xzf "$$file" -C "/home/$(USERNAME)/data/wordpress"; \
	$(COMPOSE) start wordpress nginx; \
	trap - EXIT; \
	echo "WordPress restored successfully!"

backup-delete: setup
	@set -e; \
	backup="$(BACKUP)"; \
	if [ -z "$$backup" ]; then \
		echo "Usage: make backup-delete BACKUP=<backup>"; \
		exit 1; \
	fi; \
	file="$(BACKUP_DIR)/$$backup"; \
	if [ ! -f "$$file" ]; then \
		echo "Backup not found: $$file"; exit 1; \
	fi; \
	echo "Deleting backup $$backup..."; \
	sudo rm -f "$$file"; \
	echo "Backup deleted successfully!"

clean: setup
	$(COMPOSE) down

fclean: setup
	$(COMPOSE) down --volumes --remove-orphans
	@login=$$(sed -n 's/^LOGIN=//p' srcs/.env); \
		sudo rm -rf /home/$$login/data/database/* /home/$$login/data/wordpress/*

re: fclean all
