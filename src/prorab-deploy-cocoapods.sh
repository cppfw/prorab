#!/bin/bash

#Script for quick deployment to cocoapods.
#It assumes that cocoapods specs to deploy are in 'cocoapods' directory.


while true; do
    case $1 in
        --help)
            echo "Usage:"
            echo "\t$(basename $0) <repo-name>"
            echo " "
            echo "Example:"
            echo "\t$(basename $0) igagis"
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

prorab-apply-version.sh $version cocoapods/*.podspec.in

echo "version $version applied to podspec"

cutSecret="sed -n -e s/$HOMEBREW_GITHUB_ACCESS_TOKEN/<secret>/p"

#Need to pass --use-libraries because before pushing the spec it will run 'pod lint'
#on it. And 'pod lint' uses framework integration by default which will fail to copy
#some header files to the right places.
pod repo push $1 cocoapods/*.podspec --use-libraries --allow-warnings 2>&1 | $cutSecret

echo "Deploying to cocoapods done!"
