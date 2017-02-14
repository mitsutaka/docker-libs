#!/bin/sh

mkdir -p /usr/local/vpnserver/config

ln -s /usr/local/vpnserver/config/vpn_server.config \
      /usr/local/vpnserver/vpn_server.config

if [ ! -d "/var/log/vpnserver/security_log" ]; then
  mkdir -p /var/log/vpnserver/security_log
fi

if [ ! -d "/var/log/vpnserver/packet_log" ]; then
  mkdir -p /var/log/vpnserver/packet_log
fi

if [ ! -d "/var/log/vpnserver/server_log" ]; then
  mkdir -p /var/log/vpnserver/server_log
fi

ln -s /var/log/vpnserver/*_log /usr/local/vpnserver/

exec /usr/local/vpnserver/vpnserver execsvc

exit $?
