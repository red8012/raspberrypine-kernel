#!/bin/sh
set -xeuo pipefail

cd ~
pwd
git clone --depth 1 https://gitlab.alpinelinux.org/alpine/aports
mkdir -p ~/aports/testing/raspberrypine-kernel
sudo mv /builder.sh /APKBUILD /config-changes-rpi4.aarch64 ~/aports/testing/raspberrypine-kernel
cd ~/aports/testing/raspberrypine-kernel
chmod 777 *

abuild-keygen -a -i -n
abuild checksum
abuild -r
