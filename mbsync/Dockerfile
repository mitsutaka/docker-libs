FROM ubuntu:20.04
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV ISYNC_VERSION 1.3.0-2

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends isync=${ISYNC_VERSION} ca-certificates \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /
RUN chmod 755 /entrypoint.sh

VOLUME /mail

ENTRYPOINT ["/entrypoint.sh"]
