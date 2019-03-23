FROM ubuntu:16.04
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV MEDIAPROXY_VERSION 2.6.6xenial
USER root

RUN apt-get update && \
    apt-get install -y curl

RUN echo "deb http://ag-projects.com/ubuntu xenial main" >>/etc/apt/sources.list && \
    curl -o /etc/apt/trusted.gpg.d/agp-debian-key.gpg http://download.ag-projects.com/agp-debian-key.gpg

RUN apt-get update && \
    apt-get install -y mediaproxy-dispatcher=${MEDIAPROXY_VERSION} python-mysqldb

RUN mkdir -p /etc/mediaproxy/script
COPY script/statistic.sql /etc/mediaproxy/script

COPY entrypoint.sh /sbin
RUN chown root.root /sbin/entrypoint.sh && chmod 700 /sbin/entrypoint.sh

VOLUME ["/run/mediaproxy"]
VOLUME ["/etc/mediaproxy"]
EXPOSE 25060/tcp

ENTRYPOINT ["entrypoint.sh"]
