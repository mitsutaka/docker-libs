# sshd container

- Arch linux based
- Installed daily commands.

## Usage

```console
docker run --rm --name sshd -p 60022:22 -v $HOME/.ssh/authorized_keys:/tmp/sshd/authorized_keys mitsutaka/sshd:latest
```

## Extra Options
