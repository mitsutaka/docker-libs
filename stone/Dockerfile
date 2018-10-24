FROM ubuntu:16.04 AS build

MAINTAINER Mitz Amano "mitsutaka.amano@gmail.com"

ENV STONE_VERSION 2.3e

RUN apt-get update \
    && apt-get install -y curl make gcc libssl-dev

RUN mkdir -p /src \
  && cd /src \
  && curl -L "http://www.gcd.org/sengoku/stone/stone-${STONE_VERSION}.tar.gz" | tar xvz \
  && cd stone-* \
  && echo '\nlinux-ssl-custom:\n\t$(MAKE) TARGET=linux ssl_stone LIBS="-ldl" FLAGS="-D_GNU_SOURCE $(FLAGS)"\n' >>Makefile \
  && make linux-ssl-custom

FROM ubuntu:16.04
RUN apt-get update \
  && apt-get install -y --no-install-recommends openssl

COPY --from=build /src/stone-*/GPL.txt /
COPY --from=build /src/stone-*/stone /

CMD ["/stone"]
