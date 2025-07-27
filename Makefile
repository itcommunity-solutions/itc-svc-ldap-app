IGNORE_GOALS := help help-parameters build

ifneq (,$(filter-out $(IGNORE_GOALS),$(MAKECMDGOALS)))
ifndef VERSION
  $(error VERSION is not set. Usage: make <target> VERSION=x.y.z)
endif
endif



CONTAINER_NAME=openldap-identity-prod
REPO=itcommunity/$(CONTAINER_NAME)
GIT_SHA=$(shell git rev-parse --short HEAD)
LOCAL_TAG=$(REPO):localtest
PROD_TAG=$(REPO):prod
VERSION_TAG=$(REPO):$(VERSION)
SHA_TAG=$(REPO):sha-$(GIT_SHA)

.PHONY: build up down restart logs shell tag push clean

help: ## Show this help message
	@echo "Usage: make <target> [VERSION=<version>]"
	@echo "Please run make help-parameters to check how to use"
	@echo "Makefile commands:"
	@echo "  build    - Build the Docker image"
	@echo "  up       - Start the Docker container"
	@echo "  down     - Stop the Docker container"
	@echo "  restart  - Restart the Docker container"
	@echo "  logs     - Show logs from the Docker container"
	@echo "  shell    - Open a shell in the Docker container"
	@echo "  tag      - Tag the Docker image for production and versioning"
	@echo "  push     - Push the tagged images to the repository"
	@echo "  clean    - Remove local images"

help-parameters: ## Show this help message

	@echo "Parameters:"
	@echo "  VERSION  - The version of the image to build (e.g., 1.0.0)"
	@echo "  GIT_SHA  - The short SHA of the current git commit (automatically set)"
	@echo "  LOCAL_TAG - Local tag for testing"
	@echo "  PROD_TAG - Production tag"
	@echo "  VERSION_TAG - Versioned tag"
	@echo "  SHA_TAG  - Tag with git SHA"

build:
	sudo docker build -t $(LOCAL_TAG) .

up:
	sudo docker compose up -d

down:
	sudo docker compose down

restart: down up

logs:
	sudo docker compose logs -f

shell:
	sudo docker exec -it itcommunity/openldap-identity-prod /bin/bash

tag:
	sudo docker tag $(LOCAL_TAG) $(VERSION_TAG)
	sudo docker tag $(LOCAL_TAG) $(PROD_TAG)
	sudo docker tag $(LOCAL_TAG) $(SHA_TAG)

push:
	sudo docker push $(VERSION_TAG)
	sudo docker push $(PROD_TAG)
	sudo docker push $(SHA_TAG)

clean:
	sudo docker rmi -f $(LOCAL_TAG) $(VERSION_TAG) $(PROD_TAG) $(SHA_TAG) || true
