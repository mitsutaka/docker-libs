FROM alpine:3.24
LABEL maintainer="Mitz Amano <mitz@linux.com>"

# Intentionally not pinned to an exact apk version. Alpine's CDN serves only the
# newest -rN of a package for a given branch, so "znc=1.10.2-r0" stops resolving
# the moment Alpine rebuilds the package. The base image minor is pinned
# instead, and TAG records the version this image was released against.
# hadolint ignore=DL3018
RUN apk add --no-cache znc

COPY entrypoint.sh /entrypoint.sh
COPY znc.conf.default /znc.conf.default
# Alpine's znc package pre-creates a znc user at uid 100, but this image has
# always run as 10000:10000 and published /znc-data volumes are owned by 10000.
# Drop the packaged account and recreate it at the uid this image expects, so
# existing data directories stay writable. /var/lib/znc is left orphaned on
# purpose; the entrypoint runs znc with --datadir=/znc-data and never uses it.
RUN deluser znc && delgroup znc 2>/dev/null; \
    addgroup -g 10000 znc && adduser -u 10000 -G znc -D -H znc
RUN chmod 644 /znc.conf.default && chown 10000:10000 /znc.conf.default
RUN mkdir -p /znc-data && chown 10000:10000 /znc-data

USER 10000:10000
VOLUME /znc-data

EXPOSE 6666 6667
ENTRYPOINT ["/entrypoint.sh"]
