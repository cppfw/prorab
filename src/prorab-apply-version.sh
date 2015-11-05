#!/bin/bash

#first argument is version and second is the file to apply version to

outfile=$(echo $2 | sed -n -e "s/\(.*\)\.in$/\1/p")
#echo $outfile

sed -e "s/\$(version)/$1/g" $2 > $outfile
