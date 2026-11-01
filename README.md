*This project has been created as part of the 42 curriculum by nbasheer.*

# Inception

## Description

Inception builds a small web hosting stack with Docker Compose. NGINX is the only public service and accepts HTTPS connections on port 443. It sends PHP requests to WordPress with PHP-FPM. WordPress stores its content in MariaDB. Each service has its own Dockerfile based on Debian 12, and the services communicate over a private Docker bridge network.

The persistent database and website files use named Docker volumes backed by `/home/<login>/data` on the Linux host. Passwords are generated locally into Docker Compose secret files and are excluded from Git.

### Project description and design choices

- **Virtual machines and Docker:** a virtual machine runs a complete guest operating system with its own kernel. A Docker container shares the host kernel and isolates an application process, so it usually uses fewer resources. This project runs Docker inside a Linux virtual machine as required by the subject.
- **Secrets and environment variables:** environment variables are convenient for non-sensitive settings such as a domain or database name. Passwords are passed as Docker secrets mounted as files, which keeps them out of the Compose environment and image build instructions.
- **Docker network and host network:** the bridge network gives each service private name-based access to the others. Host networking would expose services directly on the host network and weaken this separation.
- **Docker volumes and bind mounts:** the database and WordPress files live in two named volumes, declared in the top-level `volumes:` section and referenced by name from the services. Because the subject requires the data to be stored in `/home/<login>/data`, the `local` driver is configured with `driver_opts` pointing to those host directories. No service mounts a host path directly: a plain bind mount hard-codes a host path in each service and bypasses Docker's volume management, whereas a named volume can be listed, inspected and removed with `docker volume`.

The source tree contains one Dockerfile and its configuration/entrypoint files for each of NGINX, WordPress/PHP-FPM, and MariaDB. `srcs/docker-compose.yml` defines the services, secrets, volumes, and private network.

## Instructions

Run the project from the root of this repository inside your Linux virtual machine. Install Docker Engine with the Compose plugin and Git first. The project is configured for the 42 login `nbasheer` and the domain `nbasheer.42.fr`. Add a hosts-file entry mapping `nbasheer.42.fr` to the VM's IP address. The domain must resolve to the VM from the computer/browser used to open the site.

Run `make setup` to create missing local secrets and host data directories. Review `srcs/.env` and the four files in `secrets/`; the generated passwords are local and must not be committed. `make` builds and starts the stack. Open `https://nbasheer.42.fr/`; the browser will warn that the automatically generated TLS certificate is self-signed. The WordPress login page is at `/wp-login.php` and the administration panel is at `/wp-admin/`.

Useful commands are `make ps`, `make logs`, `make stop`, `make start`, `make restart`, and `make down`. `make fclean` also deletes the named volumes and their data.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress documentation](https://wordpress.org/documentation/)
- [WP-CLI documentation](https://make.wordpress.org/cli/handbook/)
- [MariaDB documentation](https://mariadb.org/documentation/)
- AI was used to interpret the subject, plan and draft the configuration & documentation, and identify a validation checklist.
