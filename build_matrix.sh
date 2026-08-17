#!/bin/sh
# Print a compact JSON array of the images whose TAG is not yet published.
#
#   $ ./build_matrix.sh
#   ["rsync","rsyncd","utils"]
#
# Consumed by .github/workflows/build.yml to fan out one build job per image.
# Only directories containing a TAG file are considered publishable; the plain
# base images (debian, centos, fedora) deliberately have no TAG and are built
# locally via the Makefile only. Images listed in EXCLUDE are skipped outright.
#
# Env is passed through to tag_exists.sh (REGISTRY, OWNER, GHCR_USER, GHCR_TOKEN).
#
# Exit: 0 on success, 2 if any image's status could not be determined.
set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

excluded=$("${script_dir}/excluded.sh")

is_excluded() {
    # Exact whole-line match, so "rsync" never matches "rsyncd".
    printf '%s\n' "$excluded" | grep -qxF "$1"
}

images=""

for tagfile in */TAG; do
    [ -f "$tagfile" ] || continue
    name=$(dirname "$tagfile")

    if is_excluded "$name"; then
        echo "skip  ${name}: listed in EXCLUDE" >&2
        continue
    fi

    set +e
    "${script_dir}/tag_exists.sh" "$name"
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
