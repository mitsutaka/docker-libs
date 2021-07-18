FROM golang:1.16.6 as builder

ARG VERSION=2021.7.0

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -sSLf https://github.com/cloudflare/cloudflared/archive/${VERSION}.tar.gz | \
        tar zxf - -C /tmp/ \
    && mkdir -p /go/src/github.com/cloudflare/ \
    && mv /tmp/cloudflared-${VERSION} /go/src/github.com/cloudflare/cloudflared

ENV CGO_ENABLED=0

WORKDIR /go/src/github.com/cloudflare/cloudflared/

RUN make cloudflared

FROM alpine:3

COPY --from=builder --chown=nobody /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/
COPY --from=builder --chown=nobody /go/src/github.com/cloudflare/cloudflared/LICENSE /usr/local/bin/

USER nobody

ENTRYPOINT ["cloudflared", "--no-autoupdate"]
CMD ["version"]
