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
#   PLATFORMS    default platform list, used when the image has no override.
#                defaults to the repository's PLATFORMS file.
#   DEFAULT_TAG  if set, used when the image has no TAG file. Local builds set
#                this to "latest" so the untagged base images (debian, ubuntu,
#                centos, fedora) remain buildable; CI leaves it unset for pushes
#                so that a missing TAG is an error.
#
# Exit: 0 on success, 2 on usage/metadata error.
set -eu

# Metadata is read from the repository, not from wherever the caller happens to
# be, so "../docker-libs/image_meta.sh rsync" resolves the same files as
# "./image_meta.sh rsync".
script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
cd "$script_dir"

REGISTRY="${REGISTRY:-ghcr.io}"
OWNER="${OWNER:-mitsutaka}"

# The PLATFORMS file is the one place the default platform list is written down;
# the Makefile and CI both end up here rather than repeating it.
if [ -z "${PLATFORMS:-}" ]; then
    if [ ! -f PLATFORMS ]; then
        echo "$0: PLATFORMS file not found and PLATFORMS is unset" >&2
        exit 2
    fi
    PLATFORMS=$(cat PLATFORMS)
fi

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

# Each value ends up on a key=value line, several of which are appended straight
# to $GITHUB_OUTPUT, so a stray newline or space would silently produce a broken
# or forged output. Reject it here instead.
check_single_token() {
    file="$1"
    value="$2"
    case "$value" in
        '')
            echo "$0: $file is empty" >&2
            exit 2
            ;;
        *[!!-~]*)
            echo "$0: $file must be a single line without whitespace: '$value'" >&2
            exit 2
            ;;
    esac
}

if [ -f "$name/TAG" ]; then
    # $(cat) strips trailing newlines, so TAG files with or without a trailing
    # newline both work.
    tag=$(cat "$name/TAG")
    check_single_token "$name/TAG" "$tag"
elif [ -n "${DEFAULT_TAG:-}" ]; then
    tag="$DEFAULT_TAG"
    check_single_token "DEFAULT_TAG" "$tag"
else
    echo "$0: $name/TAG not found (image is not published by CI)" >&2
    exit 2
fi

branch=""
if [ -f "$name/BRANCH" ]; then
    branch=$(cat "$name/BRANCH")
    check_single_token "$name/BRANCH" "$branch"
fi

platforms="$PLATFORMS"
if [ -f "$name/BUILDX_PLATFORMS" ]; then
    platforms=$(cat "$name/BUILDX_PLATFORMS")
fi
check_single_token "platform list for $name" "$platforms"

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
