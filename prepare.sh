set -xeuo pipefail

echo "deb-src http://deb.debian.org/debian bookworm main" >> /etc/apt/sources.list
cd ~

apt update
apt install -y dpkg-dev eatmydata
apt install -y fakeroot git kernel-wedge quilt ccache flex bison libssl-dev dh-exec rsync libelf-dev bc crossbuild-essential-arm64
apt install -y libssl-dev libelf-dev gcc-11 gcc-arm-linux-gnueabihf zlib1g-dev libcap-dev libpci-dev libglib2.0-dev libudev-dev libwrap0-dev libaudit-dev libbabeltrace-dev libdw-dev libiberty-dev libnewt-dev libnuma-dev libperl-dev libunwind-dev libopencsd-dev python3-dev dvipng gcc-11-aarch64-linux-gnu gcc-arm-linux-gnueabihf

apt-get build-dep -y linux-image-$LINUX_VER
apt-get source -y linux-image-$LINUX_VER


# apt install build-essential bc kmod cpio flex libncurses5-dev libelf-dev libssl-dev dwarves
# apt install linux-source-$LINUX_VER
# tar xaf /usr/src/linux-source-$LINUX_VER.tar.xz
# cd linux-source-$LINUX_VER