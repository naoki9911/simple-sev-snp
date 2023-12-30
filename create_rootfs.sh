#!/bin/bash

set -eux

cd $(dirname $0)

ALPINE_VERSION="3.19.0"
ALPINE_IMAGE="alpine-minirootfs-$ALPINE_VERSION-x86_64.tar.gz"
INITRAMFS_NAME="alpine-initrd.img"
ROOTFS_DIR="rootfs"
ADDITIONAL_FILES=("./snpguest/target/x86_64-unknown-linux-musl/debug/snpguest")

if [ ! -e $ALPINE_IMAGE ]; then
	wget https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/$ALPINE_IMAGE -O $ALPINE_IMAGE
fi

if [ -e $ROOTFS_DIR ]; then
        echo $ROOTFS_DIR already exists
fi

mkdir $ROOTFS_DIR
tar -xvf $ALPINE_IMAGE -C $ROOTFS_DIR

for FILE in ${ADDITIONAL_FILES[@]}; do
	cp -r $FILE ./$ROOTFS_DIR/$(basename $FILE)
done

pushd $ROOTFS_DIR
cat > init <<EOF
#! /bin/sh
##
## /init executable file in the initramfs
##
mount -t devtmpfs dev /dev
mkdir /dev/pts
mount -t devpts devpts /dev/pts
mount -t proc proc /proc
mount -t sysfs sysfs /sys

/sbin/getty -n -l /bin/sh 115200 /dev/console

poweroff -f
EOF

chmod +x init

sudo find . -print0 | sudo cpio --null --create --verbose --owner root:root --format=newc | zstd > ../$INITRAMFS_NAME

popd
rm -rf $ROOTFS_DIR
