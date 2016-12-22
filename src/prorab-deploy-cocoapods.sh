#!/bin/bash

#Script for quick deployment to cocoapods.
#It assumes that cocoapods specs to deploy are in 'cocoapods' directory.


while [[ $# > 0 ]] ; do
    case $1 in
        --help)
            echo "Usage:"
            echo "	$(basename $0) -r <repo-name> [<spec1.podspec.in> <spec2.podspec.in>...]"
            echo " "
            echo "Environment variable PRORAB_GIT_ACCESS_TOKEN can be set to git access token, so that it will be stripped out from the script output."
            echo " "
            echo "Example:"
            echo "	$(basename $0) -r igagis cocoapods/*.podspec.in"
            exit 0
        ;;
        -r)
			shift
			reponame=$1
			shift
			;;
		*)
			infiles="$infiles $1"
			shift
			;;
    esac
done

if [ -z "$infiles" ]; then
	infiles=$(ls cocoapods/*.rb.in)
fi

echo "Deploying to cocoapods..."

#update version numbers
version=$(prorab-deb-version.sh debian/changelog)

echo "current package version is $version, applying it to podspecs..."

prorab-apply-version.sh -v $version $infiles

echo "version $version applied to podspec"

#Make sure PRORAB_GIT_ACCESS_TOKEN is set
[ -z "$PRORAB_GIT_ACCESS_TOKEN" ] && echo "Error: PRORAB_GIT_ACCESS_TOKEN is not set" && exit 1;

cutSecret="sed -e s/$PRORAB_GIT_ACCESS_TOKEN/<secret>/"

for fin in $infiles
do
    f=$(echo $fin | sed -n -e 's/\(.*\)\.in$/\1/p')

	#Need to pass --use-libraries because before pushing the spec it will run 'pod lint'
	#on it. And 'pod lint' uses framework integration by default which will fail to copy
	#some header files to the right places.
	set -o pipefail && pod repo push $reponame $f --use-libraries --allow-warnings 2>&1 | $cutSecret
done

echo "Deploying to cocoapods done!"
