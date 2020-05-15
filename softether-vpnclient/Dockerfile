FROM ubuntu:18.04
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV VERSION v4.29-9680-rtm-2019.02.28
WORKDIR /usr/local/vpnclient

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y --no-install-recommends -q install iptables gcc make wget dhcpcd5 iproute2 \
    && rm -rf /tmp/* /var/tmp/* \
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/* \
    && wget http://www.softether-download.com/files/softether/${VERSION}-tree/Linux/SoftEther_VPN_Client/64bit_-_Intel_x64_or_AMD64/softether-vpnclient-${VERSION}-linux-x64-64bit.tar.gz -O /tmp/softether-vpnclient.tar.gz \
    && tar -xzvf /tmp/softether-vpnclient.tar.gz -C /usr/local/ \
    && rm /tmp/softether-vpnclient.tar.gz \
    && make i_read_and_agree_the_license_agreement \
    && apt-get purge -y -q --auto-remove gcc make wget

COPY entrypoint.sh /
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
