#!/bin/bash

#Script for quick deployment to cocoapods.
#It assumes that cocoapods specs to deploy are in 'cocoapods' directory.


while true; do
    case $1 in
        --help)
            echo "Usage:"
            echo "	$(basename $0) <repo-name>"
            echo " "
            echo "Environment variable PRORAB_GIT_ACCESS_TOKEN can be set to git access token, so that it will be stripped out from the script output."
            echo " "
            echo "Example:"
            echo "	$(basename $0) igagis"
            exit 0
        ;;
        *)
            break
        ;;
    esac
done

echo "Deploying to cocoapods..."

#update version numbers
version=$(prorab-deb-version.sh debian/changelog)

echo "current package version is $version, applying it to podspec..."

prorab-apply-version.sh -v $version cocoapods/*.podspec.in

echo "version $version applied to podspec"

#Make sure PRORAB_GIT_ACCESS_TOKEN is set
[ -z "$PRORAB_GIT_ACCESS_TOKEN" ] && echo "Error: PRORAB_GIT_ACCESS_TOKEN is not set" && exit 1;

cutSecret="sed -e s/$PRORAB_GIT_ACCESS_TOKEN/<secret>/"

#Need to pass --use-libraries because before pushing the spec it will run 'pod lint'
#on it. And 'pod lint' uses framework integration by default which will fail to copy
#some header files to the right places.
set -o pipefail && pod repo push $1 cocoapods/*.podspec --use-libraries --allow-warnings 2>&1 | $cutSecret

echo "Deploying to cocoapods done!"
