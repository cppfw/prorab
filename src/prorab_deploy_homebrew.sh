#!/bin/sh

#Script for quick deployment to homebrew.
#It assumes that homebrew recipes to deploy are in 'homebrew' directory.


while true; do
    case $1 in
        --help)
            echo "Usage:"
            echo "\t$(basename $0) <tap-name>"
            echo " "
            echo "GitHub username and access token should be in GITHUB_USERNAME and GITHUB_ACCESS_TOKEN environment variable."
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
make ver


#clone tap repo
git clone https://github.com/$username/$tapname.git

recipes=$(ls homebrew/*.rb)

echo "$recipes"

for f in recipes
do



done