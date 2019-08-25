FROM ubuntu:18.04
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV OFFLINEIMAP_VERSION 7.3.0

RUN apt-get update \
    && apt-get install -y sudo curl git python-pip make
RUN mkdir -p /src \
    && cd /src \
    && curl -L "https://github.com/OfflineIMAP/offlineimap/archive/v${OFFLINEIMAP_VERSION}.tar.gz" \
    | tar xvz \
    && cd offlineimap-"${OFFLINEIMAP_VERSION}" \
    && pip install rfc6555 six \
    && make \
    && python setup.py install \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /src* /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME /mail

ENTRYPOINT ["offlineimap"]
