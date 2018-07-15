FROM ubuntu:18.04
MAINTAINER Mitz Amano "mitsutaka.amano@gmail.com"

RUN apt-get update \
    && apt-get install -y --no-install-recommends znc \
    && apt-get autoremove -y \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD entrypoint.sh /entrypoint.sh
ADD znc.conf.default /znc.conf.default
RUN groupadd -g 10000 znc && useradd -u 10000 -g znc znc
RUN chmod 644 /znc.conf.default && chown 10000:10000 /znc.conf.default
RUN mkdir -p /znc-data && chown 10000:10000 /znc-data

USER 10000:10000
VOLUME /znc-data

EXPOSE 6666 6667
ENTRYPOINT ["/entrypoint.sh"]
