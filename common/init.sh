#!/bin/bash

## Script Initializer
## 
## This script contains common variables and functions to initialize other
## scripts within this project. Source this script at the beginning of other
## scripts by using:
##
## SCRIPTPATH="${0%/*}";
## . $SCRIPTPATH/common.sh
##
## ------------------------------------------------------------

# The $SCRIPTPATH variable represents the directory where this script resides.
SCRIPTPATH="${0%/*}";

# Source system environment variables
# . /etc/environment

# Source a .env file. Adjust the relative path to  your .env
# file as needed.
# . $SCRIPTPATH/../../.env

# Some text colors
TXT_RESET="tput sgr 0"
TXT_BOLD="tput bold"
TXT_CYAN="tput setaf 6"
TXT_YEL="tput setaf 3"
TXT_RED="tput setaf 1"

# Some useful functions
tell() { echo "$($TXT_YEL)$*$($TXT_RESET)" >&2; }
yell() { echo "$($TXT_RED)$(tput bold)$*$($TXT_RESET)" >&2; }
die() { echo; yell "$*"; echo; exit 111; }
try() { "$@" || yell "Cannot $*"; }
