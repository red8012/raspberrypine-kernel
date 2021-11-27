#!/bin/sh
set -xeuo pipefail

ls
mv APKBUILD config-changes-rpi4.aarch64 /home/builder
apk add alpine-sdk sudo
adduser -G abuild -g "Alpine Package Builder" -s /bin/sh -D builder
echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
su builder
cd /home/builder
ls
