# Developer documentation

## Prerequisites

Use a Linux virtual machine with Docker Engine, the Docker Compose plugin, `make`, `openssl`, and Git. The Dockerfiles use Debian 12 (Bookworm), the release immediately before Debian 13, which is the current stable release when this project was prepared.

## Configure and launch

1. Clone the repository inside the VM.
2. Run `make setup`. This creates `srcs/.env` from the example when needed, generates four local random secret files, and creates the host directories for the volumes.
3. Edit `srcs/.env`: set `LOGIN` to the learner's login and `DOMAIN_NAME` to `<login>.42.fr`. Set the site title, usernames, and email addresses as needed. The administrator username must not contain `admin` or `administrator`.
4. Make `<login>.42.fr` resolve to the VM's IP address on the machine where the browser runs.
5. Run `make` to build the three service images and start the stack.

The generated secret files are under `secrets/` and are excluded from version control. Keep backups of them outside Git if the site must be recoverable. The `.env` file is also local and ignored; `srcs/.env.example` is the tracked template.

## Management commands

- `make build` builds images.
- `make up` builds and starts the stack.
- `make ps` shows service and health status.
- `make logs` follows service logs.
- `make stop` and `make start` stop and start existing containers.
- `make down` removes containers and the network but preserves named volumes.
- `make fclean` removes containers and named volumes, permanently deleting site and database data.

Equivalent Compose commands use `docker compose -f srcs/docker-compose.yml --env-file srcs/.env`.

## Data and persistence

The named `database` volume stores MariaDB files at `/home/<login>/data/database` on the VM. The named `wordpress_files` volume stores WordPress files at `/home/<login>/data/wordpress`. Container rebuilds and `make down` preserve these directories. `make fclean` removes the named volumes; the host data directories may need to be emptied by the developer if a fully fresh initialization is required.

## Validation checklist

- Run `docker compose ... config` and review the resolved volume paths, secret files, network, and published ports.
- Build and launch from a clean VM, then confirm all services become healthy.
- Confirm only TCP port 443 is published and NGINX negotiates TLS 1.2 or TLS 1.3.
- Load the site, sign in as both WordPress users, and confirm the administrator name contains neither prohibited word.
- Restart the stack and confirm both the database and uploaded WordPress files persist.
- Review the repository and Git status to make sure no generated secret or password is tracked.
