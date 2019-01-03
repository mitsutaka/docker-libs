FROM golang:1.11 AS build

LABEL maintainer="Mitz Amano <mitsutaka.amano@gmail.com>"

RUN go get -v github.com/soundcloud/ipmi_exporter

FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --no-install-recommends freeipmi

COPY --from=build /go/bin /usr/local/ipmi_exporter/bin
COPY --from=build /go/src/github.com/soundcloud/ipmi_exporter/LICENSE /usr/local/ipmi-exporter/LICENSE

ENV PATH=/usr/local/ipmi_exporter/bin:"$PATH"

EXPOSE 9290

ENTRYPOINT [ "/usr/local/ipmi_exporter/bin/ipmi_exporter" ]
