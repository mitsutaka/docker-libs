#!/bin/sh
# Put host keys and the optional authorized_keys file in place, then hand PID 1
# to sshd.
set -eu

user="${DEFAULT_USER:?DEFAULT_USER is set by the Dockerfile and must not be empty}"
ssh_dir="/home/${user}/.ssh"
auth_keys="${ssh_dir}/authorized_keys"

# -A generates only the key types that are missing, so a restarted container
# reuses the keys it already has. Generating each type unconditionally prompted
# "Overwrite (y/n)?" on the second start, which with no tty failed and, under
# "sh -e", killed the container before sshd ever ran.
ssh-keygen -A

# The home directory may be a mounted volume, in which case the .ssh directory
# created at build time is not there.
mkdir -p "$ssh_dir"
chmod 700 "$ssh_dir"
chown "$user" "$ssh_dir"

# Mounting a key file is optional. This used to chown and chmod the file
# unconditionally, so with nothing mounted the entrypoint died on a missing path
# instead of starting sshd.
if [ -f "${KEY_FILE:-}" ]; then
    install -o "$user" -m 600 "$KEY_FILE" "$auth_keys"
else
    echo "$0: ${KEY_FILE:-KEY_FILE} not mounted; starting without authorized_keys" >&2
fi

# exec, so sshd is PID 1 and sees SIGTERM: without it "docker stop" waited the
# full timeout and then killed the container. -e logs to stderr, which is where
# "docker logs" can show it; there is no syslog daemon in this image.
exec /usr/sbin/sshd -D -e
