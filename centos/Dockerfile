# CentOS 8 reached EOL in 2021 and its repositories were withdrawn, so that
# base no longer installs anything. CentOS Stream 10 is the continuation, and it
# is published on quay.io because the Docker Hub "centos" image is archived.
FROM quay.io/centos/centos:stream10
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV DOCKER_USER=mitz

# One dnf pass, as root, before dropping to the user: the tools used to be
# installed by a second "sudo dnf install" layer after USER, which needed a
# hadolint exception and bought nothing.
#
# openssh-clients, not openssh: on RHEL-family the latter ships only the shared
# pieces, so it does not provide the ssh binary this image is meant to have.
# hadolint ignore=DL3041
RUN dnf install -y \
    bash-completion \
    man-db \
    openssh-clients \
    sudo \
    vim \
    && useradd -m -G wheel "$DOCKER_USER" \
    && echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && touch /home/$DOCKER_USER/.sudo_as_admin_successful \
    && dnf clean all

USER "${DOCKER_USER}"

WORKDIR "/home/${DOCKER_USER}"
