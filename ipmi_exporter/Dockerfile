# ipmi_exporter moved from soundcloud/ to prometheus-community/, which is where
# releases now come from.
#
# The old build used "go get" to install the binary, which modern Go no longer
# supports, so this builds from a checkout instead.
#
# The build stage is pinned to the BUILD platform and cross-compiles to the
# target, so building a foreign-architecture image does not run the Go compiler
# under emulation.
FROM --platform=$BUILDPLATFORM golang:1.26 AS build

ARG IPMI_EXPORTER_VERSION=v1.10.1
ARG TARGETOS
ARG TARGETARCH

WORKDIR /src

RUN git clone --depth 1 --branch "${IPMI_EXPORTER_VERSION}" \
    https://github.com/prometheus-community/ipmi_exporter.git .

# CGO is disabled so the result is static and depends on nothing from the
# builder image. The version is injected the way promu would, so that
# "ipmi_exporter --version" reports something useful.
RUN version="${IPMI_EXPORTER_VERSION#v}" \
    && CGO_ENABLED=0 GOOS="${TARGETOS}" GOARCH="${TARGETARCH}" \
    go build -trimpath \
    -ldflags="-s -w -X github.com/prometheus/common/version.Version=${version}" \
    -o /out/ipmi_exporter .

FROM ubuntu:26.04
LABEL maintainer="Mitz Amano <mitz@linux.com>"

# The tools-based collectors shell out to freeipmi.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends freeipmi \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=build /out/ipmi_exporter /usr/local/bin/ipmi_exporter
COPY --from=build /src/LICENSE /usr/local/share/ipmi_exporter/LICENSE

EXPOSE 9290

ENTRYPOINT ["/usr/local/bin/ipmi_exporter"]
