FROM archlinux:latest
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV container docker

ENV DEFAULT_USER mitz
ENV HOST_DOCKER_GROUP_ID 976

RUN echo 'Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist

RUN pacman -Syu --noconfirm \
        base \
        base-devel \
        which \
        inetutils \
        sudo \
        docker \
        man-db \
        bash-completion \
        vim \
        openssh \
        python-pip \
        go \
        git \
        tmux \
        rsync \
        bind-tools \
        atool \
        unrar \
        zip \
        unzip \
        p7zip \
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

RUN systemctl set-default multi-user.target
ENV init /lib/systemd/systemd
VOLUME [ "/sys/fs/cgroup" ]
ENTRYPOINT ["/lib/systemd/systemd"]
