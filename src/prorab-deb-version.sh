#!/bin/bash

echo "DEPRECATED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Use myci."

#we want exit immediately if any command fails and we want error in piped commands to be preserved
set -eo pipefail

head -1 $1 | sed -n -e 's/.*(\([\.0-9]*\)\(-[0-9]*\)\{0,1\}).*/\1/p'
