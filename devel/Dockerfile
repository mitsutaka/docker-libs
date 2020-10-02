FROM archlinux:20200908
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV container docker

ENV DEFAULT_USER mitz
ENV HOST_DOCKER_GROUP_ID 976

RUN echo 'Server = https://cloudflaremirrors.com/archlinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist && \
    echo 'Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch' >>/etc/pacman.d/mirrorlist

# Install from Arch mirror
RUN pacman -Syu --noconfirm \
        atool \
        base \
        base-devel \
        bash-completion \
        bind-tools \
        diff-so-fancy \
        docker \
        fdupes \
        fzf \
        git \
        go \
        helm \
        htop \
        hugo \
        inetutils \
        jq \
        keychain \
        kubectl \
        kustomize \
        man-db \
        mosh \
        openssh \
        p7zip \
        parallel \
        python-pip \
        ripgrep \
        rsync \
        shellcheck \
        sudo \
        terraform \
        thefuck \
        tig \
        tldr \
        tmux \
        unrar \
        unzip \
        vim \
        which \
        zip \
        zsh \
        zsh-completions \
    && useradd -m -G wheel,docker -s /usr/bin/zsh "$DEFAULT_USER" \
    && echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && touch /home/$DEFAULT_USER/.sudo_as_admin_successful \
    && rm -rf /var/cache/pacman

RUN cd /lib/systemd/system/sysinit.target.wants/; ls | grep -v systemd-tmpfiles-setup | xargs rm -vf $1 \
    rm -vf /etc/systemd/system/*.wants/*;\
    rm -vf /lib/systemd/system/local-fs.target.wants/*; \
    rm -vf /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -vf /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -vf /lib/systemd/system/systemd-update-utmp*;
#    rm -vf /lib/systemd/system/basic.target.wants/*;\
#    rm -vf /lib/systemd/system/anaconda.target.wants/*; \
#    rm -vf /lib/systemd/system/plymouth*; \
#    rm -f /lib/systemd/system/multi-user.target.wants/*;\

RUN systemctl enable sshd.service \
    && ln -s /usr/bin/vim /usr/bin/vi

RUN su mitz -c "git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin; \
cd /tmp/yay-bin; \
makepkg --rmdeps --clean --syncdeps --install --noconfirm"

# Install from AUR
RUN su mitz -c 'yay -Syu --noconfirm \
        circleci-cli-bin \
        cloudflared-bin \
        docker-compose-bin \
        fcct \
#        genact-bin \
        hadolint-bin \
        kind-bin \
        kompose-bin \
        kubeadm-bin \
        kubebuilder \
        kubeval \
        rke-bin \
        sshcode \
        stern-bin \
        vault-bin \
    ' && rm -rf /var/cache/pacman

RUN systemctl set-default multi-user.target
ENV init /lib/systemd/systemd
VOLUME [ "/sys/fs/cgroup" ]
ENTRYPOINT ["/lib/systemd/systemd"]
