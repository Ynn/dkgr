# Grav docker
A docker that provides tools supporting grav (nginx and php)

This tools can be used to :
+ 1) Install the environment for an existing grav cloned from a git repository
+ 2) Install a new grav from the grav master repository

## Quick start

In this section, we will download a skeleton and create a grav from this skeleton.

First, download the skeleton from grav web site :
```bash
cd skeleton;
./get-skel course-hub
```

A course.env file already exists. You can edit the configuration if you want :
```bash
cat config/course.env
```

Here is the sample file (course.env)
```markup
### SAMPLE FILE

# Where from the original grav should be taken
# You have to choose between a directory or git
# Git takes precedence over zip file

GRAV_ZIP="./skeleton/course-hub.zip"

# Where to commit the grav system :
GRAV_SYSTEM_REPOSITORY=""

# Where to commit the page (git submodule of system)
GRAV_PAGE_REPOSITORY=""

# Default port to expose :
HTTP_PORT=8085

VIRTUAL_HOST=course.localhost, course.example.com
```


To install the corresponding "course" grav, simply run install.sh (as a normal user) :

```bash
./install.sh course
```

A www user is created inside the container. Its user id matches the id of the user who called install.sh.

You can then call ./bin/<cmd> to manage your container. The format is always :
```bash
./bin/cmd <container_name> [Arguments, ...]
```

For instance, the following command open a bash shell in /www/grav-folder with the www user.
```
./bin/shell course
```

Gpm, Grav and plugin cli commands have their `./bin` equivalents. For instance, you can run the following command to create a new user :

```bash
 ./grav-admin/plugin course login newuser -u guest -e guest@example.org -P b -N "Guest" -p 'Passw0rd'
 ```

Go to http://localhost:8085/ or log to http://localhost:8085/admin

## GIT

If you want to use git with ssh, you should add authorized keys in the .ssh directory.

```bash
# to be run in the dkgr directory :
ssh-keygen -f ./.ssh/id_rsa
```

The `.ssh` directory is mapped to /home/www/.ssh directory of all containers.

The bin/git command provides a way to call git from the container :

```bash
# bin/git <container> [arguments, ...]
$ bin/git demo pull
www@demo_php_1$> git 'pull'
Already up-to-date.
```



## Configuration and file description

+ **docker-compose.yml** : contains the default configuration for dockers. You have to change the LOCAL_USER_ID and the port to match your preferences.
+ **install.sh** : automated install (see hereafter). Creates and runs docker containers.
+ **config** : site configuration env.file. See the default.env file for an example
+ **clean.sh** : delete docker containers as well as grav !
+ **nginx** : contains relevant files for nginx container
    + Dockefile : the dockerfile used
    + entrypoint.sh : creates a www user before executing CMD. The www user has the LOCAL_USER_ID
    + site.conf : the nginx default configuration. This configuration declares a /www/grav site and should be sufficient for most usage.
+ **php-fpm** : the configuration for php-fpm
    + dockerfile : the dockerfile to build php-fpm
    + entrypoint.sh : creates a www user before executing CMD. The www user has the LOCAL_USER_ID.
+ **www** : contains grav (once clone from git)
+ **grav-admin** : contains a set of script that can be used to configure grav with CLI

The default port is 8080 (can be changed in docker-compose.yml)

The default grav configuration can be found in nginx/site.conf




## Requirements
### Docker Compose
This utility requires [docker-compose 3](https://docs.docker.com/compose/install/).


### Quick install :

Create an env file in config directory

Exemple demo.env
```bash
# Where from the original grav should be taken
# You have to choose between a directory or git
# Git takes precedence over zip file

GRAV_ZIP="./skeleton/grav-skeleton-course-hub-site.zip"
#GRAV_GIT="https://github.com/getgrav/grav.git"

# Where to commit the grav system :
GRAV_SYSTEM_REPOSITORY=""

# Where to commit the page (git submodule of system)
GRAV_PAGE_REPOSITORY=""

# Default port to expose :
HTTP_PORT=8080
```

The grav instance name will be demo

Run install.sh :
```bash
./install.sh demo
```
