# mitsutaka/softether-vpnbridge

Softether VPN Bridge for Linux
https://www.softether.org

## Usage

```
docker run -d --name=softether-vpnbridge \
--net=host --privileged \
-v /etc/vpn_server.config:/usr/local/vpnbridge/config/vpn_server.config \
mitsutaka/softether-vpnbridge
```

## Extra Options
