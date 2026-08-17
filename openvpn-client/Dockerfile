FROM ubuntu:26.04
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV OPENVPN_VERSION=2.7.0-1ubuntu1.2

RUN apt-get update \
    && apt-get install -y --no-install-recommends openvpn=${OPENVPN_VERSION} \
    && apt-get autoremove -y \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["openvpn", "--config", "/config/config.ovpn"]
