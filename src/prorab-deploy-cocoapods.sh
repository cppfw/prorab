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


#update version numbers
version=$(prorab-deb-version.sh debian/changelog)
#echo $version
prorab-apply-version.sh $version cocoapods/*.podspec.in

pod repo push $1 cocoapods/*.podspec
