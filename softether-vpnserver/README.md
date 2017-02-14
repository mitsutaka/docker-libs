# mitsutaka/softether-vpnserver

Softether VPN Server for Linux
https://www.softether.org

## Usage

```
docker run -d --name=softether-vpnserver \
--net=host --privileged \
-v /etc/vpn_server.config:/usr/local/vpnserver/config/vpn_server.config \
mitsutaka/softether-vpnserver
```

## Extra Options
