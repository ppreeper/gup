.DEFAULT_GOAL := all
SHELL := /bin/bash

UID := $(shell id -u)
GID := $(shell id -g)
PWD := $(shell pwd)

bashly:
	@docker run --rm -it -e BASHLY_TAB_INDENT=1 -v "${PWD}:/app" docker.io/dannyben/bashly generate --upgrade

fix-permissions:
	@docker run --rm \
		-v "$(PWD):/app" \
		docker.io/alpine:latest \
		chown -R $(UID):$(GID) /app

.PHONY: bashly fix-permissions
all: bashly fix-permissions