#!/bin/bash
DOCKERNAME=$1

# Checks there is at least one arg
if [ $# -lt 1 ]; then
    echo "you must provide the grav instance name (namely the docker-compose name)"
    echo ./clean.sh dockername;
    exit 1
fi

DOCKERNAME=${1:-"default"}
ENV_FILE=./config/$DOCKERNAME.env
if [[ ! -f "$ENV_FILE" ]]; then
    echo "Environment file $ENV_FILE not found"
    echo "Please provide a valid env file name"
    echo "For instance : "
    echo "    clean.sh grav : will use the file config/grav.env"
    echo "    clean.sh : will use the file config/default.env"
    exit 0
fi
source $ENV_FILE

VIRTUAL_HOST=${VIRTUAL_HOST:-"$GRAV_INSTANCE_NAME".localhost}


export HTTP_PORT;
export VIRTUAL_HOST;
export LOCAL_USER_ID;


read -p  "This will destroy your grav install ! CTRL+C to abort."
sudo docker-compose -f docker-compose.yml.tpl -p $DOCKERNAME down
sudo rm -Rvf ./www/$DOCKERNAME
