#!/bin/bash
GRAV_INSTANCE_NAME=${1:-"default"}
ENV_FILE=./config/$GRAV_INSTANCE_NAME.env
if [[ ! -f "$ENV_FILE" ]]; then
    echo "Environment file $ENV_FILE not found"
    echo "Please provide a valid env file name"
    echo "For instance : "
    echo "    install.sh grav : will use the file config/grav.env"
    echo "    install.sh : will use the file config/default.env"
    exit 0
fi
source $ENV_FILE

LOCAL_USER_ID="$(id -u $USER)"

VIRTUAL_HOST=${VIRTUAL_HOST:-"$GRAV_INSTANCE_NAME".localhost}

function summary {
  echo '----------- SUMMARY -----------------------'
  echo 'CONFIGURATION FILE = '$ENV_FILE
  echo 'Grav instance name is '$GRAV_INSTANCE_NAME
  echo "LOCAL_USER_ID is " $LOCAL_USER_ID

  #If GRAV_GIT IS NOT SET then
  if [ -z "$GRAV_GIT" ]; then
    # Print from GRAV_ZIP
    echo "Grav system is extrated from : " $GRAV_ZIP
  else
    # Otherwise print GRAV_GIT
    echo "Grav system is cloned from : " $GRAV_GIT
  fi

  echo "VIRTUAL_HOST are : " $VIRTUAL_HOST
  echo "Grav System will be commited in : " $GRAV_SYSTEM_REPOSITORY
  echo "Grav pages will be commited in : " $GRAV_PAGE_REPOSITORY
  echo "EXPOSED HTTP PORT: " $HTTP_PORT

  echo '-------------------------------------------'
}

echo
echo
echo "This script is meant to be executed as a normal user (non root)"
echo
echo "It will configure LOCAL_USER_ID to your USER ID (current user has $(id -u $USER)) in docker-compose.yml"

echo
summary;

DOCKERNAME="$GRAV_INSTANCE_NAME"
NGINXNAME="$DOCKERNAME"_web_1
mkdir ./www/$DOCKERNAME

read -p "Is this configuration OK ? Press a key to continue or CTRL+C to abort ..."


export HTTP_PORT;
export VIRTUAL_HOST;
export LOCAL_USER_ID;

cat docker-compose.yml.tpl > ./cache/$DOCKERNAME.yml

if [ ! -z "$HTTP_PORT" ] || [ ! -z "$HTTPS_PORT" ] ; then
  cat ./cache/$DOCKERNAME.yml |sed -e "s|#ports:|ports:|" > /tmp/$DOCKERNAME.yml
  cat /tmp/$DOCKERNAME.yml > ./cache/$DOCKERNAME.yml
fi

if [ ! -z "$HTTP_PORT" ]; then
  cat ./cache/$DOCKERNAME.yml |sed -e "s|#HTTP_PORT#|- ${HTTP_PORT}:80|" > /tmp/$DOCKERNAME.yml
  cat /tmp/$DOCKERNAME.yml > ./cache/$DOCKERNAME.yml
fi;

if [ ! -z "$HTTPS_PORT" ]; then
  cat ./cache/$DOCKERNAME.yml |sed -e "s|#HTTP_PORT#|- ${HTTPS_PORT}:443|" > /tmp/$DOCKERNAME.yml
  cat /tmp/$DOCKERNAME.yml > ./cache/$DOCKERNAME.yml
fi;

if [ ! -z "$VIRTUAL_HOST" ]; then
  cat ./cache/$DOCKERNAME.yml |sed -e "s|#VIRTUAL_HOST#|- VIRTUAL_HOST=${VIRTUAL_HOST}|" > /tmp/$DOCKERNAME.yml
  cat /tmp/$DOCKERNAME.yml > ./cache/$DOCKERNAME.yml
fi;

if [ ! -z "$LOCAL_USER_ID" ]; then
  cat ./cache/$DOCKERNAME.yml |sed -e "s|#LOCAL_USER_ID#|- LOCAL_USER_ID=${LOCAL_USER_ID}|" > /tmp/$DOCKERNAME.yml
  cat /tmp/$DOCKERNAME.yml > ./cache/$DOCKERNAME.yml
fi;

cat ./cache/$DOCKERNAME.yml |sed -e "s|#WWW_VOLUME#|- ./www/${DOCKERNAME}:/www/${DOCKERNAME}|" > /tmp/$DOCKERNAME.yml
cat /tmp/$DOCKERNAME.yml > ./cache/$DOCKERNAME.yml

cat ./cache/$DOCKERNAME.yml

sudo docker network create www

cat ./cache/$DOCKERNAME.yml | sudo docker-compose -f - -p $DOCKERNAME down
cat ./cache/$DOCKERNAME.yml | sudo docker-compose -f - build
cat ./cache/$DOCKERNAME.yml | sudo docker-compose -f - -p $DOCKERNAME up -d

read -p "ready to configure NGINX ... change the default.conf root is to /www/$DOCKERNAME (PRESS A KEY OR CTRL+C TO ABORT)"
sudo docker exec $NGINXNAME /bin/sh -c "(sed -i -e \"s|#DOCKERNAME#|$DOCKERNAME|\" /etc/nginx/conf.d/default.conf)"

echo "Will use the following default.conf :"
sudo docker exec $NGINXNAME /bin/sh -c "(cat /etc/nginx/conf.d/default.conf)"
sudo docker exec $NGINXNAME /bin/sh -c "/usr/sbin/nginx -s reload"



echo "Will retrieve grav from given location (PRESS A KEY or CTRL+C)"


if [[ ! "$(ls -A ./www/$DOCKERNAME)" ]]; then
  #If GRAV_GIT IS NOT SET then
  if [ -z "$GRAV_GIT" ]; then
    # Print from GRAV_ZIP
    echo "Extract grav skeleton from : " $GRAV_ZIP
    if [[ ! $GRAV_ZIP =~ \.zip$ ]]; then
      echo "Invalid zip files";
      exit 0;
    fi
    unzip $GRAV_ZIP -d ./www/$DOCKERNAME
  else
    # Otherwise print GRAV_GIT
    echo "Grav system is cloned from : " $GRAV_GIT
    ./bin/git $DOCKERNAME clone $GRAV_GIT '.'

    if [ ! -z "$GIT_USER" ]; then
      ./bin/git $DOCKERNAME config --global user.email "${GIT_MAIL}"
      ./bin/git $DOCKERNAME config --global user.name "${GIT_USER}"
    fi

  fi
else
  echo "THE TARGET DIRECTORY IS NOT EMPTY (SKIPPING DOWNLOAD)"
fi

mkdir -p ./www/$DOCKERNAME/logs
mkdir -p ./www/$DOCKERNAME/images
mkdir -p ./www/$DOCKERNAME/assets
mkdir -p ./www/$DOCKERNAME/user/data

read -p "grav has been downloaded (press a key) ..."

./bin/permissions-fixing "$DOCKERNAME"

summary;

echo "Grav is supposed to be accessible on http://localhost:$HTTP_PORT/ (unless you changed the port)"
echo "If this is a new install (grav has been downloaded from official repo), you have to run grav-admin/grav $NGINXNAME install"
