set -xeuo pipefail

echo "deb-src http://deb.debian.org/debian bookworm main" >> /etc/apt/sources.list
cd ~

apt update
apt install -y dpkg-dev eatmydata
apt install -y fakeroot git kernel-wedge quilt ccache flex bison libssl-dev dh-exec rsync libelf-dev bc crossbuild-essential-arm64

apt-get build-dep -y linux-image-$LINUX_VER
apt-get source -y linux-image-$LINUX_VER


# apt install build-essential bc kmod cpio flex libncurses5-dev libelf-dev libssl-dev dwarves
# apt install linux-source-$LINUX_VER
# tar xaf /usr/src/linux-source-$LINUX_VER.tar.xz
# cd linux-source-$LINUX_VER