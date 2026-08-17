# offlineimap 7.x was Python 2 only and its upstream is dead. offlineimap3 is
# the successor project, so this image tracks that instead.
#
# It is installed into a venv rather than onto the system Python because
# Ubuntu's interpreter is externally managed (PEP 668) and rejects pip writes.
# The venv is built in a separate stage so curl and the venv bootstrap do not
# ship in the final image; it hardcodes /opt/offlineimap, so both stages must
# agree on that path and on the interpreter it symlinks to.
FROM ubuntu:26.04 AS build

ENV OFFLINEIMAP_VERSION=8.0.3

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl python3 python3-venv \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN python3 -m venv /opt/offlineimap \
    && curl -fsSL "https://github.com/OfflineIMAP/offlineimap3/archive/refs/tags/v${OFFLINEIMAP_VERSION}.tar.gz" \
    | tar xz -C /tmp \
    && /opt/offlineimap/bin/pip install --no-cache-dir "/tmp/offlineimap3-${OFFLINEIMAP_VERSION}" \
    && rm -rf /tmp/* /var/tmp/*

FROM ubuntu:26.04
LABEL maintainer="Mitz Amano <mitz@linux.com>"

# python3 is the interpreter the copied venv symlinks to; ca-certificates is
# needed for IMAP over TLS.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates python3 \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=build /opt/offlineimap /opt/offlineimap

ENV PATH=/opt/offlineimap/bin:$PATH

VOLUME /mail

ENTRYPOINT ["/opt/offlineimap/bin/offlineimap"]
