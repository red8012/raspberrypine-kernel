#!/bin/sh
set -xeuo pipefail

cd ~
pwd
abuild-keygen -a -i -n
abuild checksum
cat APKBUILD
