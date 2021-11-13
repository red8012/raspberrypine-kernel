pkgname=linux-rpi
pkgver=5.15.1
case $pkgver in
*.*.*)	_kernver=${pkgver%.*};;
*.*)	_kernver=${pkgver};;
esac
pkgrel=0
pkgdesc="Linux kernel with Raspberry Pi patches"
url=https://github.com/raspberrypi/linux
depends="mkinitfs linux-firmware-brcm linux-firmware-cypress"
_depends_dev="perl gmp-dev elfutils-dev bash mpc1-dev mpfr-dev"
makedepends="$_depends_dev sed installkernel bc linux-headers linux-firmware
	bison flex openssl1.1-compat-dev findutils
"
options="!strip !check"
_rpi_repo="git://github.com/raspberrypi/linux.git"
_linux_repo="git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git"
source="https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$_kernver.tar.xz
	https://cdn.kernel.org/pub/linux/kernel/v5.x/patch-$pkgver.xz
	https://dev.alpinelinux.org/archive/rpi-patches/rpi-$pkgver-alpine.patch

	config-changes-rpi4.aarch64
	"
subpackages=""
arch="aarch64"
license="GPL-2.0"
_flavors=
for _i in $source; do
	case $_i in
	config-*.$CARCH)
		_f=${_i%.$CARCH}
		_f=${_f#config-changes-}
		_flavors="$_flavors ${_f}"
		[ "linux-$_f" != "$pkgname" ] && subpackages="$subpackages linux-${_f}::$CBUILD_ARCH"
		subpackages="$subpackages linux-${_f}-dev:_dev:$CBUILD_ARCH"
		;;
	esac
done

case "$CARCH" in
	aarch64) _carch="arm64" ;;
	arm*) _carch="arm" ;;
esac

prepare() {
	local _patch_failed=
	cd "$srcdir"/linux-$_kernver
	if [ "${pkgver%.0}" = "$pkgver" ]; then
		msg "Applying patch-$pkgver.xz"
		unxz -c < "$srcdir"/patch-$pkgver.xz | patch -p1 -N
	fi

	# first apply patches in specified order
	for i in $source; do
		case $i in
		*.patch)
			msg "Applying $i..."
			if ! patch -s -p1 -N -i "$srcdir"/${i##*/}; then
				echo $i >>failed
				_patch_failed=1
			fi
			;;
		esac
	done

	if ! [ -z "$_patch_failed" ]; then
		error "The following patches failed:"
		cat failed
		return 1
	fi

	# remove localversion from patch if any
	rm -f localversion*

	local flavor=
	for flavor in $_flavors; do
		local _builddir="$srcdir"/build-$flavor
		mkdir -p "$_builddir"
		echo "-$pkgrel-$flavor" > "$_builddir"/localversion-alpine
		_genconfig $flavor
		make -C "$srcdir"/linux-$_kernver \
			O="$_builddir" \
			ARCH="$_carch" \
			olddefconfig
		_verifyconfig $flavor
	done
}

# generate config from defconfig and apply local changes.
# config-changes-$flavor.$CARCH holds a list of = delimited
# config command and values used by kernel scripts/config script.
_genconfig() {
	local flavor=$1 defconfig=
	local builddir="$srcdir"/build-$flavor
	local defconfig=
	case $flavor in
		rpi) defconfig=bcmrpi_defconfig
		[ "$CARCH" = "aarch64" ] && defconfig=bcmrpi3_defconfig ;;
		rpi2) defconfig=bcm2709_defconfig ;;
		rpi4) defconfig=bcm2711_defconfig ;;
		*) die "Unknown flavor: $flavor" ;;
	esac

	cp "$srcdir"/linux-$_kernver/arch/$_carch/configs/$defconfig \
		"$builddir"/.config

	while read line; do
		# skip comments
		case "$line" in
			"#"*) continue;;
		esac
		local option=${line%%=*} str=
		local cmd=$(echo $line | cut -d= -f2)
		case "$cmd" in
			y) cmd="enable";;
			n) cmd="disable";;
			m) cmd="module";;
			'"'*) cmd="set-str"; str="${line#*=}";;
			[0-9]*) cmd="set-val"; str="${line#*=}";;
			*) die "Command $cmd not accepted" ;;
		esac
		msg "[$flavor] $cmd: $option $str"
		"$srcdir"/linux-$_kernver/scripts/config \
			--file "$builddir"/.config \
			--${cmd} "$option" "${str//\"/}"
	done < "$srcdir"/config-changes-$flavor.${CARCH}
}

# verify if options are set to correct value
_verifyconfig() {
	local flavor=$1
	local builddir="$srcdir"/build-$flavor
	while read line; do
		[ ${line:0:1} = "#" ] && continue
		local option=${line%%=*} str= invert=
		local cmd=$(echo $line | cut -d= -f2)
		case "$cmd" in
			enable) str="$option=y" ;;
			disable) str="$option"; invert="-v" ;;
			module) str="$option=m" ;;
			set-val) str="$option=${line##*=}" ;;
			set-str) str=${line##*=}
				str="$option=\"${str//\"/}\"" ;;
		esac
		grep -q $invert "^$str" "$builddir"/.config || \
			die "Config: $option not properly set!"
	done < "$srcdir"/config-changes-$flavor.${CARCH}
}

build() {
	unset LDFLAGS
	for i in $_flavors; do
		cd "$srcdir"/build-$i
		local _kver=$(make kernelversion)
		if [ "$_kver" != "$pkgver" ]; then
			error "Version in Makefile ($_kver) does not correspond with pkgver ($pkgver)"
			return 1
		fi
		make ARCH="$_carch" CC="${CC:-gcc}" \
			KBUILD_BUILD_VERSION="$((pkgrel + 1 ))-Alpine"
	done
}

