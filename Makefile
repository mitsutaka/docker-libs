ALL_IMAGES := $(shell find * -name Dockerfile | xargs -I {} dirname {} | sort)

# Skipped by CI and by build-all alike. See the EXCLUDE file for the reasons.
EXCLUDED := $(shell ./excluded.sh)

IMAGES := $(filter-out $(EXCLUDED),$(ALL_IMAGES))

BUILDX_NAME := docker-libs

# Keep in sync with PLATFORMS in .github/workflows/build.yml.
# linux/386 and linux/arm/v6 are unsupported by ubuntu:20.04.
PLATFORMS := linux/amd64,linux/arm64,linux/ppc64le,linux/arm/v7

# Local builds load into the docker image store, which implies a single platform.
# Set LOAD=false to exercise the full multi-platform build the CI does.
LOAD := true

DOCKER_BUILDKIT := 1
BUILD_ENV := env PLATFORMS=$(PLATFORMS) LOAD=$(LOAD) DOCKER_BUILDKIT=$(DOCKER_BUILDKIT)

.PHONY: lint list excluded pre build-all clean

list:
	@for name in $(IMAGES); do echo $${name}; done

excluded:
	@echo "skipped by CI and build-all (EXCLUDE):"
	@for name in $(EXCLUDED); do echo "  $${name}"; done
	@echo
	@echo "'make build-<name>' still builds an excluded image on request."

lint:
	@for name in $(IMAGES); do \
		echo linting $${name}; \
		docker run --rm -i hadolint/hadolint /bin/hadolint - < $${name}/Dockerfile; \
	done

pre:
	-docker run --rm --name binfmt --privileged tonistiigi/binfmt:latest --install "$(PLATFORMS)"
	-docker buildx create --name $(BUILDX_NAME)
	docker buildx use $(BUILDX_NAME)

build-all: pre
	for name in $(IMAGES); do \
		echo building $${name}; \
		$(BUILD_ENV) ./build.sh $${name}; \
	done

build-%: pre
	$(BUILD_ENV) ./build.sh $(subst build-,,$@)

clean:
	-docker buildx rm $(BUILDX_NAME)
