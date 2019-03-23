FROM ubuntu:18.04 AS build

LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV STONE_VERSION 2.3.e-2.1

RUN apt-get update \
    && apt-get install -y stone=${STONE_VERSION}

CMD ["stone"]
