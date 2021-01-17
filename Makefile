#!/usr/bin/make -f

# TODO: Learn from https://gist.github.com/mouttounet/d8347e0555c1d232b7bacb881c3ef1da

SHELL = /bin/bash
NS = lp/hugo-builder
PORTS = -p 1313:1313
VOLUMES = -v "$(realpath ./orgdocs)":/src
NAME = hugo-server
IMAGE = lp/hugo-builder

srcdir = .

default: build

lint: static-analysis dockerfile_policies
build: static-analysis docker-build
start: hugo-server-start
stop: hugo-server-stop

static-analysis:
	@echo "Performing static analysis..."
	hadolint Dockerfile
	@echo "Static analysis performed!"

docker-build:
	@echo "Building Hugo Builder container..."
	docker build -t ${IMAGE} .
	@echo "Hugo Builder container built!"
	docker images ${IMAGE}

hugo-build: 
	@echo "Building thing..."
	@docker run -dt --rm $(VOLUMES) --name ${NAME} ${IMAGE} hugo
	sleep 2 # Pause a moment to let this container stop.
	@echo "Thing built!"

hugo-server-start: hugo-build
	@echo "Starting server..."
	docker run -dt --rm $(VOLUMES) $(PORTS) --name ${NAME} ${IMAGE} hugo server -w --bind=0.0.0.0
	@echo "Server started!"
	docker ps

check-health:
	@echo "Checking the health of the Hugo Server..."
	@docker inspect --format='{{json .State.Health}}' ${NAME}

hugo-server-stop:
	@echo "Stopping server..."
	docker stop `docker container ls -qf "ancestor=${IMAGE}"`
	@echo "Server stopped!"
	docker ps

inspect-labels:
	@echo "Inspecting Hugo Server Container labels..."
	@echo "maintainer set to..."
	@docker inspect --format '{{ index .Config.Labels "maintainer" }}' \
			${NAME}
	@echo "Labels inspected!"

dockerfile_policies:
	@echo "Checking Container policies..."
	@docker run --rm -it -v $(PWD):/root/ \
			projectatomic/dockerfile-lint \
			dockerfile_lint --rulefile policies/all.yml
	@echo "FinShare Container policies checked!"
