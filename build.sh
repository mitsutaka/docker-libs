#!/bin/sh -ex

name=$1

tag=latest
if [ -f "${name}/TAG" ]; then
    tag=$(cat ${name}/TAG)
fi

if [ "${BUILDX_LOAD}" = "true" ]; then
    docker build --load -t mitsutaka/${name}:${tag} ${name}
    exit $?
fi

if [ -f ${name}/BUILDX_PLATFORMS ]; then
    BUILDX_PLATFORMS=$(cat ${name}/BUILDX_PLATFORMS)
fi

docker build --platform ${BUILDX_PLATFORMS} -t mitsutaka/${name}:${tag} ${name}
