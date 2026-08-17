FROM alpine:3.24
LABEL maintainer="Mitz Amano <mitz@linux.com>"

# Intentionally not pinned to exact apk versions. Alpine's CDN serves only the
# newest -rN of a package for a given branch, so "openssh=10.3_p1-r0" stops
# resolving the moment Alpine rebuilds the package. The base image minor is
# pinned instead, and TAG records the version this image was released against.
# hadolint ignore=DL3018
RUN apk add --no-cache openssh curl

ENTRYPOINT ["ssh"]
