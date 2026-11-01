COMPOSE_BASE = docker compose -f srcs/docker-compose.yml --env-file srcs/.env
COMPOSE = $(COMPOSE_BASE) --profile bonus

.PHONY: all setup build up bonus down stop start restart logs ps clean fclean re

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

clean: setup
	$(COMPOSE) down

fclean: setup
	$(COMPOSE) down --volumes --remove-orphans
	@login=$$(sed -n 's/^LOGIN=//p' srcs/.env); \
		sudo rm -rf /home/$$login/data/database/* /home/$$login/data/wordpress/*

re: fclean all
