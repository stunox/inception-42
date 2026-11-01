# User documentation

## Services

- NGINX provides the website over HTTPS on port 443.
- WordPress runs PHP through PHP-FPM and provides the site and administration panel.
- MariaDB stores WordPress data.

The containers communicate on a private Docker network. Only NGINX publishes a host port.

## Start and stop

From the repository root in the Linux VM, run `make` to build and start the services. Run `make stop` to stop them while retaining the containers, or `make down` to stop and remove the containers. Run `make start` to restart stopped containers. `make fclean` deletes the containers and persistent database and website data.

## Access

Add the VM's IP address and `<login>.42.fr` to the hosts file on the machine where the browser runs. Then visit `https://<login>.42.fr/`. The TLS certificate is self-signed, so a browser warning is expected. Visit `/wp-admin/` for administration or `/wp-login.php` to sign in.

## Credentials

The administrator username is set by `WP_ADMIN_USER` in `srcs/.env`; a second author account is set by `WP_USER`. Their passwords are in `secrets/wp_admin_password.txt` and `secrets/wp_user_password.txt`. MariaDB credentials are in `secrets/db_password.txt` and `secrets/db_root_password.txt`. These files are created by `make setup`, are ignored by Git, and should remain local to the VM. Change a WordPress password in the WordPress administration panel. Changing database passwords after the database has been initialized requires updating the MariaDB account and the WordPress configuration consistently.

## Check the services

Run `make ps` and confirm all three services are running and healthy. Run `make logs` to view service output. Check the website at `https://<login>.42.fr/` and sign in at `/wp-admin/`.
