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
GIT_USER=${GIT_USER:-$USER}
GIT_MAIL=${GIT_MAIL:-$USER'@example.com'}

VIRTUAL_HOST=${VIRTUAL_HOST:-"$GRAV_INSTANCE_NAME".localhost}
GRAV_SYSTEM_REPOSITORY=${GRAV_SYSTEM_REPOSITORY:-$GRAV_GIT}

# This script might not work well on OSX : (just replace the command by a random string)
#GIT_PULL_DIRECTORY_NAME=${GIT_PULL_DIRECTORY_NAME:-"$(cat /dev/urandom | env LC_CTYPE=C tr -cd 'a-f0-9' | head -c 32)"}
GIT_PULL_SCRIPT_NAME=${GIT_PULL_DIRECTORY_NAME:-"${DOCKERNAME}"'_pull'}


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
  echo "Grav accounts shared directory : " /www/.shared/$SHARED_ACCOUNTS_GROUP
  echo "EXPOSED HTTP PORT: " $HTTP_PORT
  echo "GIT USER NAME : "$GIT_USER
  echo "GIT USER MAIL : "$GIT_MAIL
  echo "PULL ADDRESS : http://<vhost>.<hostname>/git/${GIT_PULL_DIRECTORY_NAME}/pull.php"

  if [[ ! -z "$HTPASSWD_NAME" ]]; then
      echo "htpasswd file : "./www/.htpasswd/$HTPASSWD_NAME
  fi

  if [[ ! -z "$LETSENCRYPT_HOST" ]]; then
    echo "LETSENCRYPT_HOST=${LETSENCRYPT_HOST}"
  fi;

  if [[ ! -z "$LETSENCRYPT_EMAIL" ]]; then
    echo "LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}"
  fi;

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
mkdir ./www/$DOCKERNAME 2> /dev/null

read -p "Is this configuration OK ? Press a key to continue or CTRL+C to abort ..."


export HTTP_PORT;
export VIRTUAL_HOST;
export LOCAL_USER_ID;

cat docker-compose.yml.tpl > ./cache/$DOCKERNAME.yml

if [[ ! -z "$HTTP_PORT" ]] || [[ ! -z "$HTTPS_PORT" ]] ; then
  cat ./cache/$DOCKERNAME.yml |sed -e "s|#ports:|ports:|" > /tmp/$DOCKERNAME.yml
  cat /tmp/$DOCKERNAME.yml > ./cache/$DOCKERNAME.yml
fi

if [[ ! -z "$HTTP_PORT" ]]; then
  cat ./cache/$DOCKERNAME.yml |sed -e "s|#HTTP_PORT#|- ${HTTP_PORT}:80|" > /tmp/$DOCKERNAME.yml
  cat /tmp/$DOCKERNAME.yml > ./cache/$DOCKERNAME.yml
fi;

if [[ ! -z "$HTTPS_PORT" ]]; then
  cat ./cache/$DOCKERNAME.yml |sed -e "s|#HTTP_PORT#|- ${HTTPS_PORT}:443|" > /tmp/$DOCKERNAME.yml
  cat /tmp/$DOCKERNAME.yml > ./cache/$DOCKERNAME.yml
fi;

if [[ ! -z "$VIRTUAL_HOST" ]]; then
  cat ./cache/$DOCKERNAME.yml |sed -e "s|#VIRTUAL_HOST#|- VIRTUAL_HOST=${VIRTUAL_HOST}|" > /tmp/$DOCKERNAME.yml
  cat /tmp/$DOCKERNAME.yml > ./cache/$DOCKERNAME.yml
fi;

if [[ ! -z "$LOCAL_USER_ID" ]]; then
  cat ./cache/$DOCKERNAME.yml |sed -e "s|#LOCAL_USER_ID#|- LOCAL_USER_ID=${LOCAL_USER_ID}|" > /tmp/$DOCKERNAME.yml
  cat /tmp/$DOCKERNAME.yml > ./cache/$DOCKERNAME.yml
fi;

