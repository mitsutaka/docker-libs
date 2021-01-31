IMAGES = $(shell find * -name Dockerfile | grep -vE "(armv7-plexmediaserver|mediaproxy-|softether-)" | xargs dirname)
BUILDX_NAME := docker-libs

# Unsupported linux/386,linux/arm/v6 for ubuntu:20.04
BUILDX_PLATFORMS := linux/amd64,linux/arm64,linux/ppc64le,linux/s390x,linux/arm/v7

lint:
	@for name in $(IMAGES); do \
		echo linting $${name}; \
		docker run --rm -i hadolint/hadolint /bin/hadolint - < $${name}/Dockerfile; \
	done

build:
	-docker run --rm --name bimfmt --privileged tonistiigi/binfmt:latest --install "$(BUILDX_PLATFORMS)"
	-docker buildx create --name $(BUILDX_NAME)
	docker buildx use $(BUILDX_NAME)
	for name in $(IMAGES); do \
		echo building $${name}; \
		env BUILDX_PLATFORMS=$(BUILDX_PLATFORMS) ./build.sh $${name}; \
	done

build-load:
	-docker buildx create --name $(BUILDX_NAME)
	docker buildx use --name $(BUILDX_NAME)
	for name in $(IMAGES); do \
		echo building $${name}; \
		docker buildx build -t mitsutaka/$${name}:latest --load $${name}; \
	done

clean:
	docker buildx rm $(BUILDX_NAME)
	docker stop bimfmt
