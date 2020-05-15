FROM jenkins/jenkins:2.157
LABEL maintainer="Mitz Amano <mitz@linux.com>"

RUN apt-get update \
    && apt-get install -y --no-install-recommends libvirt0 \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
USER jenkins
