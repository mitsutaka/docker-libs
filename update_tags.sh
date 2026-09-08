#!/bin/sh
# Refresh image tags when packages in the currently published image can upgrade.
set -eu

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
repo_root=${REPO_ROOT:-$script_dir}
cd "$repo_root"

DOCKER=${DOCKER:-docker}
TAG_CHECKER=${TAG_CHECKER:-$script_dir/tag_exists.sh}
REGISTRY=${REGISTRY:-ghcr.io}
OWNER=${OWNER:-mitsutaka}
APK_REPOSITORY_SCHEME=${APK_REPOSITORY_SCHEME:-https}
write=false
only_image=

case "$APK_REPOSITORY_SCHEME" in
    http | https) ;;
    *)
        echo "$0: APK_REPOSITORY_SCHEME must be http or https" >&2
        exit 2
        ;;
esac

usage() {
    echo "Usage: $0 [--write] [--image NAME]" >&2
    exit 2
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --write)
            write=true
            ;;
        --image)
            [ "$#" -ge 2 ] || usage
            only_image=${2%/}
            shift
            ;;
        *)
            usage
            ;;
    esac
    shift
done

excluded=$("$repo_root/excluded.sh")

in_list() {
    printf '%s\n' "$2" | grep -qxF "$1"
}

primary_package() {
    case "$1" in
        mbsync) echo isync ;;
        openssh) echo openssh ;;
        openvpn-client) echo openvpn ;;
        rsync | rsyncd) echo rsync ;;
        znc) echo znc ;;
        *) echo '' ;;
    esac
}

next_revision_tag() {
    current=$1
    base=$2
    case "$current" in
        "$base")
            echo "${base}-1"
            ;;
        "$base"-*)
            revision=${current#"$base"-}
            case "$revision" in
                '' | *[!0-9]*)
                    echo "$0: cannot increment tag '$current' from base '$base'" >&2
                    exit 2
                    ;;
            esac
            echo "${base}-$((revision + 1))"
            ;;
        *)
            echo "$0: tag '$current' does not match base '$base'" >&2
            exit 2
            ;;
    esac
}

next_unused_tag() {
    name=$1
    candidate=$2
    base=$3
    style=$4

    while :; do
        set +e
        "$TAG_CHECKER" "$name" "$candidate"
        rc=$?
        set -e
        case "$rc" in
            0)
                case "$style" in
                    integer) candidate=$((candidate + 1)) ;;
                    revision) candidate=$(next_revision_tag "$candidate" "$base") ;;
                    *) exit 2 ;;
                esac
                ;;
            1)
                echo "$candidate"
                return
                ;;
            *)
                echo "$0: could not check whether ${name}:${candidate} exists" >&2
                exit 2
                ;;
        esac
    done
}

check_alpine() {
    ref=$1
    primary=$2
    # APK indexes and packages are signed. The http override is useful behind
    # TLS-inspecting proxies whose CA is intentionally absent from the image.
    # shellcheck disable=SC2016
    outdated=$("$DOCKER" run --rm --pull=always --user 0 \
        -e "APK_REPOSITORY_SCHEME=$APK_REPOSITORY_SCHEME" \
        --entrypoint /bin/sh "$ref" -c '
            set -e
            if [ "$APK_REPOSITORY_SCHEME" = http ]; then
                sed -i "s|https://|http://|" /etc/apk/repositories
            fi
            apk update >/dev/null
            apk version -q -l "<"
        ')

    installed=
    candidate=
    if [ -n "$primary" ]; then
        # Variables in this single-quoted program expand inside the container.
        # shellcheck disable=SC2016
        versions=$("$DOCKER" run --rm --user 0 \
            -e "APK_REPOSITORY_SCHEME=$APK_REPOSITORY_SCHEME" \
            --entrypoint /bin/sh "$ref" -c '
            set -e
            if [ "$APK_REPOSITORY_SCHEME" = http ]; then
                sed -i "s|https://|http://|" /etc/apk/repositories
            fi
            apk update >/dev/null
            installed=$(apk info -v "$1" | sed -n "1p")
            candidate=$(apk search -x "$1" | sed -n "1p")
            printf "%s\n%s\n" "${installed#"$1"-}" "${candidate#"$1"-}"
        ' sh "$primary")
        installed=$(printf '%s\n' "$versions" | sed -n '1p')
        candidate=$(printf '%s\n' "$versions" | sed -n '2p')
        if [ -z "$installed" ] || [ -z "$candidate" ]; then
            echo "$0: could not resolve $primary versions in $ref" >&2
            exit 2
        fi
    fi
}

check_ubuntu() {
    ref=$1
    outdated=$("$DOCKER" run --rm --pull=always --user 0 --entrypoint /bin/sh "$ref" -c '
        set -e
        apt-get update >/dev/null
        apt-get -s upgrade 2>/dev/null | sed -n "s/^Inst \([^ ]*\).*/\1/p"
    ')
    installed=
    candidate=
}

updated=false
for dockerfile in */Dockerfile; do
    [ -f "$dockerfile" ] || continue
    name=$(dirname "$dockerfile")
    [ -z "$only_image" ] || [ "$name" = "$only_image" ] || continue
    [ -f "$name/TAG" ] || continue
    in_list "$name" "$excluded" && continue

    old_tag=$(cat "$name/TAG")
    ref="${REGISTRY}/${OWNER}/${name}:${old_tag}"
    primary=$(primary_package "$name")

    case "$name" in
        offlineimap) check_ubuntu "$ref" ;;
        *) check_alpine "$ref" "$primary" ;;
    esac

    if [ -z "$outdated" ]; then
        echo "ok    $name: installed packages are current" >&2
        continue
    fi

    echo "bump  $name: upgradable packages:" >&2
    printf '%s\n' "$outdated" | sed 's/^/      /' >&2

    case "$name" in
        utils)
            case "$old_tag" in *[!0-9]* | '') exit 2 ;; esac
            new_tag=$(next_unused_tag "$name" "$((old_tag + 1))" '' integer)
            ;;
        sshd)
            base=$(date -u +%Y%m%d)
            new_tag=$(next_unused_tag "$name" "$base" "$base" revision)
            ;;
        ipmi_exporter)
            base=$(sed -n 's/^ARG IPMI_EXPORTER_VERSION=//p' "$dockerfile")
            new_tag=$(next_revision_tag "$old_tag" "$base")
            new_tag=$(next_unused_tag "$name" "$new_tag" "$base" revision)
            ;;
        offlineimap)
            base=$(sed -n 's/^ENV OFFLINEIMAP_VERSION=//p' "$dockerfile")
            new_tag=$(next_revision_tag "$old_tag" "$base")
            new_tag=$(next_unused_tag "$name" "$new_tag" "$base" revision)
            ;;
        *)
            if [ "$candidate" != "$installed" ]; then
                base=$candidate
                new_tag=$candidate
            else
                base=$installed
                new_tag=$(next_revision_tag "$old_tag" "$base")
            fi
            new_tag=$(next_unused_tag "$name" "$new_tag" "$base" revision)
            ;;
    esac

    echo "$name $old_tag -> $new_tag"
    if [ "$write" = true ]; then
        printf '%s\n' "$new_tag" >"$name/TAG"
    fi
    updated=true
done

if [ -n "$only_image" ] && [ ! -f "$only_image/TAG" ]; then
    echo "$0: '$only_image' is not a published image" >&2
    exit 2
fi

[ "$updated" = true ] || echo "All published images are current." >&2
