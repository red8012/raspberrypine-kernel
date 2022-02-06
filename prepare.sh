set -xeuo pipefail

echo "deb-src http://deb.debian.org/debian bookworm main" >> /etc/apt/sources.list
cd ~

dpkg --add-architecture arm64
apt update
apt install -y dpkg-dev eatmydata crossbuild-essential-arm64 build-essential
apt install -y gcc-11:arm64 gcc-arm-linux-gnueabihf:arm64

apt-get build-dep -y linux-image-$LINUX_VER
apt-get source -y linux-image-$LINUX_VER


# apt install build-essential bc kmod cpio flex libncurses5-dev libelf-dev libssl-dev dwarves
# apt install linux-source-$LINUX_VER
# tar xaf /usr/src/linux-source-$LINUX_VER.tar.xz
# cd linux-source-$LINUX_VER