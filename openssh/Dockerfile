FROM alpine:3
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV OPENSSH_VERSION 8.3_p1-r1
ENV CURL_VERSION 7.69.1-r3

RUN apk add --no-cache openssh=${OPENSSH_VERSION} curl=${CURL_VERSION}

ENTRYPOINT ["ssh"]