if [[ ! -z "$LETSENCRYPT_HOST" ]]; then
  cat ./cache/$DOCKERNAME.yml |sed -e "s|#LETSENCRYPT_HOST#|- LETSENCRYPT_HOST=${LETSENCRYPT_HOST}|" > /tmp/$DOCKERNAME.yml
  cat /tmp/$DOCKERNAME.yml > ./cache/$DOCKERNAME.yml
fi;

if [[ ! -z "$LETSENCRYPT_EMAIL" ]]; then
  cat ./cache/$DOCKERNAME.yml |sed -e "s|#LETSENCRYPT_EMAIL#|- LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL}|" > /tmp/$DOCKERNAME.yml
  cat /tmp/$DOCKERNAME.yml > ./cache/$DOCKERNAME.yml
fi;


if [[ ! -z "$HTPASSWD_NAME" ]]; then
  touch ./www/.htpasswd/${HTPASSWD_NAME}
  cat ./cache/$DOCKERNAME.yml |sed -e "s|#HTPASSWD#|- ./www/.htpasswd/${HTPASSWD_NAME}:/www/.htpasswd|" > /tmp/$DOCKERNAME.yml
  cat /tmp/$DOCKERNAME.yml > ./cache/$DOCKERNAME.yml
fi;


cat ./cache/$DOCKERNAME.yml |sed -e "s|#WWW_VOLUME#|- ./www/${DOCKERNAME}:/www/${DOCKERNAME}|" > /tmp/$DOCKERNAME.yml
cat /tmp/$DOCKERNAME.yml > ./cache/$DOCKERNAME.yml

if [ ! -z "$SHARED_ACCOUNTS_GROUP" ]; then
  echo "WILL STORE ACCOUNTS in  ./www/.shared/$SHARED_ACCOUNTS_GROUP/"
  cat ./cache/$DOCKERNAME.yml |sed -e "s|#SHARED_ACCOUNT_VOLUME#|- ./www/.shared/$SHARED_ACCOUNTS_GROUP/:/www/${DOCKERNAME}/user/accounts|" > /tmp/$DOCKERNAME.yml
  cat /tmp/$DOCKERNAME.yml > ./cache/$DOCKERNAME.yml
fi

cat ./cache/$DOCKERNAME.yml

sudo docker network create www

cat ./cache/$DOCKERNAME.yml | sudo docker-compose -f - -p $DOCKERNAME down
sudo docker pull nnynn/dkgr-nginx:latest
sudo docker pull nnynn/dkgr-php:latest
cat ./cache/$DOCKERNAME.yml | sudo docker-compose -f - -p $DOCKERNAME up -d

read -p "ready to configure NGINX ... change the default.conf root is to /www/$DOCKERNAME (PRESS A KEY OR CTRL+C TO ABORT)"
sudo docker exec $NGINXNAME /bin/sh -c "(sed -i -e \"s|#DOCKERNAME#|$DOCKERNAME|\" /etc/nginx/conf.d/default.conf)"

if [ ! -z "$HTPASSWD_NAME" ]; then
  sudo docker exec $NGINXNAME /bin/sh -c "(sed -i -e \"s|#AUTH_BASIC#|auth_basic|\" /etc/nginx/conf.d/default.conf)"
  sudo docker exec $NGINXNAME /bin/sh -c "(cat /etc/nginx/conf.d/default.conf)"
fi;




echo "Will use the following default.conf :"
sudo docker exec $NGINXNAME /bin/sh -c "(cat /etc/nginx/conf.d/default.conf)"
sudo docker exec $NGINXNAME /bin/sh -c "/usr/sbin/nginx -s reload"


echo "Will retrieve grav from given location (PRESS A KEY or CTRL+C)"

# SET GIT USER NAME AND MAIL :
./bin/git $DOCKERNAME config --global user.email "${GIT_MAIL}"
./bin/git $DOCKERNAME config --global user.name "${GIT_USER}"


