#!/bin/bash

#Script for quick deployment to custom github-based cygwin repository.


while [[ $# > 0 ]] ; do
    case $1 in
        --help)
            echo "Usage:"
            echo "	$(basename $0) -r <repo-name> [<spec1.cygport.in> <spec2.cygport.in>...]"
            echo " "
            echo "Environment variable PRORAB_GIT_ACCESS_TOKEN should be set to git access token, it will be stripped out from the script output."
            echo " "
            echo "Example:"
            echo "	$(basename $0) -r igagis/cygwin-repo cygwin/*.cygport.in"
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

[ -z "$reponame" ] && source prorab-error.sh "repo name is not given";

if [ -z "$infiles" ]; then
	infiles=$(ls cygwin/*.cygport.in)
fi

[ -z "$infiles" ] && source prorab-error.sh "no input files found";

echo "Deploying to cygwin..."

#update version numbers
version=$(prorab-deb-version.sh debian/changelog)

#echo "current package version is $version, applying it to cygport files..."
#
#prorab-apply-version.sh -v $version $infiles
#
#echo "version $version applied to cygport files"



#=== clone repo ===

#Make sure PRORAB_GIT_USERNAME is set
[ -z "$PRORAB_GIT_USERNAME" ] && echo "Error: PRORAB_GIT_USERNAME is not set" && exit 1;

#Make sure PRORAB_GIT_ACCESS_TOKEN is set
[ -z "$PRORAB_GIT_ACCESS_TOKEN" ] && source prorab-error.sh "Error: PRORAB_GIT_ACCESS_TOKEN is not set";

cutSecret="sed -e s/$PRORAB_GIT_ACCESS_TOKEN/<secret>/"

repodir=cygwin-repo

#clean if needed
rm -rf $repodir

repo=https://$PRORAB_GIT_USERNAME:$PRORAB_GIT_ACCESS_TOKEN@github.com/$reponame.git

git clone $repo $repodir 2>&1 | $cutSecret

[ $? -ne 0 ] && source prorab-error.sh "'git clone' failed";

#--- repo cloned ---

architectures="x86 x86_64"

architecture=$(uname -m)

for a in $architectures; do
	if [[ "$architecture" == "$a" ]]; then architectureFound=true; break; fi
done
[ -z "$architectureFound" ] && source prorab-error.sh "Unknown architecture: $architecture";


#=== create directory tree if needed ===
for a in $architectures; do
	mkdir -p $repodir/$a/release
done
#---

#=== copy packages to repo and add them to git commit ===
for fin in $infiles
do
	dist=$(echo $fin | sed -n -e 's/\(.*\)\.cygport\.in$/\1/p')-$version-1.$architecture/dist
#	echo $dist
	cp -r $dist/* $repodir/$architecture/release

	f=$(echo $fin | sed -n -e 's/\(.*\)\.cygport\.in$/\1/p' | sed -n -e 's/.*\///p')

	if [ -z "$packages" ]; then packages="$f"; else packages="$packages, $f"; fi
done 
#---

#run mksetupini for all architectures
(
cd $repodir
for a in $architectures; do
	mksetupini --arch $a --inifile=$a/setup.ini --releasearea=. &&
	bzip2 <$a/setup.ini >$a/setup.bz2 &&
	xz -6e <$a/setup.ini >$a/setup.xz
done
cd ..
)

(cd $repodir && git add . && git commit -a -m"version $version of $packages")

#clean
#echo "Removing cloned repo..."
#rm -rf $repodir
