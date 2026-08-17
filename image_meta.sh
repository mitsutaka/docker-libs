#!/bin/sh
# Resolve build metadata for one image directory.
#
# This is the single source of truth for the "files as metadata" convention:
#
#   <name>/TAG               required. the version tag to publish.
#   <name>/BRANCH            optional. an additional floating tag (usually "latest").
#   <name>/BUILDX_PLATFORMS  optional. per-image platform list, overrides PLATFORMS.
#
# Output is key=value lines, which is both eval-able by build.sh and directly
# appendable to $GITHUB_OUTPUT in GitHub Actions:
#
#   name=rsync
#   tag=3.2.7-r0
#   branch=latest
#   platforms=linux/amd64,linux/arm64
#   image=ghcr.io/mitsutaka/rsync
#   tags=ghcr.io/mitsutaka/rsync:3.2.7-r0,ghcr.io/mitsutaka/rsync:latest
#
# "tags" intentionally carries every tag for the image so that callers build and
# push once with multiple -t flags, rather than rebuilding per tag.
#
# Env:
#   REGISTRY     default ghcr.io
#   OWNER        default mitsutaka
#   PLATFORMS    default platform list, used when the image has no override
#   DEFAULT_TAG  if set, used when the image has no TAG file. Local builds set
#                this to "latest" so the untagged base images (debian, ubuntu,
#                centos, fedora) remain buildable; CI leaves it unset so that a
#                missing TAG is an error.
#
# Exit: 0 on success, 2 on usage/metadata error.
set -eu

REGISTRY="${REGISTRY:-ghcr.io}"
OWNER="${OWNER:-mitsutaka}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64,linux/ppc64le,linux/arm/v7}"

if [ $# -ne 1 ]; then
    echo "Usage: $0 NAME" >&2
    exit 2
fi

name="$1"
name="${name%/}"

if [ ! -d "$name" ]; then
    echo "$0: no such image directory: $name" >&2
    exit 2
fi

if [ ! -f "$name/Dockerfile" ]; then
    echo "$0: $name/Dockerfile not found" >&2
    exit 2
fi

if [ -f "$name/TAG" ]; then
    # $(cat) strips trailing newlines, so TAG files with or without a trailing
    # newline both work.
    tag=$(cat "$name/TAG")
elif [ -n "${DEFAULT_TAG:-}" ]; then
    tag="$DEFAULT_TAG"
else
    echo "$0: $name/TAG not found (image is not published by CI)" >&2
    exit 2
fi

if [ -z "$tag" ]; then
    echo "$0: no tag resolved for $name" >&2
    exit 2
fi

branch=""
if [ -f "$name/BRANCH" ]; then
    branch=$(cat "$name/BRANCH")
fi

platforms="$PLATFORMS"
if [ -f "$name/BUILDX_PLATFORMS" ]; then
    platforms=$(cat "$name/BUILDX_PLATFORMS")
fi

# OCI reference names must be lowercase.
repo=$(printf '%s/%s' "$OWNER" "$name" | tr '[:upper:]' '[:lower:]')
image="${REGISTRY}/${repo}"

tags="${image}:${tag}"
if [ -n "$branch" ] && [ "$branch" != "$tag" ]; then
    tags="${tags},${image}:${branch}"
fi

echo "name=${name}"
echo "tag=${tag}"
echo "branch=${branch}"
echo "platforms=${platforms}"
echo "image=${image}"
echo "tags=${tags}"
