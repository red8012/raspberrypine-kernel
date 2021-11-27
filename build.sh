#!/bin/sh
set -xeuo pipefail

apk add alpine-sdk sudo
adduser -G abuild -g "Alpine Package Builder" -s /bin/sh -D builder
echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
mv builder.sh APKBUILD config-changes-rpi4.aarch64 /home/builder
cd /home/builder
su -c 'sh builder.sh' builder
