# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Zack Williams

.DEFAULT_GOAL := help
.PHONY: test lint ruff license help

# Use bash for pushd/popd, and to fail quickly.
SHELL      := bash -eu -o pipefail

# venv tooling
VIRTUALENV ?= python -m venv

# name of the venv
VENV_NAME  := venv_tutorial

$(VENV_NAME): requirements.txt
	$(VIRTUALENV) $@ ;\
  source ./$@/bin/activate ;\
  pip install -r requirements.txt

# prep
prep: $(VENV_NAME) docker-build

# all files with extensions
PYTHON_FILES      ?= $(wildcard jinja/*.py)

# Lint targets
license: $(VENV_NAME) ## Check license with the reuse tool
	source ./$</bin/activate ; set -u ;\
  reuse --version ;\
  reuse --root . lint

ruff: $(VENV_NAME) ## check python formatting with ruff
	source ./$</bin/activate ;\
	ruff check

# Docker related
docker-build: ## build the docker test container
	docker build -t molecule-systemd:debian-13 ansible/docker

CONTAINER_NAME ?= debian-13-priv

docker-run: ## start the docker test container
	docker run -it --rm \
    --name ${CONTAINER_NAME} \
    -v "/sys/fs/cgroup:/sys/fs/cgroup:rw" \
    --privileged --cgroupns=host \
    --tmpfs /run --tmpfs /tmp \
    molecule-systemd:debian-13

docker-exec:  ## Run a shell in the docker test container
	docker exec -it ${CONTAINER_NAME} /bin/bash

docker-stop: ## stop the docker test container
	docker stop ${CONTAINER_NAME}

hadolint:  ## lint the test container Dockerfile
	hadolint docker/Dockerfile

# utilities
clean: ## cleanup virtualenv and collections
	rm -rf $(VENV_NAME)

help: ## Print help for each target
	@echo tutorial make targets
	@echo
	@grep '^[[:alnum:]_-]*:.* ##' $(MAKEFILE_LIST) \
    | sort | awk 'BEGIN {FS=":.* ## "}; {printf "%-25s %s\n", $$1, $$2};'
