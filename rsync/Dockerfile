FROM alpine
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV RSYNC_VERSION 3.1.3-r2

RUN apk add rsync=${RSYNC_VERSION}

ENTRYPOINT ["rsync"]
