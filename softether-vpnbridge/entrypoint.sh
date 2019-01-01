#!/bin/sh

mkdir -p /usr/local/vpnbridge/config

ln -s /usr/local/vpnbridge/config/vpn_server.config \
      /usr/local/vpnbridge/vpn_server.config

if [ ! -d "/var/log/vpnbridge/security_log" ]; then
  mkdir -p /var/log/vpnbridge/security_log
fi

if [ ! -d "/var/log/vpnbridge/packet_log" ]; then
  mkdir -p /var/log/vpnbridge/packet_log
fi

if [ ! -d "/var/log/vpnbridge/server_log" ]; then
  mkdir -p /var/log/vpnbridge/server_log
fi

/usr/local/vpnbridge/vpnbridge start

tail -F /usr/local/vpnbridge/*_log/*.log &

set +e
while pgrep vpnbridge > /dev/null; do sleep 1; done
set -e
