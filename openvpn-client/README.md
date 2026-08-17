# openvpn-client

OpenVPN Client
https://openvpn.net/

## Usage

The entrypoint runs `openvpn --config /config/config.ovpn`, so mount a directory
containing `config.ovpn`:

```console
docker run -d --name openvpn-client \
 --cap-add NET_ADMIN --device /dev/net/tun \
 -v /path/to/config:/config \
 ghcr.io/mitsutaka/openvpn-client:latest
```

`--cap-add NET_ADMIN --device /dev/net/tun` is what OpenVPN actually needs;
`--privileged` also works but grants far more than that. Add `--net=host` to route
the host's traffic through the tunnel.
