
.DEFAULT_GOAL = help

# Project variables
NAME        := poc-rust
VENDOR      := philtremblay
URL         := https://github.com/$(VENDOR)/$(NAME)

# Build variables
COMMIT_HASH  ?= $(shell git rev-parse --short HEAD 2>/dev/null)
BUILD_DATE   ?= $(shell date +%FT%T%z)
VERSION      ?= $(shell git describe --tags --exact-match 2>/dev/null || git describe --tags 2>/dev/null || echo "v0.0.0-$(COMMIT_HASH)")

# Docker variables
DEFAULT_TAG  ?= $(shell echo "$(VERSION)" | tr -d 'v')
REGISTRY     := gcr.io
DOCKER_IMAGE := $(REGISTRY)/$(VENDOR)/$(NAME)
DOCKER_TAG   ?= $(DEFAULT_TAG)

.PHONY: docker
docker: DOCKER_IMAGE ?= $(DOCKER_IMAGE)
docker: ## Build the project container with Docker
	@ $(MAKE) --no-print-directory log-$@
	@ docker build --tag $(DOCKER_IMAGE):$(DOCKER_TAG) .

.PHONY: push
push: DOCKER_IMAGE ?= $(DOCKER_IMAGE)
push: ## Push the project container
	@ $(MAKE) --no-print-directory log-$@
	@ docker push $(DOCKER_IMAGE):$(DOCKER_TAG)

.PHONY: local-run
local-run: ## Run the project locally via cargo
	@ $(MAKE) --no-print-directory log-$@
	@ . env.sh && RUST_BACKTRACE=1 cargo run

.PHONY: stress
stress: ## Stress test api using Drill via benchmark.yml
	@ $(MAKE) --no-print-directory log-$@
	@ drill --benchmark benchmark.yml --stats

#####################
## Release targets ##
#####################
PATTERN =

# if the last relase was alpha, beta or rc, 'release' target has to used with current
# cycle release. For example if latest tag is v0.8.0-rc.2 and v0.8.0 GA needs to get
# released the following should be executed: "make release version=0.8.0"
.PHONY: release
release: version ?= $(shell echo $(VERSION) | sed 's/^v//' | awk -F'[ .]' '{print $(PATTERN)}')
release: ## Prepare release
	@ $(MAKE) --no-print-directory log-$@
	@ ./scripts/release/release.sh "$(version)" "$(VERSION)" "1"

.PHONY: patch
patch: PATTERN = '\$$1\".\"\$$2\".\"\$$3+1'
patch: release ## Prepare Patch release

.PHONY: minor
minor: PATTERN = '\$$1\".\"\$$2+1\".0\"'
minor: release ## Prepare Minor release

.PHONY: major
major: PATTERN = '\$$1+1\".0.0\"'
major: release ## Prepare Major release

.PHONY: help
help:
	@ grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

log-%:
	@ grep -h -E '^$*:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m==> %s\033[0m\n", $$2}'