FROM debian:bookworm-slim

ENV LINUX_VER=5.15.0-3-arm64-unsigned
RUN sh prepare.sh
