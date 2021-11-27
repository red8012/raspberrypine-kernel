#!/bin/sh
set -xeuo pipefail

cd ~
pwd
mkdir -p main/linux-rpi
mv APKBUILD config-changes-rpi4.aarch64 main/linux-rpi
cd main/linux-rpi

abuild-keygen -a -i -n
abuild checksum
abuild -r
