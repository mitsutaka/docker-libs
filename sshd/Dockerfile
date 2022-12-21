FROM alpine:3
LABEL maintainer="Mitz Amano <mitz@linux.com>"
ENV DEFAULT_USER mitz

# hadolint ignore=DL3018
RUN apk add --no-cache \
    make \
    neovim \
    openssh-server \
    rsync \
    sudo \
    zsh

RUN adduser -G wheel -s /bin/zsh -D "$DEFAULT_USER" && \
    passwd -u "$DEFAULT_USER" && \
    mkdir -p 700 /home/$DEFAULT_USER/.ssh && \
    chown $DEFAULT_USER /home/$DEFAULT_USER/.ssh && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers && \
    touch /home/$DEFAULT_USER/.sudo_as_admin_successful && \
    :

ENV KEY_FILE=/tmp/sshd/authorized_keys
COPY entrypoint.sh /

EXPOSE 22
CMD ["/entrypoint.sh"]
