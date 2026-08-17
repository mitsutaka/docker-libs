FROM alpine:3.24
LABEL maintainer="Mitz Amano <mitz@linux.com>"

# Intentionally not pinned to an exact apk version. Alpine's CDN serves only the
# newest -rN of a package for a given branch, so "rsync=3.4.3-r1" stops
# resolving the moment Alpine rebuilds the package. The base image minor is
# pinned instead, and TAG records the version this image was released against.
# hadolint ignore=DL3018
RUN apk add --no-cache rsync

ENTRYPOINT ["rsync"]
