FROM ubuntu:18.04 AS build

LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV STONE_VERSION 2.3.e-2.1

RUN apt-get update \
    && apt-get install -y --no-install-recommends stone=${STONE_VERSION} \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["stone"]
