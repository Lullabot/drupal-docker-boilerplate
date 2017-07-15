# mariadb-init

This folder is only used when this project is run in a Docker container with Docker-Compose. 

Any .sql files in this directory will be automatically executed by the database when the mariadb container is created. These can include database dumps and/or sql queries or commands needed on startup.

Once created, data in the container will persist even when the container is stopped or shut down, as long as this volume is not removed.

The container will afterward ignore the files in this folder. Changing or updating these files later will have no effect on the database in the running container.

To relaunch the container with new or updated .sql files, shut the container down **and remove its volumes**, then start it again, i.e.

```
docker-compose down -v
docker-compose up
```
If there are no .sql files in this folder, no action will be taken when the container is built.
