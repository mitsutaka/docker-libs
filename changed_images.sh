#!/bin/sh
# Print the image directories touched between a base commit and HEAD, one name
# per line.
#
#   $ ./changed_images.sh origin/master
#   sshd
#   utils
#
# Used by .github/workflows/build.yml to build and lint what a pull request
# changed even when its TAG was not bumped; without it a broken Dockerfile merges
# unvalidated and only fails at the next release.
#
# Only directories that are images (they contain a Dockerfile) are reported, and
# EXCLUDE'd names are dropped since CI cannot build them anyway. Changes to
# shared files (Makefile, *.sh, workflows) are deliberately not mapped to images:
# they do not alter image contents.
#
# Exit: 0 on success (including "nothing changed"), 2 on usage/git error.
set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
cd "$script_dir"

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $0 BASE [HEAD]" >&2
    exit 2
fi

base="$1"
head="${2:-HEAD}"

if ! git rev-parse --verify --quiet "$base" >/dev/null; then
    echo "$0: cannot resolve base revision '$base'" >&2
    exit 2
fi

# Three-dot: compare against the merge base, so unrelated commits landing on the
# base branch after the pull request opened do not look like changes.
changed=$(git diff --name-only "${base}...${head}") || {
    echo "$0: git diff ${base}...${head} failed" >&2
    exit 2
}

excluded=$(./excluded.sh)

printf '%s\n' "$changed" \
    | sed -n 's:^\([^/]*\)/.*:\1:p' \
    | sort -u \
    | while read -r name; do
        [ -n "$name" ] || continue
        [ -f "$name/Dockerfile" ] || continue
        printf '%s\n' "$excluded" | grep -qxF "$name" && continue
        printf '%s\n' "$name"
    done
