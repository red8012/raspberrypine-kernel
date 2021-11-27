#!/bin/sh
set -xeuo pipefail

apk add alpine-sdk sudo doas
adduser -G abuild -g "Alpine Package Builder" -s /bin/sh -D builder
echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
addgroup builder abuild
su -c 'sh builder.sh' builder
