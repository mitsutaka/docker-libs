FROM alpine:3
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV RSYNC_VERSION 3.2.7-r0

RUN apk add --no-cache rsync=${RSYNC_VERSION}

ENTRYPOINT ["rsync"]
