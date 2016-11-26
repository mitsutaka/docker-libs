FROM armv7/armhf-debian:8
MAINTAINER "Mitz Amano <mitz@linux.com>"

ENV VER=1.2.7.2987
ENV SUM=1bef33a
ENV URL=https://downloads.plex.tv/plex-media-server/${VER}-${SUM}/PlexMediaServer-${VER}-${SUM}-arm7.spk
ENV BUILD_DIR=/tmp/plexmediaserver
ENV INSTALL_DIR=/opt/plexmediaserver

RUN \
  apt-get update && \
  apt-get install -y curl && \
  mkdir -p ${BUILD_DIR} && \
  mkdir -p ${INSTALL_DIR} && \
  curl ${URL} | tar xv -C ${BUILD_DIR} && \
  tar xvf ${BUILD_DIR}/package.tgz -C ${INSTALL_DIR} && \
  rm -rf ${BUILD_DIR} && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY entrypoint.sh /
RUN chown root.root /entrypoint.sh && chmod 700 /entrypoint.sh

# 32400/tcp Plex DLNA Server
# 5353/udp Bonjour/Avahi network discovery
# 1900/udp Plex DLNA Server
# 32469/tcp Plex DLNA Server
EXPOSE 32400/tcp 5353/udp 1900/udp 32469/tcp

ENTRYPOINT ["/entrypoint.sh"]
