set -xeuo pipefail

cd ~/linux-*
eatmydata dpkg-buildpackage -uc -b -a arm64 -P=cross,nopython,nodoc,pkg.linux.notools
