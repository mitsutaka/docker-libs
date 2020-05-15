FROM ubuntu:16.04
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV MEDIAPROXY_VERSION 2.6.6xenial

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "deb http://ag-projects.com/ubuntu xenial main" >>/etc/apt/sources.list && \
    curl -o /etc/apt/trusted.gpg.d/agp-debian-key.gpg http://download.ag-projects.com/agp-debian-key.gpg

RUN apt-get update \
    && apt-get install -y --no-install-recommends mediaproxy-relay=${MEDIAPROXY_VERSION} \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get purge -y ca-certificates libidn11 openssl wget

COPY entrypoint.sh /
RUN chown root.root /entrypoint.sh && chmod 700 /entrypoint.sh

EXPOSE 20000-60000/udp

ENTRYPOINT ["/entrypoint.sh"]
