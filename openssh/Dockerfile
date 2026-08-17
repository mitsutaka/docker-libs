FROM alpine:3.24
LABEL maintainer="Mitz Amano <mitz@linux.com>"

# Intentionally not pinned to exact apk versions. Alpine's CDN serves only the
# newest -rN of a package for a branch, so "openssh=10.3_p1-r0" stops
# resolving the moment Alpine rebuilds the package. The base image minor is
# pinned instead, and TAG records the version this image was released against.
#
# curl used to be installed alongside it, which nothing in an image whose
# entrypoint is ssh had a use for.
# hadolint ignore=DL3018
RUN apk add --no-cache openssh

ENTRYPOINT ["ssh"]
