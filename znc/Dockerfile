FROM ubuntu:26.04
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV ZNC_VERSION=1.10.1-1build3

RUN apt-get update \
    && apt-get install -y -q --no-install-recommends znc=${ZNC_VERSION} \
    && apt-get autoremove -y \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY entrypoint.sh /entrypoint.sh
COPY znc.conf.default /znc.conf.default
RUN groupadd -g 10000 znc && useradd -u 10000 -g znc znc
RUN chmod 644 /znc.conf.default && chown 10000:10000 /znc.conf.default
RUN mkdir -p /znc-data && chown 10000:10000 /znc-data

USER 10000:10000
VOLUME /znc-data

EXPOSE 6666 6667
ENTRYPOINT ["/entrypoint.sh"]
