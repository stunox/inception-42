COMPOSE = docker compose -f srcs/docker-compose.yml --env-file srcs/.env

.PHONY: all setup build up down stop start restart logs ps clean fclean re

all: up

setup:
	sh srcs/requirements/tools/init.sh

build: setup
	$(COMPOSE) build

up: build
	$(COMPOSE) up -d

start: setup
	$(COMPOSE) start

stop: setup
	$(COMPOSE) stop

down:
	$(COMPOSE) down

restart: setup
	$(COMPOSE) restart

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

clean:
	$(COMPOSE) down

fclean:
	$(COMPOSE) down --volumes --remove-orphans
	@login=$$(sed -n 's/^LOGIN=//p' srcs/.env); \
		sudo rm -rf /home/$$login/data/database/* /home/$$login/data/wordpress/*

re: fclean all
