# sshd container

- Alpine based
- `make`, `neovim`, `rsync`, `sudo` and `zsh` installed, with a passwordless
  `sudo` user (`mitz`)

## Usage

```console
docker run --rm --name sshd -p 60022:22 \
  -v "$HOME/.ssh/authorized_keys:/tmp/sshd/authorized_keys:ro" \
  ghcr.io/mitsutaka/sshd:alpine
```

Then `ssh -p 60022 mitz@localhost`.

The published tags are the build datestamp (see [`TAG`](TAG)) and `alpine`; there
is no `latest`.

## Options

| Env | Default | Purpose |
| --- | --- | --- |
| `KEY_FILE` | `/tmp/sshd/authorized_keys` | mounted public keys, copied to the user's `authorized_keys`. Optional: sshd starts without it |
| `DEFAULT_USER` | `mitz` | the account the keys are installed for |

Host keys are generated on first start. They live in the container's `/etc/ssh`,
so a fresh container presents a new fingerprint; mount a volume there to keep the
identity stable across `docker rm`:

```console
docker run --rm --name sshd -p 60022:22 \
  -v sshd-hostkeys:/etc/ssh \
  -v "$HOME/.ssh/authorized_keys:/tmp/sshd/authorized_keys:ro" \
  ghcr.io/mitsutaka/sshd:alpine
```
