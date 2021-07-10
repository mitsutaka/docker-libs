# hadolint ignore=DL3007
FROM archlinux:latest
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV container docker

ENV DEFAULT_USER mitz

# hadolint ignore=SC2016
RUN echo 'Server = https://cloudflaremirrors.com/archlinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist && \
    echo 'Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch' >>/etc/pacman.d/mirrorlist

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
        zsh-completions \
    && useradd -m -G wheel -s /bin/zsh "$DEFAULT_USER" \
    && mkdir -m 700 -p /home/$DEFAULT_USER/.ssh \
    && chown $DEFAULT_USER /home/$DEFAULT_USER/.ssh \
    && echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && touch /home/$DEFAULT_USER/.sudo_as_admin_successful \
    && rm -rf /var/cache/pacman

RUN ln -s /usr/bin/nvim /usr/bin/vi

RUN su $DEFAULT_USER -c "git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin; \
cd /tmp/yay-bin; \
makepkg --rmdeps --clean --syncdeps --install --noconfirm"

# Install from AUR
RUN su $DEFAULT_USER -c 'yay -Syu --noconfirm \
        cloudflared-bin \
        rclone-bin \
    ' && rm -rf /var/cache/pacman \
    && rm -rf /home/$DEFAULT_USER/.cache

ENV KEY_FILE=/tmp/sshd/authorized_keys
COPY entrypoint.sh /

EXPOSE 22
CMD ["/entrypoint.sh"]
