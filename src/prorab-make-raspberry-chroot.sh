#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "error: this script must be run as root" 1>&2
   exit 1
fi

apt-get install -qq -y debootstrap qemu-user-static binfmt-support sbuild

chrootDir=$1
chrootArch=armhf
chrootDebVer=jessie
chrootDebMirror=http://archive.raspbian.org/raspbian

mkdir $chrootDir

debootstrap --foreign --no-check-gpg --include=fakeroot,build-essential --arch=$chrootArch $chrootDebVer $chrootDir $chrootDebMirror

cp /usr/bin/qemu-arm-static $chrootDir/usr/bin/

chroot $chrootDir ./debootstrap/debootstrap --second-stage

sbuild-createchroot --arch=$chrootArch --foreign --setup-only $chrootDebVer $chrootDir $chrootDebMirror


#receive GPG keys for repositories
chroot $chrootDir apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8B48AD6246925553 7638D0442B90D010 CBF8D6FD518E17E1 379CE192D401AB61

echo "deb [arch=$chrootArch] $chrootDebMirror $chrootDebVer main" > $chrootDir/etc/apt/sources.list
