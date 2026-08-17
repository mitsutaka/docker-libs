# Alpine packages no RAR extractor: unrar and atool are in neither main nor
# community, and the 7zip package is built without the RAR codec (its format
# list has no Rar entry). libarchive's bsdtar does read a single-volume RAR5,
# but on a multi-volume set it extracts a truncated file and still exits 0, so
# it is not safe for the backup importer. Build RARLAB's unrar instead, which
# walks a volume set from its first part and fails loudly on a missing one.
#
# Linked statically so the runtime stage needs no libstdc++.
FROM alpine:3.24 AS unrar

ENV UNRAR_VERSION=7.2.4
ENV UNRAR_SHA256=b02e571a33af7711cd803080500370dc1d28eea82b2032480819d27462ad8b31

# The shipped CXXFLAGS carry clang-only -Wno- flags, so they are replaced for
# gcc rather than extended.
# hadolint ignore=DL3018
RUN apk add --no-cache build-base \
    && wget -q -O /tmp/unrarsrc.tar.gz \
    "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz" \
    && echo "${UNRAR_SHA256}  /tmp/unrarsrc.tar.gz" >/tmp/unrarsrc.sha256 \
    && sha256sum -c /tmp/unrarsrc.sha256 \
    && tar xzf /tmp/unrarsrc.tar.gz -C /tmp \
    && make -C /tmp/unrar -j"$(nproc)" \
    CXXFLAGS="-O2 -std=c++11 -Wno-switch" \
    LDFLAGS="-pthread -static" \
    && install -Dm755 /tmp/unrar/unrar /out/unrar

FROM alpine:3.24
LABEL maintainer="Mitz Amano <mitz@linux.com>"

# hadolint ignore=DL3018
RUN apk add --no-cache \
    alertmanager \
    bash \
    bind-tools \
    coreutils \
    curl \
    findutils \
    gawk \
    inotify-tools \
    ipmitool \
    jq \
    openssh \
    parallel \
    rclone \
    restic \
    rsync

# Used by the backup importer to unpack RAR video releases before importing the
# video inside. See the first stage for why this is a build and not an apk.
COPY --from=unrar /out/unrar /usr/local/bin/unrar
