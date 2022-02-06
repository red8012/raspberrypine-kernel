set -xeuo pipefail

echo "deb-src http://deb.debian.org/debian bookworm main" > /etc/apt/sources.list
cat /etc/apt/sources.list
apt update
apt install -y dpkg-dev eatmydata
apt-get build-dep linux-image-$LINUX_VER
apt-get source linux-source-$LINUX_VER


# apt install build-essential bc kmod cpio flex libncurses5-dev libelf-dev libssl-dev dwarves
# apt install linux-source-$LINUX_VER
# tar xaf /usr/src/linux-source-$LINUX_VER.tar.xz
# cd linux-source-$LINUX_VER