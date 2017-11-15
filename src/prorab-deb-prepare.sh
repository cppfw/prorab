#!/bin/bash

#we want exit immediately if any command fails and we want error in piped commands to be preserved
set -eo pipefail

# This script is used for preparing the debian package before building with dpkg-buildpackage.


echo "Preparing Debian package for building..."

soname=$(cat src/soname.txt 2>/dev/null || true) #ignore error if there is no soname.txt file

if [ -z "$soname" ]; then
	echo "no soname found, using empty soname"
	soname=
else
	echo "Detected soname = $soname"
fi

listOfInstalls=$(ls debian/*.install.in 2>/dev/null || true) #allow package without *.install.in

for i in $listOfInstalls; do
	echo "Applying soname to $i..."
	cp $i ${i%.install.in}$soname.install
done

echo "Applying soname to debian/control.in..."

sed -e "s/\$(soname)/$soname/g" debian/control.in > debian/control

echo "Debian package prepared for building!"
