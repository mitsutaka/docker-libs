# mitsutaka/softether-vpnclient

Softether VPN Client for Linux
https://www.softether.org

- Standard authenticatin only
- Single Virtual Hub only

## Usage

```
docker run -d --name=softether-vpnclient \
--net=host --privileged \
-e VPN_SERVER=<Softether VPN server> \
-e VPN_SERVER=<Softether VPN port> \
-e ACCOUNT_USER=<Registered username> \
-e ACCOUNT_PASS=<Registered password> \
mitsutaka/softether-vpnclient
```

## Extra Options

- VIRTUAL_HUB=<Virtual Hub name> # Default is DEFAULT
- TAP_IPADDR=<IP address/netmask> # Default is retrieved by DHCP
