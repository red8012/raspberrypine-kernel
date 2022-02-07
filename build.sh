set -xeuo pipefail

cd ~/linux-*
# eatmydata dpkg-buildpackage -uc -b -a arm64 -P=cross,nopython,nodoc,pkg.linux.notools

ARCH=arm64
FEATURESET=none
FLAVOUR=cloud-arm64
export $(dpkg-architecture -a$ARCH)
export PATH=/usr/lib/ccache:$PATH
export DEB_BUILD_PROFILES="cross nopython nodoc pkg.linux.notools"
export MAKEFLAGS="-j8"
export DEBIAN_KERNEL_DISABLE_DEBUG=yes
time fakeroot make -f debian/rules clean
time fakeroot make -f debian/rules orig
time fakeroot make -f debian/rules source
echo "$(dpkg-parsechangelog --show-field Distribution)"
time fakeroot make -f debian/rules.gen setup_${ARCH}_${FEATURESET}_${FLAVOUR}
time eatmydata fakeroot make -f debian/rules.gen binary-arch_${ARCH}_${FEATURESET}_${FLAVOUR}

mkdir ~/deb_artifacts
mv ../*.deb ~/deb_artifacts
ls ~/deb_artifacts
