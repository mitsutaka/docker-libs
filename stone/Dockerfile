FROM ubuntu:18.04 AS build

MAINTAINER Mitz Amano "mitsutaka.amano@gmail.com"

ENV STONE_VERSION 2.3e

RUN apt-get update \
    && apt-get install -y stone

CMD ["stone"]
