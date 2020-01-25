This contains the initrd binaries needed to boot a rpi from iSCSI.

This is used by [rgl/pxe-raspberrypi-vagrant](https://github.com/rgl/pxe-raspberrypi-vagrant)
because updating the initrd when running in [packer-builder-arm-image](https://github.com/solo-io/packer-builder-arm-image)
does not work.

# Build

To build the binaries execute the following command in your Raspberry Pi 4:

```bash
wget -O- https://github.com/rgl/raspberrypi-kernel-iscsi-initrd/raw/master/build.sh | sudo bash
```

# Raspberry Pi configuration

Configure your rpi boot partition to load initrd and configure the iSCSI boot, e.g.:

```bash
# add support for mounting iscsi targets.
apt-get install -y --no-install-recommends open-iscsi
sed -i -E 's,#(INITRD)=.+,\1=Yes,g' /etc/default/raspberrypi-kernel
# install the initrd binaries needed for mounting an iscsi target.
# NB this is needed because dpkg-reconfigure raspberrypi-kernel does not
#    work under packer-builder-arm-image.
tar xf raspberrypi-kernel-iscsi-initrd.tgz -C /boot

# go to your rpi boot partition.
cd /boot

# configure the rpi bootloader to load initrd.
# see https://www.raspberrypi.org/documentation/configuration/config-txt/README.md
# see https://www.raspberrypi.org/documentation/configuration/config-txt/boot.md
echo "initramfs $(ls initrd.img-*-v7l+) followkernel" >>config.txt

# configure rpi kernel command line to mount the root fs from our iscsi export.
# see "Root on iSCSI" at /usr/share/doc/open-iscsi/README.Debian.gz
(cat | tr '\n' ' ') >cmdline.txt <<EOF
root=UUID=$(blkid --probe --match-tag UUID --output value /srv/iscsi/$name.img)
iscsi_initiator=iqn.2020-01.test:$name
iscsi_target_name=iqn.2020-01.test.gateway:$name.root
iscsi_target_ip=10.10.10.2
iscsi_target_port=3260
rw
rootwait
elevator=deadline
ip=dhcp
console=serial0,115200
console=tty1
EOF
```
