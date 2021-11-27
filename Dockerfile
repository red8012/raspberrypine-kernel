FROM alpine:edge
ADD build.sh APKBUILD config-changes-rpi4.aarch64 /
RUN sh build.sh
