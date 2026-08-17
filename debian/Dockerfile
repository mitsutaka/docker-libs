FROM debian:trixie
LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV DOCKER_USER=mitz
ENV HOST_DOCKER_GROUP_ID=976

# Debian 13 dropped adduser from the base image, so it is installed explicitly
# rather than assumed.
RUN apt-get update \
    && apt-get install -y -q --no-install-recommends adduser sudo \
    && adduser --disabled-password --gecos '' "$DOCKER_USER" \
    && adduser "$DOCKER_USER" sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && touch /home/$DOCKER_USER/.sudo_as_admin_successful \
    && apt-get autoremove -y \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER "${DOCKER_USER}"

WORKDIR "/home/${DOCKER_USER}"

# apt-transport-https is not installed: https support has been part of apt itself
# since 1.5, so on trixie the package is only a transitional dummy.
# hadolint ignore=DL3004
RUN sudo apt-get update && \
    sudo apt-get install -y man-db bash-completion build-essential curl openssh-client vim && \
    sudo rm -rf /var/lib/apt/lists/*

# Install docker.
#
# apt-key was removed in Debian 12, and add-apt-repository is no longer needed,
# so the key goes to /etc/apt/keyrings and the repo is declared with signed-by.
# The suite and architecture are read from the image instead of hardcoded, so
# this keeps working across base bumps and on every published platform.
#
# There is no systemd here, so the old "systemctl disable docker.service" is
# dropped: nothing in a container starts the unit in the first place.
#
# The key is fetched to a file rather than piped into tee: in a pipeline a
# failed curl is masked by tee's exit status, which silently installs an empty
# keyring and fails later as a confusing "no installation candidate".
# hadolint ignore=DL3004,DL3008
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends ca-certificates curl gnupg && \
    sudo install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL -o /tmp/docker.asc https://download.docker.com/linux/debian/gpg && \
    sudo install -m 0644 /tmp/docker.asc /etc/apt/keyrings/docker.asc && \
    rm -f /tmp/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null && \
    sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io && \
    sudo rm -rf /var/lib/apt/lists/* && \
    sudo usermod -a -G docker "$DOCKER_USER" && \
    sudo groupmod -g "${HOST_DOCKER_GROUP_ID}" docker
