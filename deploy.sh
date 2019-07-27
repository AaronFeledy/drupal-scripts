#!/bin/bash

## Code Deployer
## 
## Use this script to deploy the latest code for an environment.
## ------------------------------------------------------------

# Load common functions and variables
SCRIPTPATH="${0%/*}";
. $SCRIPTPATH/common/init.sh

# Require root.
# Uncomment if users will need to sudo in order to overwrite files in the code base. If users did not sudo, the script
# will warn the user and stop execution.
#
# require_root()

# Make sure the necessary environment variables are set
if [ -z "$APP_ROOT" ] || [ -z "$APP_WEBROOT" ] || [ -z "$APP_ENV" ] || [ -z "$APP_GIT_BRANCH" ]; then
  die "This script requires values for the APP_ENV, APP_ROOT, APP_WEBROOT, and APP_GIT_BRANCH environment variables."
fi

# Require confirmation before deploying to production
if [[ $APP_ENV == 'prod' ]]; then
  echo
  yell "WARNING: YOU ARE DEPLOYING TO PRODUCTION"
  read -p "$($TXT_CYAN)$(echo -e 'Please type "production" to continue deployment \n\b> ')$($TXT_RESET)" -re
  if [[ $REPLY != "production" ]]; then
    die "You did not type production. Aborting deployment."
  fi
fi

echo
tell "Executing deployment sequence..."

#
# Fetch latest changes
#

deploy_fetch() {
  echo
  tell "Fetching latest from git repository..."
  cd $APP_ROOT && git fetch origin $APP_GIT_BRANCH --force --prune --prune-tags
}

if ! deploy_fetch ; then
  die "Failed to fetch latest from Git repository."
fi


#
# Update code
#

deploy_reset() {
  echo
  tell "Resetting code..."
  cd $APP_ROOT && git checkout $APP_GIT_BRANCH
  cd $APP_ROOT && git reset --hard origin/$APP_GIT_BRANCH
}

# Reset code to match origin
if ! deploy_reset ; then
  die "Code reset failed."
fi


#
# Build steps
#

# Install dependencies
composer -d "${APP_WEBROOT}" install --no-interaction

# Rebuild Drupal caches using the latest code
drush -r "${APP_WEBROOT}" cache:rebuild

# Run Drupal's database update script
drush -r "${APP_WEBROOT}" updatedb --yes

# Import configuration changes
drush -r "${APP_WEBROOT}" config:import --yes

# Two imports are necessary for sites using the config_split module
drush -r "${APP_WEBROOT}" config:import --yes

# Rebuild the caches with everything updated
drush -r "${APP_WEBROOT}" cache:rebuild


#
# Post Deployment Tasks
#

# Execute `.config.post-deploy.sh` if it exists in the drupal-scripts directory.
POST_DEPLOY=$SCRIPTPATH/.config.post-deploy.sh && test -f $POST_DEPLOY && try bash $POST_DEPLOY

#
# Complete
#

echo
tell "Deployment complete!"
echo
