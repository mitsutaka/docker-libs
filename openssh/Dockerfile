FROM alpine:3
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV OPENSSH_VERSION 8.4_p1-r2
ENV CURL_VERSION 7.74.0-r0

RUN apk add --no-cache openssh=${OPENSSH_VERSION} curl=${CURL_VERSION}

ENTRYPOINT ["ssh"]
