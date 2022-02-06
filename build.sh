set -xeuo pipefail

cd ~/linux-*
export DEB_BUILD_PROFILES="cross nopython nodoc pkg.linux.notools"
dpkg-buildpackage -uc -b -a arm64
