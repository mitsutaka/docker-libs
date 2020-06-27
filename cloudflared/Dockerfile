# use a builder image for building cloudflare
FROM golang:1.14 as builder

ARG VERSION=2020.6.5

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -sSLf https://github.com/cloudflare/cloudflared/archive/${VERSION}.tar.gz | \
        tar zxf - -C /tmp/ \
    && mkdir -p /go/src/github.com/cloudflare/ \
    && mv /tmp/cloudflared-${VERSION} /go/src/github.com/cloudflare/cloudflared

ENV GO111MODULE=on
ENV CGO_ENABLED=0
ENV GOOS=linux

WORKDIR /go/src/github.com/cloudflare/cloudflared/

RUN make cloudflared

# use a distroless base image with glibc
FROM gcr.io/distroless/base-debian10:nonroot

# copy our compiled binary
COPY --from=builder --chown=nonroot /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/
COPY --from=builder --chown=nonroot /go/src/github.com/cloudflare/cloudflared/LICENSE /usr/local/bin/

# run as non-privileged user
USER nonroot

# command / entrypoint of container
ENTRYPOINT ["cloudflared", "--no-autoupdate"]
CMD ["version"]
