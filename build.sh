#!/bin/sh -ex

name=$1

tag=latest
if [ -f "${name}/TAG" ]; then
    tag=$(cat ${name}/TAG)
fi

if [ -f ${name}/BUILDX_PLATFORMS ]; then
    BUILDX_PLATFORMS=$(cat ${name}/BUILDX_PLATFORMS)
fi

docker buildx build --platform ${BUILDX_PLATFORMS} -t mitsutaka/${name}:${tag} ${name}
