#!/bin/sh

VIRTUAL_HUB=${VIRTUAL_HUB:-"DEFAULT"}
VPN_SERVER=${VPN_SERVER:-"localhost"}
VPN_PORT=${VPN_PORT:-"5555"}
TAP_IPADDR=${TAP_IPADDR:-""}
ACCOUNT_NAME=${ACCOUNT_NAME:-"DEFAULT"}
ACCOUNT_USER=${ACCOUNT_USER:-"username"}
ACCOUNT_PASS=${ACCOUNT_PASS:-"password"}

ACCOUNT_PASS_TYPE=standard
VPNCMD="/usr/local/vpnclient/vpncmd localhost /CLIENT /CMD"

/usr/local/vpnclient/vpnclient start

sleep 2

$VPNCMD NicList $VIRTUAL_HUB
$VPNCMD NicCreate $VIRTUAL_HUB
$VPNCMD NicEnable $VIRTUAL_HUB
$VPNCMD AccountCreate $ACCOUNT_NAME /SERVER:$VPN_SERVER:$VPN_PORT /HUB:$VIRTUAL_HUB /USERNAME:$ACCOUNT_USER /NICNAME:$VIRTUAL_HUB
$VPNCMD AccountPasswordSet $ACCOUNT_NAME /PASSWORD:$ACCOUNT_PASS /TYPE:$ACCOUNT_PASS_TYPE
$VPNCMD AccountConnect $ACCOUNT_NAME

sleep 3

TAP_DEVICE=$(cd /sys/class/net; echo vpn_*)
case ${TAP_IPADDR} in
	dhcp)
		dhcpcd $TAP_DEVICE
		;;
	none)
		;;
	*)
		ip addr add $TAP_IPADDR dev $TAP_DEVICE
esac

tail -F /usr/local/vpnclient/client_log/*.log &

set +e
while pgrep vpnclient > /dev/null; do sleep 1; done
set -e
