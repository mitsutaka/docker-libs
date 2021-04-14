IMAGES = $(shell find * -name Dockerfile | grep -vE "(armv7-plexmediaserver|mediaproxy-|softether-)" | xargs dirname)
BUILDX_NAME := docker-libs

# Unsupported linux/386,linux/arm/v6 for ubuntu:20.04
BUILDX_PLATFORMS := linux/amd64,linux/arm64,linux/ppc64le,linux/s390x,linux/arm/v7

lint:
	@for name in $(IMAGES); do \
		echo linting $${name}; \
		docker run --rm -i hadolint/hadolint /bin/hadolint - < $${name}/Dockerfile; \
	done

pre:
	-docker run --rm --name bimfmt --privileged tonistiigi/binfmt:latest --install "$(BUILDX_PLATFORMS)"
	-docker buildx create --name $(BUILDX_NAME)
	docker buildx use $(BUILDX_NAME)

build-all: pre
	for name in $(IMAGES); do \
		echo building $${name}; \
		env BUILDX_PLATFORMS=$(BUILDX_PLATFORMS) ./build.sh $${name}; \
	done

build-%: pre
	env BUILDX_PLATFORMS=$(BUILDX_PLATFORMS) ./build.sh $(subst build-,,$@)

pre-load:
	-docker buildx create --name $(BUILDX_NAME)
	docker buildx use $(BUILDX_NAME)

build-load-all: pre-load
	for name in $(IMAGES); do \
		echo building $${name}; \
		docker buildx build -t mitsutaka/$${name}:latest --load $${name}; \
	done

build-load-%: pre-load
	docker buildx build -t mitsutaka/$(subst build-load-,,$@):latest --load $(subst build-load-,,$@)

clean:
	docker buildx rm $(BUILDX_NAME)
	docker stop bimfmt
