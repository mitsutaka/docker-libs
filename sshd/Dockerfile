# hadolint ignore=DL3007
FROM archlinux:base-20211010.0.36274
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV container docker

ENV DEFAULT_USER mitz

COPY mirrorlist /etc/pacman.d/mirrorlist

# Install from Arch mirror
RUN pacman -Syu --noconfirm \
    atool \
    base \
    base-devel \
    bash-completion \
    bind-tools \
    fdupes \
    fzf \
    git \
    go \
    htop \
    inetutils \
    jq \
    keychain \
    openssh \
    p7zip \
    parallel \
    python-pip \
    rsync \
    sudo \
    tmux \
    unrar \
    unzip \
    neovim \
    which \
    zip \
    zsh \
    zsh-completions && \
    useradd -m -G wheel -s /bin/zsh "$DEFAULT_USER" && \
    mkdir -p /home/$DEFAULT_USER/.ssh && \
    chmod 0755 /home/$DEFAULT_USER/.ssh && \
    chown $DEFAULT_USER /home/$DEFAULT_USER/.ssh && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers && \
    touch /home/$DEFAULT_USER/.sudo_as_admin_successful && \
    ln -s /usr/bin/nvim /usr/bin/vi && \
    rm -rf /var/cache/pacman

# hadolint ignore=DL3069
RUN su $DEFAULT_USER -c "git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin && \
cd /tmp/yay-bin && \
makepkg --rmdeps --clean --syncdeps --install --noconfirm && \
rm -rf /tmp/yay-bin && \
yay -Syu --noconfirm \
        cloudflared-bin \
        rclone-bin \
" && \
    rm -rf /var/cache/pacman && \
    rm -rf /home/$DEFAULT_USER/.cache

ENV KEY_FILE=/tmp/sshd/authorized_keys
COPY entrypoint.sh /

EXPOSE 22
CMD ["/entrypoint.sh"]
