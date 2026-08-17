#!/bin/sh
# Build one image directory.
#
#   ./build.sh rsync              build for the local platform and load it into
#                                 the local docker image store (the default)
#   PUSH=true ./build.sh rsync    build every platform and push every tag
#
# Tag, extra tags and platform list all come from image_meta.sh, so this script
# and .github/workflows/build.yml agree on the metadata convention by
# construction.
#
# Env:
#   PUSH       "true" to push to the registry. implies a multi-platform build.
#   LOAD       "true" (default) to load the result into the local docker store.
#              docker cannot load a multi-platform image, so this builds the
#              host platform only.
#   REGISTRY   default ghcr.io
#   OWNER      default mitsutaka
#   PLATFORMS  default platform list for images without a BUILDX_PLATFORMS file
set -eu

if [ $# -ne 1 ]; then
    echo "Usage: $0 NAME" >&2
    exit 2
fi

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
name="${1%/}"

PUSH="${PUSH:-false}"
LOAD="${LOAD:-true}"

# Untagged base images (debian, ubuntu, centos, fedora) are local-only, so give
# them a tag rather than failing.
meta=$(DEFAULT_TAG=latest "${script_dir}/image_meta.sh" "$name")

meta_get() {
    printf '%s\n' "$meta" | sed -n "s/^$1=//p"
}

tags=$(meta_get tags)
platforms=$(meta_get platforms)

# Turn the comma separated tag list into repeated -t flags.
set --
old_ifs=$IFS
IFS=,
for t in $tags; do
    IFS=$old_ifs
    set -- "$@" -t "$t"
    IFS=,
done
IFS=$old_ifs

if [ "$PUSH" = true ]; then
    set -- "$@" --platform "$platforms" --push
elif [ "$LOAD" = true ]; then
    # No --platform: buildx defaults to the host platform, which is the only
    # thing --load accepts. Some images only support a subset of platforms, so
    # warn when the host is not one of them rather than letting the build fail
    # with a confusing "404 Not Found" or "exec format error" deeper in.
    host=$(docker version --format '{{.Server.Os}}/{{.Server.Arch}}' 2>/dev/null || true)
    if [ -n "$host" ]; then
        case ",${platforms}," in
            *",${host},"*) ;;
            *)
                echo "$0: warning: ${name} declares platforms '${platforms}'," >&2
                echo "$0: warning: which does not include this host (${host})." >&2
                echo "$0: warning: building anyway; expect it to fail. Use" >&2
                echo "$0: warning: 'LOAD=false PUSH=false' to build the declared set." >&2
                ;;
        esac
    fi
    set -- "$@" --load
else
    set -- "$@" --platform "$platforms"
fi

set -x
exec docker buildx build "$@" "$name"
