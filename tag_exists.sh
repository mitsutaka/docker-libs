#!/bin/sh -e

if [ $# -ne 1 ]; then
    echo "Usage: tag_exists NAME"
    exit 1
fi

NAME="$1"
TAG=$(cat "$NAME"/TAG)
TOKEN=$(curl -s \
    -H 'Accept-Encoding: application/json' \
    -u "$DOCKER_USER:$DOCKER_PASS" \
    "https://auth.docker.io/token?scope=repository:mitsutaka/$NAME:pull&service=registry.docker.io" | jq -r '.token')
set +e
TAGS=$(curl -s \
    -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    -H "Authorization: Bearer $TOKEN" \
    "https://registry-1.docker.io/v2/mitsutaka/$NAME/tags/list" | jq -r '.tags[]')
set -e

for t in $TAGS; do
    if [ "$t" = "$TAG" ]; then
        echo "ok"
        exit 0
    fi
done

echo "ng"
