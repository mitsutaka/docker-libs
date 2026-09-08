#!/bin/sh
set -eu

root=$(mktemp -d)
trap 'rm -rf "$root"' EXIT
mkdir -p "$root/rsync"
printf 'FROM alpine:3.24\n' >"$root/rsync/Dockerfile"
printf '3.4.3-r1\n' >"$root/rsync/TAG"

cat >"$root/excluded.sh" <<'EOF'
#!/bin/sh
exit 0
EOF

cat >"$root/docker" <<'EOF'
#!/bin/sh
case "$*" in
    *'apk version '*) printf 'busybox\n' ;;
    *'apk info -v'*) printf '3.4.3-r1\n%s\n' "${FAKE_CANDIDATE:-3.4.3-r2}" ;;
    *) exit 2 ;;
esac
EOF

cat >"$root/tag-checker" <<'EOF'
#!/bin/sh
exit 1
EOF
chmod +x "$root/excluded.sh" "$root/docker" "$root/tag-checker"

output=$(REPO_ROOT="$root" DOCKER="$root/docker" TAG_CHECKER="$root/tag-checker" \
    ./update_tags.sh --write --image rsync)
[ "$output" = 'rsync 3.4.3-r1 -> 3.4.3-r2' ]
[ "$(cat "$root/rsync/TAG")" = '3.4.3-r2' ]

printf '3.4.3-r1\n' >"$root/rsync/TAG"
output=$(FAKE_CANDIDATE=3.4.3-r1 REPO_ROOT="$root" DOCKER="$root/docker" \
    TAG_CHECKER="$root/tag-checker" ./update_tags.sh --write --image rsync)
[ "$output" = 'rsync 3.4.3-r1 -> 3.4.3-r1-1' ]
[ "$(cat "$root/rsync/TAG")" = '3.4.3-r1-1' ]

echo "update_tags.sh tests passed"
