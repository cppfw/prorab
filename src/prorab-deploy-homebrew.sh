#!/bin/bash

#Script for quick deployment to homebrew.
#It assumes that homebrew recipes to deploy are in 'homebrew' directory.


while [[ $# > 0 ]] ; do
	case $1 in
		--help)
			echo "Usage:"
			echo "\t$(basename $0) -t <tap-name> <recipe-file-name.rb.in> ..."
			echo " "
			echo "GitHub username and access token should be in PRORAB_GIT_USERNAME and PRORAB_GIT_ACCESS_TOKEN environment variables."
			echo " "
			echo "Example:"
			echo "\t$(basename $0) -t igagis/tap homebrew/*.rb.in"
			exit 0
			;;
		-t)
			shift
			tapname=$1
			shift
			;;
		*)
			infiles="$infiles $1"
			shift
			;;
	esac
done

echo "Deploying to homebrew repo..."

[ -z "$tapname" ] && echo "Error: -t option is not given" && exit 1;

if [ -z "$infiles" ]; then
	echo "No input files specified, taking all files from 'homebrew' folder..."
	infiles=$(ls homebrew/*.rb.in)
fi


#parse homebrew tap name
tap=(${tapname//\// })

username="${tap[0]}"
tapname="homebrew-${tap[1]}"

echo "username: $(username), tapname: $(tapname)"

#update version numbers
echo "getting version from Debian changelog"
version=$(prorab-deb-version.sh debian/changelog)
#echo $version
prorab-apply-version.sh -v $version $infiles

#clean if needed
rm -rf $tapname

echo "Setting git credentials helper mode to store credentials for unlimited time..."
git config --global credential.helper store
[ $? != 0 ] && echo "Error: 'git config --global credential.helper store' failed" && exit 1;


echo "Cloning tap repo from github..."
#clone tap repo
repo=https://$PRORAB_GIT_USERNAME:$PRORAB_GIT_ACCESS_TOKEN@github.com/$username/$tapname.git

#Make sure PRORAB_GIT_ACCESS_TOKEN is set
[ -z "$PRORAB_GIT_ACCESS_TOKEN" ] && echo "Error: PRORAB_GIT_ACCESS_TOKEN is not set" && exit 1;

#Make sure PRORAB_GIT_USERNAME is set
[ -z "$PRORAB_GIT_USERNAME" ] && echo "Error: PRORAB_GIT_USERNAME is not set" && exit 1;

cutSecret="sed -e s/$PRORAB_GIT_ACCESS_TOKEN/<secret>/"


#echo "git clone $repo | $cutSecret"
git clone $repo 2>&1 | $cutSecret
[ $? != 0 ] && echo "Error: 'git clone' failed" && exit 1;

#echo "$infiles"

for fin in $infiles
do
	f=$(echo $fin | sed -n -e 's/\(.*\)\.in$/\1/p')
	url=$(awk '/\ *url\ *"http.*\.tar.gz"$/{print $2}' $f | sed -n -e 's/^"\(.*\)"$/\1/p')
#    echo "url = $url"
	filename=$(echo $url | sed -n -e 's/.*\/\([^\/]*\.tar\.gz\)$/\1/p')
	curl -L -O $url
	echo "downloaded $filename"
	sha=($(shasum -a 256 $filename))
	sha=${sha[0]}
	echo "calculated sha256 = $sha"
	sedcommand="s/\$(sha256)/$sha/"
#    echo "sedcommand = $sedcommand"
	sed $sedcommand $f > $f.out
	mv $f.out $f
	cp $f $tapname
	specfilename=$(echo $f | sed -n -e 's/^homebrew\/\(.*\)$/\1/p')
	(cd $tapname && git add $specfilename && git commit -a -m"new version of $f")
done

(cd $tapname; set -o pipefail && git push 2>&1 | $cutSecret)
