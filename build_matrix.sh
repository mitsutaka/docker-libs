#!/bin/sh
# Print a compact JSON array of the images that need building.
#
#   $ ./build_matrix.sh
#   ["rsync","rsyncd","utils"]
#
# Consumed by .github/workflows/build.yml to fan out one build job per image.
#
# An image needs building when the tag in its TAG file is not yet published, so
# bumping TAG is what triggers a release. Directories with no TAG file (the plain
# base images: debian, centos, fedora) are never published and so are never
# selected here; they are built locally via the Makefile. Images listed in
# EXCLUDE are skipped outright.
#
# Env:
#   FORCE_IMAGES  whitespace separated image names to include regardless of
#                 whether their tag is published. Pull request runs pass the
#                 images they touched, so that a change is built and linted even
#                 when TAG was not bumped. EXCLUDE still wins.
#   REGISTRY, OWNER, GHCR_USER, GHCR_TOKEN are passed through to tag_exists.sh.
#
# Exit: 0 on success, 2 if any image's status could not be determined.
set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
cd "$script_dir"

excluded=$(./excluded.sh)

# Exact whole-line match, so "rsync" never matches "rsyncd".
in_list() {
    printf '%s\n' "$2" | grep -qxF "$1"
}

# Normalise FORCE_IMAGES to one name per line, tolerating spaces, commas and
# trailing slashes, so callers can pass a shell list or a git-derived list.
forced=$(printf '%s' "${FORCE_IMAGES:-}" | tr -s ',[:space:]' '\n' | sed -e 's:/*$::' -e '/^$/d')

# A forced name that is not an image directory is a caller bug, not something to
# silently drop into the matrix. Checked up front, before any registry lookups.
for name in $forced; do
    if [ ! -f "$name/Dockerfile" ]; then
        echo "$0: forced image '${name}' has no Dockerfile" >&2
        exit 2
    fi
done

images=""

for dockerfile in */Dockerfile; do
    [ -f "$dockerfile" ] || continue
    name=$(dirname "$dockerfile")

    if in_list "$name" "$excluded"; then
        echo "skip  ${name}: listed in EXCLUDE" >&2
        continue
    fi

    if in_list "$name" "$forced"; then
        echo "build ${name}: changed in this run" >&2
        images="${images}${images:+ }${name}"
        continue
    fi

    if [ ! -f "$name/TAG" ]; then
        echo "skip  ${name}: no TAG file (not published by CI)" >&2
        continue
    fi

    set +e
    ./tag_exists.sh "$name"
    rc=$?
    set -e

    case "$rc" in
        0)
            echo "skip  ${name}: already published" >&2
            ;;
        1)
            echo "build ${name}: tag not published" >&2
            images="${images}${images:+ }${name}"
            ;;
        *)
            echo "$0: could not determine status of ${name}" >&2
            exit 2
            ;;
    esac
done

# Build the JSON array with jq so names are escaped correctly, and keep it on a
# single line for $GITHUB_OUTPUT.
if [ -z "$images" ]; then
    echo '[]'
else
    printf '%s\n' "$images" | jq -Rc 'split(" ")'
fi
