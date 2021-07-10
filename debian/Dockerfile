FROM debian:bullseye
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV DOCKER_USER mitz
ENV HOST_DOCKER_GROUP_ID 976

RUN apt-get update \
    && apt-get install -y -q --no-install-recommends sudo \
    && adduser --disabled-password --gecos '' "$DOCKER_USER" \
    && adduser "$DOCKER_USER" sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && touch /home/$DOCKER_USER/.sudo_as_admin_successful \
    && apt-get autoremove -y \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER "${DOCKER_USER}"

WORKDIR "/home/${DOCKER_USER}"

# hadolint ignore=DL3004
RUN sudo apt-get update && \
    sudo apt-get install -y man-db bash-completion build-essential curl openssh-client vim apt-transport-https && \
    sudo rm -rf /var/lib/apt/lists/*

# Install docker
# hadolint ignore=DL3004
RUN sudo apt-get update && \
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add - && \
    sudo apt-key fingerprint 0EBFCD88 && \
    sudo add-apt-repository "deb https://download.docker.com/linux/debian buster stable" && \
    sudo apt-get update && \
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io && \
    sudo rm -rf /var/lib/apt/lists/* && \
    sudo systemctl disable docker.service && \
    sudo usermod -a -G docker mitz && \
    sudo groupmod -g ${HOST_DOCKER_GROUP_ID} docker
