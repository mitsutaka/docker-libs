FROM centos:8
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV DOCKER_USER mitz
#ENV HOST_DOCKER_GROUP_ID 976

RUN dnf upgrade -y \
    && dnf install -y sudo \
    && useradd -m -G wheel "$DOCKER_USER" \
    && echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && touch /home/$DOCKER_USER/.sudo_as_admin_successful \
    && dnf clean all

USER "${DOCKER_USER}"

WORKDIR "/home/${DOCKER_USER}"

RUN sudo dnf install -y man-db bash-completion openssh vim && \
    sudo dnf clean all

# Install docker
#RUN sudo apt-get update && \
#    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common lsb-release && \
#    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
#    sudo apt-key fingerprint 0EBFCD88 && \
#    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" && \
#    sudo apt-get update && \
#    sudo apt-get install -y docker-ce docker-ce-cli containerd.io && \
#    sudo rm -rf /var/lib/apt/lists/* && \
#    sudo systemctl disable docker.service && \
#    sudo usermod -a -G docker mitz && \
#    sudo groupmod -g ${HOST_DOCKER_GROUP_ID} docker
#