_package() {
	local _buildflavor="$1" _outdir="$2"
	local _abi_release=${pkgver}-${pkgrel}-${_buildflavor}

	cd "$srcdir"/build-$_buildflavor

	mkdir -p "$_outdir"/boot "$_outdir"/lib/modules

	local _install
	case "$CARCH" in
	arm*)
		_install="zinstall dtbs_install"
		;;
	aarch64)
		_install="install dtbs_install"
		;;
	*)
		_install=install
		;;
	esac

	cd "$srcdir"/build-$_buildflavor
	# modules_install seems to regenerate a defect Modules.symvers. Work
	# around it by backing it up and restore it after modules_install
	cp Module.symvers Module.symvers.backup

	local INSTALL_DTBS_PATH="$_outdir"/boot
	make -j1 modules_install $_install \
		ARCH="$_carch" \
		INSTALL_MOD_PATH="$_outdir" \
		INSTALL_PATH="$_outdir"/boot \
		INSTALL_DTBS_PATH="$INSTALL_DTBS_PATH"
	cp Module.symvers.backup Module.symvers

	rm -f "$_outdir"/lib/modules/${_abi_release}/build \
		"$_outdir"/lib/modules/${_abi_release}/source
	rm -rf "$_outdir"/lib/firmware

	install -D -m644 include/config/kernel.release \
		"$_outdir"/usr/share/kernel/$_buildflavor/kernel.release

	if [ "$CARCH" = "aarch64" ]; then
		mv -f "$INSTALL_DTBS_PATH"/broadcom/*.dtb \
			"$INSTALL_DTBS_PATH"
		rmdir "$INSTALL_DTBS_PATH"/broadcom
	fi
}

genpatch() {
	local RPI_REPO_PATH="$HOME/repositories/linux-rpi"
	msg "Checking out/pulling the Linux kernel git repository.."
	mkdir -p "$RPI_REPO_PATH" && cd "$RPI_REPO_PATH"
	git clone "$_linux_repo" "$RPI_REPO_PATH" 2>/dev/null || git pull
	msg "Fetching raspberry git repository.."
	git remote add rpi "$_rpi_repo" 2>/dev/null || true
	git fetch rpi
	msg "Generating rpi patch: rpi-$pkgver.patch"
	mkdir -p "$srcdir"
	git diff v$pkgver remotes/rpi/rpi-${pkgver%.*}.y > \
		"$srcdir"/rpi-$pkgver.patch
	msg "Sending patch to dev.alpinelinux.org.."
	scp "$srcdir"/rpi-$pkgver.patch \
		dev.alpinelinux.org:/archive/rpi-patches/rpi-$pkgver.patch
	cd "$startdir" && abuild checksum
}

# main flavor installs in $pkgdir
package() {
	_package rpi "$pkgdir"
}

# subflavors install in $subpkgdir
rpi2() {
	depends="mkinitfs linux-firmware-brcm linux-firmware-cypress"
	_package rpi2 "$subpkgdir"
}

rpi4() {
	depends="mkinitfs linux-firmware-brcm linux-firmware-cypress"
	_package rpi4 "$subpkgdir"
}

_dev() {
	local _flavor=$(echo $subpkgname | sed -E 's/(^linux-|-dev$)//g')
	local _abi_release=${pkgver}-${pkgrel}-$_flavor
	# copy the only the parts that we really need for build 3rd party
	# kernel modules and install those as /usr/src/linux-headers,
	# simlar to what ubuntu does
	#
	# this way you dont need to install the 300-400 kernel sources to
	# build a tiny kernel module
	#
	pkgdesc="Headers and script for third party modules for $_flavor kernel"
	depends="$_depends_dev"
	local dir="$subpkgdir"/usr/src/linux-headers-${_abi_release}

	# first we import config, run prepare to set up for building
	# external modules, and create the scripts
	mkdir -p "$dir"
	cp "$srcdir"/build-$_flavor/.config "$dir"/.config
	echo "-$pkgrel-$_flavor" > "$dir"/localversion-alpine

	make -j1 -C "$srcdir"/linux-$_kernver O="$dir" \
		syncconfig prepare modules_prepare scripts

	# remove the stuff that points to real sources. we want 3rd party
	# modules to believe this is the soruces
	rm "$dir"/Makefile "$dir"/source

	# copy the needed stuff from real sources
	#
	# this is taken from ubuntu kernel build script
	# http://kernel.ubuntu.com/git/ubuntu/ubuntu-zesty.git/tree/debian/rules.d/3-binary-indep.mk
	cd "$srcdir"/linux-$_kernver
	find .  -path './include/*' -prune \
		-o -path './scripts/*' -prune -o -type f \
		\( -name 'Makefile*' -o -name 'Kconfig*' -o -name 'Kbuild*' -o \
		   -name '*.sh' -o -name '*.pl' -o -name '*.lds' \) \
		-print | cpio -pdm "$dir"

	cp -a scripts include "$dir"
	find $(find arch -name include -type d -print) -type f \
		| cpio -pdm "$dir"

	install -Dm644 "$srcdir"/build-$_flavor/Module.symvers \
		"$dir"/Module.symvers

	mkdir -p "$subpkgdir"/lib/modules/${_abi_release}
	ln -sf /usr/src/linux-headers-${_abi_release} \
		"$subpkgdir"/lib/modules/${_abi_release}/build
}
