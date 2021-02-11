FROM golang:1.15.8 AS build

LABEL maintainer="Mitz Amano <mitz@linux.com>"

ENV IPMI_EXPORTER_VERSION v1.3.1

RUN GO111MODULE=on go get -v github.com/soundcloud/ipmi_exporter@${IPMI_EXPORTER_VERSION} \
    && echo "${IPMI_EXPORTER_VERSION}" >/tmp/version

FROM ubuntu:20.04

ENV IPMI_EXPORTER_VERSION v1.3.1

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends freeipmi \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=build /go/bin /usr/local/ipmi_exporter/bin
COPY --from=build /go/pkg/mod/github.com/soundcloud/ipmi_exporter@${IPMI_EXPORTER_VERSION}/LICENSE /usr/local/ipmi-exporter/LICENSE

ENV PATH=/usr/local/ipmi_exporter/bin:"$PATH"

EXPOSE 9290

ENTRYPOINT [ "/usr/local/ipmi_exporter/bin/ipmi_exporter" ]
