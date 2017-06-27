# Drupal Boilerplate

Boilerplate to create new Drupal 8 projects that can be managed locally in Docker containers. It uses  [Docker4Drupal](https://github.com/wodby/docker4drupal) for the Docker configuration. You can use [Drupal Composer Project](https://github.com/drupal-composer/drupal-project) to create a Drupal installation from scratch.

The codebase could be deployed normally to production, which can just ignore the Docker configuration files, and that Docker would just be available for local development.

## Prerequisites

1. [Composer](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx)
2. [Docker](https://docs.docker.com/engine/installation/) (for MacOS, Windows, or Linux)
3. [Docker-Compose](https://docs.docker.com/compose/install/) (only required for Linux, already included in Docker for MacOS and Windows)
4. [Docker-Sync](http://docs.docker4drupal.org/en/latest/macos/) (not necessary for Linux or Windows, improves file syncing performance on MacOS)

## Configuration

1. Fork this repository to create a new project.
2. Copy `env-example` to `.env` to set an environment value for `COMPOSE_PROJECT_NAME`. This will be the machine name for the project. This name will be used as the prefix for all the Docker containers, so it should be unique among all containers that might be running on the same host. If the project name is `drupal8`, the php container name will be `drupal8_php_1`. The project name is also used in the browser url. For the same `drupal8` project name, the browser path will be `http://drupal8.docker.localhost:8000`.
3. Edit configuration files as needed. These files will be used to provide localized values applicable to the containerized site:
	- `/config/docker/new-site-install.yml` is used only if you want to install a vanilla site from scratch. Drupal Console can build a site from that file.
	- `/drush/site-aliases/docker.aliases.drushrc.php`creates drush aliases `@docker.container` and `@docker.source`. The `container` values should be correct. Update the values in `source` to match an external site to make it easy to copy files and the database to and from that location.
	- `drushrc.php` uses the drush aliases to create simple aliases to copy files and database from the source by executing `drush syncfiles`, `drush syncprivate`, and `drush syncdb`.
4. To communicate with servers outside the Docker containers, the Docker-compose file passes your ssh credentials and keys through to the container as a volume, `- ~/.ssh:/root/.ssh`. You should have a ssh config file in your home directory, `./ssh/config`, that identifies the user name that matches your ssh keys. This will allow you to ssh as yourself, instead of the root user, from inside the container. For example, `/ssh/config` might look like:

```
Host example.com
  User karen
```


## Create Site From Drupal Project

If you don't already have a codebase, you can pull down Drupal files by navigating to the top level of this repository, where `composer.json` is located, and running the following command. No parameters are necessary since it will build information from the `composer.json` file located there. Edit `composer.json` beforehand to require any modules or libraries that should be included in the initial site, the run:

	- `composer create-project`


Start the containers (see details below), then enter the php container, cd to the `web` directory inside the container, and install a new site:

	-  `/var/www/html/vendor/bin/drupal chain --file=/var/www/html/config/docker/new-site-install.yml`
The current version of Drupal Console has a bug that generates a `Drupal Finder` error after the site is installed, but the installation should work fine.

## Container Commands
Use the following commands to manage the containers. The first time you `start` the containers, it may take several minutes. After that they will rely on cached copies of the images and should start very quickly. The containers will start up in the background so it's hard to tell when they're ready. You can tail the logs to see what's happening. When you see `KEEPALIVE` entries from `mailhog` the containers are ready.

1. Type `./manage.sh start` from the host to launch the Docker containers.
2. Type `./manage.sh stop` from the host to pause them without destroying the data.
3. Type `./manage.sh destroy` from the host to completely tear down the Docker containers and their volumes, except for external volumes.
4. Type `./manage.sh latest_logs` to view and tail the latest log entries from the containers, or `./manage.sh all_logs` to view and tail all log entries. With either of these, `ctl-c` will exit out of the logs.
5. The `manage.sh` script is provided as a convenience to avoid a lot of typing. If you prefer to run the Docker commands directly you can review that file to see what commands are used for each purpose.
4. To communicate from one container to another, treat each container's service name as if it was the IP address of a remote server. For instance, to get into the database from the php container, set the host as `mariadb`, i.e.:

```
mysql -udrupal -pdrupal -hmariadb
```

## Container Operations

 Move into the container from the host using the `docker exec` command, using the project name that was added to `.env`: `docker exec -it [COMPOSE_PROJECT_NAME]_php_1 /bin/bash`. To return to the host from the container, just type `exit`.
 
You will be using the `root` user inside the container, so should have permissions to do anything. The code in your git repository can be found at `/var/www/html` in the container. Drupal's docroot is located at `/var/www/html/web`. Try the following to see that the installation was successful:

```
cd web
drush st
```

To view the site in a browser, navigate to the following url, replacing `[COMPOSE_PROJECT_NAME]`  with the project name you put in the `.env` file. With some browsers and operating systems any path ending in `localhost` will work automatically, otherwise you may need update your `hosts` file so your browser will know it's a local url.

```
http://[COMPOSE_PROJECT_NAME].docker.localhost:8000
```
You should be able to add, delete, and edit your codebase from either inside or outside the containers, and immediately see the results inside your containers. Changes made inside the containers won't persist outside the container. Changes made outside the containers will persist, and can be saved using `git commit`.

