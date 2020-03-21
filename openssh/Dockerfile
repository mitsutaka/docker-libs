FROM alpine:3
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV OPENSSH_VERSION 8.1_p1-r0

RUN apk add --no-cache openssh=${OPENSSH_VERSION}

ENTRYPOINT ["ssh"]
