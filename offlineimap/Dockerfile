FROM ubuntu:18.04
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV OFFLINEIMAP_VERSION 7.3.3

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends sudo curl git python-pip make \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /src

# hadolint ignore=DL3003
RUN curl -L "https://github.com/OfflineIMAP/offlineimap/archive/v${OFFLINEIMAP_VERSION}.tar.gz" \
    | tar xvz \
    && cd offlineimap-"${OFFLINEIMAP_VERSION}" \
    && pip install rfc6555==0.0.0 six==1.15.0 \
    && pip list \
    && make \
    && python setup.py install \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /src* /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME /mail

ENTRYPOINT ["offlineimap"]
