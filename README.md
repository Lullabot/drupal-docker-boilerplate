# Drupal Boilerplate

This is a boilerplate directory structure for new Drupal 8 installs
using Docker. It includes a workaround for slow mounted volumes in
OSX.

Here's a breakdown for what each directory/file is used for. If you want
to know more please check the README inside the specific directory.


* [docroot](https://github.com/Lullabot/drupal-docker-boilerplate/tree/master/docroot)
 * Where your drupal root should start.
* [drush](https://github.com/Lullabot/drupal-docker-boilerplate/tree/master/drush)
 * Contains project specific drush commands, aliases, and configurations.
* [.gitignore](https://github.com/Lullabot/drupal-docker-boilerplate/blob/master/.gitignore)
 * Contains the a list of the most common excluded files.
* [docker-compose.yml](https://github.com/Lullabot/drupal-docker-boilerplate/blob/master/docker-compose.yml)
 * 
* [Makefile](https://github.com/Lullabot/drupal-docker-boilerplate/blob/master/Makefile)
 *
* [patches.make](http://github.com/Lullabot/drupal-docker-boilerplate/bloh/master/Makefile)
 * This is the file used by Drush Patchfile to manage patches to modules and core. Install it Drush Patchfile into ```drush/commands```
 
## Docker Setup

- Install [Docker](https://www.docker.com/products/docker). For Mac, make sure you are on the beta channel.
- Open ```docker/web/Dockerfile``` and follow the instructions regarding XDebug
- Run ```docker-compose build```
- Run ```docker-compose up``` to bring up all the services
- Your local ```~/.ssh``` folder will be mapped into the container to allow you access remote servers using your usual keypair. Make sure you have an ```~/.ssh/config``` file containing the username mapping to your host, as you will be using root in the container.
```
Host example.com
  User Lullabot
```
If you store your keys elsewhere, edit this in ```docker-compose.yml```

- Check your running containers with ```docker ps```
```
docker ps -a
CONTAINER ID        IMAGE                               COMMAND                  CREATED             STATUS                    PORTS                               NAMES
a830387f49ba        drupaldockerboilerplate_web                 "apache2-foreground"     3 hours ago         Up 3 hours                0.0.0.0:32799->80/tcp               drupaldockerboilerplate_web_1
f0d359ad2531        drupaldockerboilerplate_mysql               "docker-entrypoint.sh"   2 days ago          Up 3 hours                0.0.0.0:32796->3306/tcp             drupaldockerboilerplate_mysql_1
65765243b8b7        drupaldockerboilerplate_mysqldata           "/bin/bash"              2 days ago          Exited (0) 3 hours ago                                        drupaldockerboilerplate_mysqldata_1           9300/tcp, 0.0.0.0:32776->9200/tcp
```

In this example, your site will be available at http://localhost:32799. MySQL is available at localhost:32796, however an internal network is created between the containers and so drupaldockerboilerplate_web_1 will access  drupaldockerboilerplate_mysql_1 via port 3306.

The container is mounted with a volume which maps your local code checkout to ```/var/www/mirror```. These files are watched by UnisonFS and any changes are synced over to the directory ```/var/www/html```.
This is a workaround for slow volumes in OSX.

- Enter the web container with ```docker exec -it drupaldockerboilerplate_web_1 /bin/bash```
- It'll take a few moments for all your local files to sync into the container, so check that they're all there before continuing. In a new terminal window, exec into the container again and run ```tail -f /var/log/supervisor/unison-stdout---supervisor-*``` to watch the file sync log.
- When files have finished syncing, from ```/var/www/html```

## XDebug

If you're using PHPStorm, setup is as follows:
- Make sure your remote settings are configured in ```docker/web/Dockerfile``` (run ```docker-compose build``` again if you
change this)
- Add the [XDebug helper browser extension](https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc) and configure it to use PHPStorm's IDE key
- Click the telephone icon in the PHPStorm toolbar to enable listening for PHP Debug connections
- Enable the browser extension, set a breakpoint in code and refresh the page. Cachegrind profiling data will be saved
into ```volumes/xdebug_profiler```

## Make

A Makefile is provided which provides the following commands:

- update
