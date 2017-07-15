# Drupal Boilerplate

Boilerplate to create new Drupal 8 projects that can be managed locally in Docker containers. It uses  [Docker4Drupal](https://github.com/wodby/docker4drupal) for the Docker configuration. You can also use [Drupal Composer Project](https://github.com/drupal-composer/drupal-project) to create a Drupal installation from scratch.

## Prerequisites

1. [Docker](https://docs.docker.com/engine/installation/) (for MacOS, Windows, or Linux)
2. [Docker-Compose](https://docs.docker.com/compose/install/) (only required for Linux, already included in Docker for MacOSX and Windows)
3. [Docker-Sync](http://docker-sync.io) (not necessary for Linux, improves file syncing performance on MacOSX and Windows)

## Installation

1. Fork this repository to create a new project.
2. Copy `/docker/env-example` to `.env` to set an environment value for `COMPOSE_PROJECT_NAME`. This will be the machine name for the project, and should be alphanumeric. This name will be used as the prefix for all the Docker containers, so it should be unique among all containers that might be running on the same host. If the project name is `drupal8`, the php container name will be `drupal8_php_1`. The project name is also used in the container urls. For the same `drupal8` project name, the browser path will be `http://drupal8.docker.localhost:8000`.
3. Add the Drupal codebase, placing the Drupal root in the `/web` subdirectory of this repository.
3. Add the following code to the bottom of settings.php:
	
	```
	// Add settings for Docker4Drupal containers.
	if (!empty($_SERVER['WODBY_DIR_FILES'])) {
  		include '/var/www/html/docker/settings.docker.local.php';
	}
	```
4. Add a database and files, depending on your needs. See the sections below to `Mount an Existing Database`, `Mount Existing Files`, or `Install Vanilla Drupal 8 Site` using composer and Drupal Console.


## Docker-Compose Overrides
Docker-compose is configured differently depending on the capabilities of the host operating system. When sharing a repository we want to keep the host-specific configuration out of the `docker-compose` file.

You can create a file called [/docker-compose.override.yml](https://docs.docker.com/compose/extends/) that can contain overrides to the main `docker-compose.yml` file. Docker will automatically merge the contents of the two files together when you execute `docker-compose up`.

The override file doesn't need to be a complete `docker-compose` file, it only needs to contain the override values.

You can use this feature to set up host-specific overrides. There are examples in the `/docker` folder of some of the configuration changes that could be used. Copy one of the examples to `/docker-compose.override.yml` or create an empty file and combine any number of overrides in that file.

Similarly to `settings.local.php` in a Drupal installation, this localized file is not stored in the shared repository, allowing each user to adjust configuration as necessary for their own environment.

See information below on how to adjust configuration for `SSH`, `HTTPS/SSL`, or `Docker-Sync for MacOSX or Windows`.

If you don't need any overrides, don't create the file. Docker will choke on an empty `docker-compose.override.yml` file.

## Host Operations
Once you have configured `docker-compose.overide.yml`, if needed, and prepared the database and files from the directions below, use the following commands to manage the containers. All are run from the root of the docker repository on the host machine. 

The first time you `start` the containers, it may take several minutes. After that they will rely on cached copies of the images and should start very quickly. The containers will start up in the background so it's hard to tell when they're ready. You can tail the logs to see what's happening. When you see `KEEPALIVE` entries from `mailhog` the containers are ready.

- Type `docker-compose up -d` to launch the Docker containers. The `-d` means it will start in detached mode, allowing you to continue to use that terminal window while the containers run in the background.
- Type `docker-compose stop` to pause them without destroying the data.
- Type `docker-compose down -v` to completely tear down the Docker containers and their volumes.
- Type `docker-compose logs -f` to view and tail the log entries from the containers. To stop viewing the logs, use `ctl-c` to exit out of the logs without actually stopping the containers..
- To communicate from one container to another, treat the name of the service as if it was the IP address of a remote server. For instance, to get into the mariadb database from the php container, set the host as `mariadb`, i.e.:

```
mysql -udrupal -pdrupal -hmariadb
```

## Container Operations

 Move into the container from the host using the `docker exec` command, using the project name that was added to `.env`, for instance if `COMPOSE_PROJECT_NAME=drupal8`:
 
  ```
  docker exec -it drupal8_php_1 /bin/bash
  ```
To return to the host from the container, just type `exit`.
 
You will be using the `root` user inside the container, so should have permissions to do anything. The code in your git repository can be found at `/var/www/html` in the container. Drupal's docroot should be located at `/var/www/html/web`, using the Drupal-Project pattern. Try the following inside the container to see that the containers were mounted successfully:

```
cd web
drush st
```

To view the site in a browser, navigate to the following url, replacing `[COMPOSE_PROJECT_NAME]`  with the project name you put in the `.env` file. With some browsers and operating systems any path ending in `localhost` will work automatically, otherwise you may need update your `hosts` file so your browser will know it's a local url. For instance, if `COMPOSE_PROJECT_NAME=drupal8`:

```
http://drupal8.docker.localhost:8000
```
You should be able to add, delete, and edit your codebase from either inside or outside the containers, and immediately see the results inside your containers. Permanent changes should made in the host rather than the container, and can be saved using `git commit` on the host.

## Docker-Sync for Mac OSX and Windows
The solution to file performance problems on Mac OSX and Windows is to use [Docker-Sync](http://docker-sync.io). To adjust the repository for Docker-Sync, do the following:

1. Install [Docker-Sync](http://docker-sync.io).
2. A file called `/docker-sync.yml` is included in the repository. It will be ignored if Docker-Sync is not being used. It should not need any changes unless are trying to use Docker-Sync to manage a swarm or multiple networks.
2. Copy the file `/docker/docker-compose.docker-sync.yml` to `/docker-compose.override.yml` to adjust the `docker-compose` values.
3. Run `docker-sync` before starting or after stopping:
	- Execute `docker-sync start` before running `docker-compose up`.
	- Execute `docker-sync stop` after running `docker-compose stop`.
	- Execute `docker-sync clean` after running `docker-compose down`.

## Mount an Existing Database

There are a couple ways to populate the database inside the container. 

- The folder `/mariadb-init` will be checked when the container is spun up. If there are any SQL files in that folder, they will be executed at that time. The default repository contains a SQL file to create an empty Drupal database. Alternately, a SQL dump file could be added to that folder to populate the database from another Drupal site.
- If the Drush alias file has been updated with values from a source site, and SSH credentials have been set up correctly in the docker-compose file, the container can be populated using drush inside the container: `drush sql-sync @docker.source @docker.container`


## Mount Existing Files

There are a couple ways to populate the files inside the container:

- Copy the public files directly into `web/sites/default/files`.
- Copy the files into `/files/public` and create a relative symlink to `sites/default/files`. The relative symlink is necessary since the absolute path will be different inside the container. For instance,

	```
	cd sites/default
	ln -s ../../../files/public files
	``` 
- If the Drush alias file has been updated with values from a source site, and SSH credentials have been set up correctly in the docker-compose file, don't copy the files in at all, just create the symlink or add an empty files directory, then wait until the container has been started and move into it and populate the files with:

	```
	drush rsync @docker.source:%files/ @docker.container:%files`
	```

## Configure SSH

To communicate with servers outside the Docker containers, for instance to be able to use `drush sql-sync`, the Docker-compose file passes ssh credentials and keys through to the container as a volume, `- ~/.ssh:/root/.ssh`. You should have a ssh config file in your home directory, `./ssh/config`, that identifies the user name that matches your ssh keys. This will allow you to ssh as yourself, instead of the root user, from inside the container. For example, `/ssh/config` might look like:

```
Host example.com
User karen
```

If that is not the correct location for your SSH credentials, override the `docker-compose.yml` value in `docker-compose.override.yml`.

## Using Drush in the Container

Drush will be available inside the container. Drush files can be used to provide localized values applicable to the containerized site:

- The file `/drush/site-aliases/docker.aliases.drushrc.php`creates drush aliases `@docker.container` and `@docker.source`. The `container` values should be correct. Update the values in `source` to match an external site, if any, to make it easy to copy files and the database to and from that location.
- The file `/drush/drushrc.php` uses the drush aliases to create simple aliases to copy files and database from the source by executing `drush syncfiles`, `drush syncprivate`, and `drush syncdb`.


## Configure HTTPS/SSL
You may want the containers to use SSL, either to test SSL operations or for consistency with the production urls.

- Set up a self-signed SSL certificate for use in local HTTPS containers. On a Mac, do the following, other operating systems may need to be handled differently. All containers using a domain like `*.docker.localhost` will be able share this cert. The cert is be stored on the host rather than in the container, so this only needs to be done once:
	
```
## Make a directory for the cert.
mk dir ~/ssl/certs
	
# Create a wildcard cert.
openssl req \
  -newkey rsa:2048 \
  -x509 \
  -nodes \
  -keyout ~/ssl/certs/key.pem \
  -new \
  -out ~/ssl/certs/cert.pem \
  -subj /CN=*.docker.localhost \
  -reqexts SAN \
  -extensions SAN \
  -config <(cat /System/Library/OpenSSL/openssl.cnf \
      <(printf '[SAN]\nsubjectAltName=DNS:*.docker.localhost')) \
  -sha256 \
  -days 720

# Add the cert to Mac's keychain.
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ~/ssl/certs/cert.pem

```

- Copy the file `/docker/docker-compose.ssl.yml` to `/docker-compose.override.yml`, or add its contents to that file if it already exists. 
- Adjust all container urls to use `HTTPS` instead of `HTTP`, and the port `4443` instead of `8000`, for instance:
- HTTP: `http://drupal8.docker.localhost:8000`
- HTTPS: `https://drupal8.docker.localhost:4443`
	

## Install a Vanilla Drupal 8 Site

If you don't already have a codebase, you can pull down a vanilla Drupal site using [Composer](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx). Navigate to the top level of this repository, add a `composer.json` file that requires the desired modules, and run the following command. No parameters are necessary since it will build information from the `composer.json` file located there:

`composer create-project`

Edit the file `/docker/new-site-install.yml`. It is used only if you want to install a vanilla site from scratch. Drupal Console can build a site from that file.

Start the containers, then enter the php container, cd to the `web` directory inside the container, and install a new site with Drupal Console:

`/var/www/html/vendor/bin/drupal chain --file=/var/www/html/docker/new-site-install.yml`

The current version of Drupal Console has a bug that generates a `Drupal Finder` error after the site is installed, but the installation should work fine.

