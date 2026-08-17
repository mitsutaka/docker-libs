#!/bin/sh
# Print the README's published-image table as Markdown.
#
#   $ ./image_table.sh
#   | Image | Tag |
#   | --- | --- |
#   | [rsync](https://github.com/mitsutaka/docker-libs/pkgs/container/rsync) | `3.4.3-r1`, `latest` |
#
# The table is generated rather than hand-maintained so it cannot drift from the
# TAG and BRANCH files. "make readme" splices this into README.md and
# "make readme-check" fails when the checked-in table is stale.
#
# Tags come from image_meta.sh, so this shares the one reader of the metadata
# convention. Images with no TAG (never published) and EXCLUDE'd images are
# omitted, which is what the table has always shown.
#
# Env:
#   OWNER  default mitsutaka, used for the package links
#   REPO   default docker-libs, used for the package links
set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
cd "$script_dir"

OWNER="${OWNER:-mitsutaka}"
REPO="${REPO:-docker-libs}"

excluded=$(./excluded.sh)

# Sorted in the C locale, so the generated table is byte-identical everywhere and
# "make readme-check" cannot fail purely because of a developer's locale.
names=$(for tagfile in */TAG; do
    [ -f "$tagfile" ] || continue
    dirname "$tagfile"
done | LC_ALL=C sort)

echo '| Image | Tag |'
echo '| --- | --- |'

for name in $names; do
    printf '%s\n' "$excluded" | grep -qxF "$name" && continue

    meta=$(./image_meta.sh "$name")
    tag=$(printf '%s\n' "$meta" | sed -n 's/^tag=//p')
    branch=$(printf '%s\n' "$meta" | sed -n 's/^branch=//p')

    tags="\`${tag}\`"
    if [ -n "$branch" ] && [ "$branch" != "$tag" ]; then
        tags="${tags}, \`${branch}\`"
    fi

    printf '| [%s](https://github.com/%s/%s/pkgs/container/%s) | %s |\n' \
        "$name" "$OWNER" "$REPO" "$name" "$tags"
done
