FROM alpine:edge
RUN apk add alpine-sdk sudo \
  adduser -G abuild -g "Alpine Package Builder" -s /bin/sh -D builder \
  echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER builder
RUN abuild-keygen -a -i -n \
  git clone --depth 1 https://github.com/alpinelinux/aports \
  aports/scripts/bootstrap.sh aarch64
