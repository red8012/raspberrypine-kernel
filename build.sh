#!/bin/sh
set -xeuo pipefail

cd ~/linux-*
dpkg-buildpackage -uc -b -a arm64
