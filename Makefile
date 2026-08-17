ALL_IMAGES := $(sort $(patsubst %/Dockerfile,%,$(wildcard */Dockerfile)))

# Skipped by CI and by build-all alike. See the EXCLUDE file for the reasons.
EXCLUDED := $(shell ./excluded.sh)

IMAGES := $(filter-out $(EXCLUDED),$(ALL_IMAGES))

SHELL_SOURCES := $(wildcard *.sh) $(wildcard */entrypoint.sh)

BUILDX_NAME := docker-libs

# The PLATFORMS file is the single source of truth for the default platform list;
# image_meta.sh reads it too, and CI goes through image_meta.sh.
PLATFORMS := $(shell cat PLATFORMS)

# Local builds load into the docker image store, which implies a single platform.
# Set LOAD=false to exercise the full multi-platform build the CI does.
LOAD := true

DOCKER_BUILDKIT := 1
# PLATFORMS is passed through so that "make build-rsync PLATFORMS=linux/amd64"
# still overrides the file for a one-off build.
BUILD_ENV := env PLATFORMS=$(PLATFORMS) LOAD=$(LOAD) DOCKER_BUILDKIT=$(DOCKER_BUILDKIT)

# Pinned so that "make lint" and CI, which runs this same target, cannot disagree
# about which rules exist.
HADOLINT_IMAGE := hadolint/hadolint:v2.12.0
SHELLCHECK_IMAGE := koalaman/shellcheck:stable
ACTIONLINT_IMAGE := rhysd/actionlint:latest

# These Dockerfiles predate current hadolint rules and still trip a number of
# style warnings, so only hard errors fail the lint. Tighten to "warning" once
# they have been cleaned up.
HADOLINT_THRESHOLD := error

README_BEGIN := <!-- BEGIN GENERATED IMAGE TABLE -->
README_END := <!-- END GENERATED IMAGE TABLE -->
TABLE_TMP := .image_table.tmp
README_TMP := .README.tmp

AWK_SPLICE = awk -v begin='$(README_BEGIN)' -v end='$(README_END)' -v table='$(TABLE_TMP)' \
	'$$0 == begin { print; while ((getline line < table) > 0) print line; skip = 1; next } \
	 $$0 == end { skip = 0 } \
	 !skip { print }'

.PHONY: list excluded check lint shellcheck actionlint readme readme-check pre build-all clean

list:
	@for name in $(IMAGES); do echo $${name}; done

excluded:
	@echo "skipped by CI and build-all (EXCLUDE):"
	@for name in $(EXCLUDED); do echo "  $${name}"; done
	@echo
	@echo "'make build-<name>' still builds an excluded image on request."

# Everything CI checks on every run, so a full pass can be reproduced locally
# with one command.
check: lint shellcheck actionlint readme-check

lint:
	@rc=0; \
	for name in $(IMAGES); do \
		echo "linting $${name}/Dockerfile"; \
		docker run --rm -i $(HADOLINT_IMAGE) \
			hadolint --failure-threshold $(HADOLINT_THRESHOLD) - <$${name}/Dockerfile || rc=1; \
	done; \
	exit $${rc}

shellcheck:
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "shellcheck $(SHELL_SOURCES)"; \
		shellcheck $(SHELL_SOURCES); \
	else \
		echo "shellcheck (via $(SHELLCHECK_IMAGE)) $(SHELL_SOURCES)"; \
		docker run --rm -v "$(CURDIR):/mnt:ro" -w /mnt $(SHELLCHECK_IMAGE) $(SHELL_SOURCES); \
	fi

# The workflow is what decides whether anything gets published, so it is linted
# too. actionlint also shellchecks the run: blocks.
actionlint:
	@if command -v actionlint >/dev/null 2>&1; then \
		actionlint; \
	else \
		echo "actionlint (via $(ACTIONLINT_IMAGE))"; \
		docker run --rm -v "$(CURDIR):/repo:ro" -w /repo $(ACTIONLINT_IMAGE); \
	fi

# The README image table is generated from the TAG and BRANCH files so it cannot
# drift; readme-check is the CI guard that it was regenerated.
readme:
	@./image_table.sh >$(TABLE_TMP)
	@$(AWK_SPLICE) README.md >$(README_TMP)
	@rm -f $(TABLE_TMP)
	@mv $(README_TMP) README.md
	@echo "regenerated the image table in README.md"

readme-check:
	@./image_table.sh >$(TABLE_TMP)
	@$(AWK_SPLICE) README.md >$(README_TMP)
	@rm -f $(TABLE_TMP)
	@if cmp -s $(README_TMP) README.md; then \
		rm -f $(README_TMP); \
		echo "README.md image table is up to date"; \
	else \
		diff -u README.md $(README_TMP) || true; \
		rm -f $(README_TMP); \
		echo "README.md image table is stale; run 'make readme'" >&2; \
		exit 1; \
	fi

pre:
	-docker run --rm --name binfmt --privileged tonistiigi/binfmt:latest --install "$(PLATFORMS)"
	-docker buildx create --name $(BUILDX_NAME)
	docker buildx use $(BUILDX_NAME)

# A shell for loop reports only its last command's status, so failures are
# collected explicitly; otherwise one broken image in the middle would leave
# "make build-all" exiting 0.
build-all: pre
	@rc=0; \
	failed=''; \
	for name in $(IMAGES); do \
		echo "building $${name}"; \
		$(BUILD_ENV) ./build.sh $${name} || { rc=1; failed="$${failed} $${name}"; }; \
	done; \
	if [ -n "$${failed}" ]; then echo "failed:$${failed}" >&2; fi; \
	exit $${rc}

build-%: pre
	$(BUILD_ENV) ./build.sh $(subst build-,,$@)

clean:
	-docker buildx rm $(BUILDX_NAME)
	rm -f $(TABLE_TMP) $(README_TMP)
