#!/bin/bash

## Common Variables
## 
## This script contains common variables for use within other scripts. There's
## no need to source this file as it is sourced by init.sh.
## You may override these and set new variables by creating a file called
## `.config.variables.sh` in the drupal-scripts directory.
## ------------------------------------------------------------

#
# Some default variables
#

# The environment. i.e local, dev, test, prod
APP_ENV=dev

# The directory that contains your entire project.
APP_ROOT=/var/www/html

# The directory that contains your Drupal installation
APP_WEBROOT=$APP_ROOT/web

# The Git branch used for deployment
APP_GIT_BRANCH=master



#
# Other sources for overriding defaults
#

# Source system environment variables.
source_if_exists /etc/environment

# Source a .env file.
source_if_exists $APP_ROOT/.env
source_if_exists $APP_WEBROOT/.env

# Source custom variables
source_if_exists $SCRIPTPATH/../.config.variables.sh
