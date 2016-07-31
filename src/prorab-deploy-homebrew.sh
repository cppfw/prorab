#!/bin/bash

#Script for quick deployment to homebrew.
#It assumes that homebrew recipes to deploy are in 'homebrew' directory.


while true; do
    case $1 in
        --help)
            echo "Usage:"
            echo "\t$(basename $0) <tap-name>"
            echo " "
            echo "GitHub username and access token should be in HOMEBREW_GITHUB_USERNAME and HOMEBREW_GITHUB_ACCESS_TOKEN environment variable."
            echo " "
            echo "Example:"
            echo "\t$(basename $0) igagis/tap"
            exit 0
        ;;
        *)
            break
        ;;
    esac
done


#parse homebrew tap name
tap=(${1//\// })

username="${tap[0]}"
tapname="homebrew-${tap[1]}"

#update version numbers
version=$(prorab-deb-version.sh debian/changelog)
#echo $version
prorab-apply-version.sh $version homebrew/*.in

#clean if needed
rm -rf $tapname

git config --global credential.helper store


#clone tap repo
repo=https://$HOMEBREW_GITHUB_USERNAME:$HOMEBREW_GITHUB_ACCESS_TOKEN@github.com/$username/$tapname.git
cutSecret="sed -n -e s/$HOMEBREW_GITHUB_ACCESS_TOKEN/<secret>/p"
#echo "git clone $repo | $cutSecret"
git clone $repo 2>&1 | $cutSecret

recipes=$(ls homebrew/*.rb)

#echo "$recipes"

for f in $recipes
do
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

(cd $tapname; git push 2>&1 | $cutSecret)
