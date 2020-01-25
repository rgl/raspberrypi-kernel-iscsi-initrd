#!/bin/bash
set -eux

# make sure the system is up-to-date.
apt-get update
apt-get dist-upgrade -y

# make sure the iscsi package are installed.
apt-get install -y --no-install-recommends open-iscsi

# create the initrd tarball.
tarball_path="$PWD/raspberrypi-kernel-iscsi-initrd.tgz"
pushd /boot
sed -i -E 's,#(INITRD)=.+,\1=Yes,g' /etc/default/raspberrypi-kernel
dpkg-reconfigure raspberrypi-kernel
tar czf "$tarball_path" initrd.img*
tar tf "$tarball_path"
sha256sum "$tarball_path"
popd
