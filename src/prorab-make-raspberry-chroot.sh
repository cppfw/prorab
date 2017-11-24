#!/bin/bash

#we want exit immediately if any command fails and we want error in piped commands to be preserved
set -eo pipefail

if [ "$(id -u)" != "0" ]; then
   echo "error: this script must be run as root" 1>&2
   exit 1
fi

while [[ $# > 0 ]] ; do
	case $1 in
		--help)
			echo "Usage:"
			echo "\t$(basename $0) -d <deb-ver> <path-to-chroot-dir> ..."
			echo " "
			echo "Example:"
			echo "\t$(basename $0) -d stretch /srv/chroot/rasp-armhf"
			exit 0
			;;
		-d)
			shift
			chrootDebVer=$1
			shift
			;;
		-p)
			shift
			packages=$1
			shift
			;;
		*)
			chrootDir=$1
			shift
			;;
	esac
done

if [ -z "$chrootDir" ]; then
	echo "error: path-to-chroot-dir is not given"
	exit 1
fi

if [ -z "$packages" ]; then
	packages=
else
	packages=,$packages
fi

chrootArch=armhf

if [ -z "$chrootDebVer" ]; then
	chrootDebVer=stretch
fi

chrootDebMirror=http://archive.raspbian.org/raspbian


apt-get install -qq -y debootstrap qemu-user-static binfmt-support sbuild


mkdir -p $chrootDir

debootstrap --foreign --variant=minbase --no-check-gpg --include=fakeroot,build-essential,subversion,dirmngr$packages --arch=$chrootArch $chrootDebVer $chrootDir $chrootDebMirror

cp /usr/bin/qemu-arm-static $chrootDir/usr/bin/

#sed -i -e 's/systemd//g' $chrootDir/debootstrap/required
#sed -i -e 's/systemd-sysv//g' $chrootDir/debootstrap/required
echo " systemd-sysv " >> $chrootDir/debootstrap/required

chroot $chrootDir ./debootstrap/debootstrap --second-stage

sbuild-createchroot --arch=$chrootArch --foreign --setup-only $chrootDebVer $chrootDir $chrootDebMirror

#copy firmware
chroot $chrootDir svn --non-interactive --trust-server-cert export https://github.com/raspberrypi/firmware/trunk/opt/vc /opt/vc

#receive GPG keys for repositories
chroot $chrootDir apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8B48AD6246925553 7638D0442B90D010 CBF8D6FD518E17E1 379CE192D401AB61

echo "deb [arch=$chrootArch] $chrootDebMirror $chrootDebVer main contrib non-free rpi" > $chrootDir/etc/apt/sources.list
