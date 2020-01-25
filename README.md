This contains the initrd binaries needed to boot a rpi from iSCSI.

To build the binaries execute the following command in your Raspberry Pi 4:

```bash
wget -O- https://github.com/rgl/raspberrypi-kernel-iscsi-initrd/raw/master/build.sh | sudo bash
```
