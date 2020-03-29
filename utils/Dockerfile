FROM alpine:3
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV OPENSSH_VERSION=8.1_p1-r0
ENV CURL_VERSION=7.67.0-r0
ENV RSYNC_VERSION=3.1.3-r2

RUN apk add --no-cache \
openssh=${OPENSSH_VERSION} \
curl=${CURL_VERSION} \
rsync=${RSYNC_VERSION}
