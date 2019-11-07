# mitsutaka/openvpn-client

OpenVPN Client
https://openvpn.net/

## Usage

```console
docker run -d --name openvpn-client \
 --privileged \
 --net=host \
 -v /path/to/config:/config \
 mitsutaka/openvpn-client
```

## Extra Options
