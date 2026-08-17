[![build](https://github.com/mitsutaka/docker-libs/actions/workflows/build.yml/badge.svg)](https://github.com/mitsutaka/docker-libs/actions/workflows/build.yml)

# docker-libs

Docker containers, published to the GitHub Container Registry.

```console
docker pull ghcr.io/mitsutaka/<name>:<tag>
```

## Images

| Image | Tag |
| --- | --- |
| [ipmi_exporter](https://github.com/mitsutaka/docker-libs/pkgs/container/ipmi_exporter) | `v1.10.1-2`, `latest` |
| [mbsync](https://github.com/mitsutaka/docker-libs/pkgs/container/mbsync) | `1.5.1-r1`, `latest` |
| [offlineimap](https://github.com/mitsutaka/docker-libs/pkgs/container/offlineimap) | `8.0.3`, `latest` |
| [openssh](https://github.com/mitsutaka/docker-libs/pkgs/container/openssh) | `10.3_p1-r0`, `latest` |
| [openvpn-client](https://github.com/mitsutaka/docker-libs/pkgs/container/openvpn-client) | `2.7.5-r0`, `latest` |
| [rsync](https://github.com/mitsutaka/docker-libs/pkgs/container/rsync) | `3.4.3-r1`, `latest` |
| [rsyncd](https://github.com/mitsutaka/docker-libs/pkgs/container/rsyncd) | `3.4.3-r1`, `latest` |
| [sshd](https://github.com/mitsutaka/docker-libs/pkgs/container/sshd) | `20260817`, `alpine` |
| [utils](https://github.com/mitsutaka/docker-libs/pkgs/container/utils) | `15`, `latest` |
| [znc](https://github.com/mitsutaka/docker-libs/pkgs/container/znc) | `1.10.2-r0`, `latest` |

`debian`, `centos` and `fedora` are local development images. They have no `TAG`
file and so are never published; build them with `make build-debian`.

## Excluded images

Images listed in the [`EXCLUDE`](EXCLUDE) file are skipped by CI and by
`make build-all`. Currently `stone`, `ejabberd` and `ubuntu`; see the file for
the reasons.

```console
make excluded          # show what is skipped and why it is split
make build-stone       # build an excluded image anyway, on request
```

Deleting a line from `EXCLUDE` re-enables the image. `excluded.sh` is the only
reader of the file, so CI and the Makefile cannot disagree about what is skipped.

## How an image is defined

Each image is a directory whose files carry its metadata:

| File | Required | Purpose |
| --- | --- | --- |
| `Dockerfile` | yes | the build |
| `TAG` | to publish | version tag. an image with no `TAG` is never published |
| `BRANCH` | no | an extra floating tag, usually `latest` |
| `BUILDX_PLATFORMS` | no | platform list for this image, overriding the default |

`image_meta.sh` is the single reader of this convention; both the local build and
CI go through it.

## Releasing

CI publishes an image only when the tag named in its `TAG` file is not already
present in the registry. **Bumping `TAG` is what triggers a release** — merge
that change to `master` and the workflow builds and pushes it. Nothing else
needs to be touched, and re-running the workflow on an unchanged tree is a no-op.

Pull requests build the affected images for `linux/amd64` without pushing, so a
`TAG` bump is validated before it merges.

## Local builds

```console
make list              # images make will build
make excluded          # images that are skipped, and why the list is split
make lint              # hadolint every Dockerfile
make build-rsync       # build one image for the host platform
make build-all         # build all of them
make clean             # remove the buildx builder
```

`make build-*` loads the result into the local docker image store, which docker
only supports for a single platform. To exercise the full multi-platform build
that CI runs:

```console
make build-rsync LOAD=false
```

To push by hand, bypassing CI:

```console
echo "$GITHUB_TOKEN" | docker login ghcr.io -u mitsutaka --password-stdin
PUSH=true ./build.sh rsync
```

## Scripts

| Script | Purpose |
| --- | --- |
| `image_meta.sh NAME` | resolve tags and platforms for one image |
| `tag_exists.sh NAME` | is this image's `TAG` already published? `0` yes, `1` no, `2` error |
| `excluded.sh` | the excluded image names, parsed from `EXCLUDE` |
| `build_matrix.sh` | JSON array of images needing a build, for the CI matrix |
| `build.sh NAME` | build one image |
