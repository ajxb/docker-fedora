SHELL=/usr/bin/env bash

# Versioning information
VERSION?=latest

# Docker parameters
DOCKER_OPTS?=
DOCKER_BUILD_ARGS?=
DOCKER_IMAGE?=ajxb/fedora
DOCKER_IMAGE_TAG?=$(VERSION)
DOCKER_REGISTRY?=docker.io
DOCKER_CREDS_USR?=$(shell op read "op://Beagle Designs/Docker Hub/username")
DOCKER_CREDS_PSW?=$(shell op read "op://Beagle Designs/Docker Hub/pat")

.PHONY: build publish

build:
	docker buildx build $(DOCKER_BUILD_ARGS) $(DOCKER_OPTS) --pull --rm --file Dockerfile --tag $(DOCKER_REGISTRY)/$(DOCKER_IMAGE):$(DOCKER_IMAGE_TAG) .

publish: build
	@docker login -u $(DOCKER_CREDS_USR) -p $(DOCKER_CREDS_PSW) $(DOCKER_REGISTRY)
	docker push $(DOCKER_REGISTRY)/$(DOCKER_IMAGE):$(DOCKER_IMAGE_TAG)
	docker tag $(DOCKER_REGISTRY)/$(DOCKER_IMAGE):$(DOCKER_IMAGE_TAG) $(DOCKER_REGISTRY)/$(DOCKER_IMAGE):latest
	docker push $(DOCKER_REGISTRY)/$(DOCKER_IMAGE):latest