#if [[ ! "$(ls -A ./www/$DOCKERNAME/bin)" ]]; then
if [[ ! -d "./www/$DOCKERNAME/bin" ]]; then
  #If GRAV_GIT IS NOT SET then
  if [ -z "$GRAV_GIT" ]; then
    # Print from GRAV_ZIP
    echo "Extract grav skeleton from : " $GRAV_ZIP
    if [[ ! $GRAV_ZIP =~ \.zip$ ]]; then
      echo "Invalid zip files";
      exit 0;
    fi
    sudo unzip $GRAV_ZIP -d ./www/$DOCKERNAME
  else
    # Otherwise print GRAV_GIT
    echo "Grav system is cloned from : " $GRAV_GIT
    (cd ./www/$DOCKERNAME && git init)
    (cd ./www/$DOCKERNAME && git remote add origin  $GRAV_GIT)
    #./bin/git $DOCKERNAME clone $GRAV_GIT '.'
    ./bin/git $DOCKERNAME fetch origin
    ./bin/permissions-fixing "$DOCKERNAME"
    ./bin/git $DOCKERNAME reset --hard origin/master
    ./bin/git $DOCKERNAME submodule update --init --recursive
  fi
else
  echo "THE TARGET DIRECTORY IS NOT EMPTY (SKIPPING DOWNLOAD)"
fi

if [ ! -z "$GRAV_SYSTEM_REPOSITORY" ]; then
  echo checks "./www/$DOCKERNAME/.git" exists
  if [[ ! -d "./www/$DOCKERNAME/.git" ]]; then
    echo "create a git structure"
    cp ./nginx/grav_gitignore ./www/$DOCKERNAME/.gitignore
    (cd ./www/$DOCKERNAME && git init)
    (cd ./www/$DOCKERNAME && git remote add origin  $GRAV_SYSTEM_REPOSITORY)
  else
    echo "change git origin url"
    (cd ./www/$DOCKERNAME && git remote set-url origin $GRAV_SYSTEM_REPOSITORY)
  fi;
else
  echo "no system git repository"
fi


mkdir -p ./www/$DOCKERNAME/logs
mkdir -p ./www/$DOCKERNAME/images
mkdir -p ./www/$DOCKERNAME/assets
mkdir -p ./www/$DOCKERNAME/user/data


### SET GIT PULL SCRIPT WITH THE PROPER NAME INTO THE PULL DIRECTORY OF THE GRAV INSTALL

rm -Rf ./www/${DOCKERNAME}/git/
mkdir ./www/${DOCKERNAME}/git/
cp ./nginx/git/gitignore ./www/${DOCKERNAME}/git/.gitignore
mkdir "./www/${DOCKERNAME}/git/${GIT_PULL_DIRECTORY_NAME}/"
cp -R ./nginx/git/* "./www/${DOCKERNAME}/git/${GIT_PULL_DIRECTORY_NAME}/"

PULL_SCRIPT="/www/${DOCKERNAME}/git/${GIT_PULL_DIRECTORY_NAME}/pull.sh"
sudo docker exec $NGINXNAME /bin/sh -c "(chown www:www ${PULL_SCRIPT} && chmod +x ${PULL_SCRIPT} && ls -l ${PULL_SCRIPT})"
sudo docker exec $NGINXNAME /bin/sh -c "(sed -i -e \"s|#DOCKERNAME#|$DOCKERNAME|\" ./www/${DOCKERNAME}/git/${GIT_PULL_SCRIPT_NAME}/pull.php)"
sudo docker exec $NGINXNAME /bin/sh -c "(sed -i -e \"s|#DOCKERNAME#|$DOCKERNAME|\" ./www/${DOCKERNAME}/git/${GIT_PULL_SCRIPT_NAME}/commit.php)"



echo "pull request can be send to http://host:$HTTP_PORT/git/${GIT_PULL_SCRIPT_NAME}/pull.php"

sudo docker exec $NGINXNAME /bin/sh -c "(ls -l ${PULL_SCRIPT})"
./bin/permissions-fixing "$DOCKERNAME"
sudo docker exec $NGINXNAME /bin/sh -c "(ls -l ${PULL_SCRIPT})"


read -p "grav has been downloaded (press a key) ..."

summary;

echo "Grav is supposed to be accessible on http://localhost:$HTTP_PORT/ (unless you changed the port)"
echo "If this is a new install (grav has been downloaded from official repo), you have to run grav-admin/grav $NGINXNAME install"
