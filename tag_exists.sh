#!/bin/sh
# Report whether an image's TAG has already been published to the registry.
#
# Queries the manifest for the single tag we care about rather than listing every
# tag in the repository, so the answer is unambiguous and cheap.
#
# Exit codes (checked by callers, so keep them stable):
#   0  tag exists   -> nothing to build
#   1  tag absent   -> build it
#   2  error        -> could not determine; caller should fail loudly rather
#                     than risk silently rebuilding and overwriting a tag
#
# Env:
#   REGISTRY    default ghcr.io
#   OWNER       default mitsutaka
#   GHCR_USER   username for the registry token request
#   GHCR_TOKEN  token/password; on GitHub Actions pass secrets.GITHUB_TOKEN
set -eu

REGISTRY="${REGISTRY:-ghcr.io}"
OWNER="${OWNER:-mitsutaka}"

if [ $# -ne 1 ]; then
    echo "Usage: $0 NAME" >&2
    exit 2
fi

name="${1%/}"

if [ ! -f "$name/TAG" ]; then
    echo "$0: $name/TAG not found" >&2
    exit 2
fi
tag=$(cat "$name/TAG")
if [ -z "$tag" ]; then
    echo "$0: $name/TAG is empty" >&2
    exit 2
fi

repo=$(printf '%s/%s' "$OWNER" "$name" | tr '[:upper:]' '[:lower:]')

# Exchange credentials for a pull-scoped bearer token. GHCR implements the
# standard Docker registry v2 token endpoint.
token_url="https://${REGISTRY}/token?scope=repository:${repo}:pull&service=${REGISTRY}"

body=$(mktemp)
# shellcheck disable=SC2064  # expand $body now, not at trap time
trap "rm -f '$body'" EXIT

if [ -n "${GHCR_TOKEN:-}" ]; then
    token_code=$(curl -sS -u "${GHCR_USER:-}:${GHCR_TOKEN}" \
        -o "$body" -w '%{http_code}' "$token_url") || {
        echo "$0: token request failed for ${repo}" >&2
        exit 2
    }
else
    token_code=$(curl -sS -o "$body" -w '%{http_code}' "$token_url") || {
        echo "$0: anonymous token request failed for ${repo}" >&2
        exit 2
    }
fi

case "$token_code" in
    200) ;;
    401 | 403)
        # GHCR refuses to mint even a pull token for a repository it will not
        # show us, and a package that has never been pushed is exactly that. So
        # this is the normal answer for a brand new image on its first build.
        #
        # Bad or under-scoped credentials look identical here. Reporting
        # "absent" is still the safe choice: the worst case is that we rebuild an
        # image whose push then fails loudly, whereas failing here would block
        # every first-time build.
        echo "$0: cannot read ${repo} (token HTTP ${token_code}); treating ${tag} as absent" >&2
        exit 1
        ;;
    *)
        echo "$0: unexpected HTTP ${token_code} from token endpoint for ${repo}" >&2
        exit 2
        ;;
esac

token=$(jq -r '.token // empty' <"$body")
if [ -z "$token" ]; then
    echo "$0: registry returned no token for ${repo}" >&2
    exit 2
fi

# Ask for every manifest media type we might have pushed; multi-arch builds
# produce an index/manifest-list, single-arch a plain manifest.
code=$(curl -sS -o /dev/null -w '%{http_code}' \
    -H "Authorization: Bearer ${token}" \
    -H 'Accept: application/vnd.oci.image.index.v1+json' \
    -H 'Accept: application/vnd.oci.image.manifest.v1+json' \
    -H 'Accept: application/vnd.docker.distribution.manifest.list.v2+json' \
    -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' \
    "https://${REGISTRY}/v2/${repo}/manifests/${tag}") || {
    echo "$0: manifest request failed for ${repo}:${tag}" >&2
    exit 2
}

case "$code" in
    200)
        exit 0
        ;;
    404)
        exit 1
        ;;
    401 | 403)
        # GHCR answers 401/403 for a package that does not exist yet, which is
        # exactly the state of a brand new image on its first build. Treat it as
        # absent but say so, since it is also what genuinely bad credentials
        # would look like.
        echo "$0: ${repo}:${tag} not visible (HTTP ${code}); treating as absent" >&2
        exit 1
        ;;
    *)
        echo "$0: unexpected HTTP ${code} for ${repo}:${tag}" >&2
        exit 2
        ;;
esac
