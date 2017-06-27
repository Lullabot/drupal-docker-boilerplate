#!/bin/bash

# Argument passed to shell script.
OPTION="$1"
# Options this script can accept.
OPTIONS=['start','stop','destroy','latest_logs','all_logs']

# Are we inside host or container? Docker only exists in host.
IN_HOST=`which docker`
# Is Docker-Sync being used?
SYNC=`which docker-sync`

# PHP container name, if running
function GET_CONTAINER {
  echo `docker ps -f name=php --format '{{.Names}}'`
}

#-----------------------------------
# Start docker
#-----------------------------------
if [ "$IN_HOST" ] && [ "$OPTION" = 'start' ]; then
  if [ $SYNC ]; then docker-sync start; fi
  docker-compose up -d
  docker ps
  echo "Docker containers have been started. To enter php container type:"
  CONTAINER=$(GET_CONTAINER)
  echo "docker exec -it $CONTAINER /bin/bash"

#-----------------------------------
# Stop docker
#-----------------------------------
elif [ "$IN_HOST" ] && [ "$OPTION" = 'stop' ]; then
  docker-compose stop
  echo "Docker containers have been stopped."

#-----------------------------------
# Destroy docker containers
#-----------------------------------
elif [ "$IN_HOST" ] && [ "$OPTION" = 'destroy' ]; then
  docker-compose down -v
  if [ $SYNC ]; then docker-sync clean; fi
  echo "Docker containers have been destroyed."

#-----------------------------------
# View latest logs
#-----------------------------------
elif [ "$IN_HOST" ] && [ "$OPTION" = 'latest_logs' ]; then
  echo "View latest log entries, end viewing with ctl-c."
  docker-compose logs -f --tail=1

#-----------------------------------
# View all logs
#-----------------------------------
elif [ "$IN_HOST" ] && [ "$OPTION" = 'latest_logs' ]; then
  echo "View all log entries, end viewing with ctl-c."
  docker-compose logs -f

#-----------------------------------
# You not in the right place!
#-----------------------------------
else
  if [[ ${OPTIONS[*]} =~ "$OPTION" ]]; then
    if [ $IN_HOST ]; then
      echo "You must be in the container to run '$OPTION'."
    else
      echo "You must not be in the container to run '$OPTION'."
    fi
  else
    echo "'$OPTION' is not a valid option."
  fi
fi
