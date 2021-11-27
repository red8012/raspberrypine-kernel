FROM alpine:edge
ADD build.sh /
RUN sh build.sh
