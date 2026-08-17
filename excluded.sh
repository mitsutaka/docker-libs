#!/bin/sh
# Print the globally excluded image names, one per line.
#
# The single reader of the EXCLUDE file, so the Makefile and build_matrix.sh
# cannot disagree about what is skipped. Strips #-comments and blank lines.
#
#   $ ./excluded.sh
#   stone
#   ejabberd
#   ubuntu
#
# Missing EXCLUDE is not an error; it just means nothing is excluded.
set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
exclude_file="${EXCLUDE_FILE:-${script_dir}/EXCLUDE}"

[ -f "$exclude_file" ] || exit 0

sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$exclude_file"
