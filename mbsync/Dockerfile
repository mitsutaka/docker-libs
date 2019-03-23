FROM ubuntu:18.04
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV ISYNC_VERSION 1.3.0-1ubuntu0.18.04.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends isync=${ISYNC_VERSION} ca-certificates \
    && apt-get autoremove -y \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD entrypoint.sh /
RUN chmod 755 /entrypoint.sh

VOLUME /mail

ENTRYPOINT ["/entrypoint.sh"]
