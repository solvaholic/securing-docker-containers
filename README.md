# securing-docker-containers

Work repository for manning.com Securing Docker Containers live project

https://www.manning.com/liveproject/securing-docker-containers

## To run `clair-scanner`

The `clair-scanner` binary for macOS is published unsigned and I don't want to install Go just to build it. So I built it in a Docker container.

The database and clair itself run in containers, so this should work great. Right?

I didn't quite get it working, though. This :point_down: seemed to run the check OK but there was a panic at the end when closing a network socket or something.

```bash
docker network create --attachable --internal clair

docker run -d --rm --network clair --hostname clair-db \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  arminc/clair-db:latest
docker run -d --rm --network clair --hostname clair \
  -v "$(realpath ./clair_config)":/config:ro \
  arminc/clair-local-scan:latest

_dockerfile="FROM golang:alpine3.12 AS goBuild
LABEL name='Run arminc/clair-scanner'
SHELL [\"/bin/ash\", \"-eo\", \"pipefail\", \"-c\"]
RUN wget -O - https://api.github.com/repos/arminc/clair-scanner/tarball/ | tar xz -C /
RUN mv /arminc-clair-scanner-* /arminc-clair-scanner
WORKDIR /arminc-clair-scanner
RUN CGO_ENABLED=0 go build
RUN CGO_ENABLED=0 go install
ENTRYPOINT [\"/go/bin/clair-scanner\"]
CMD [\"--help\"]"

printf "%s\n" "$_dockerfile" \
| docker build -t clair-scanner -

docker run -it --rm --network clair --hostname clair-scanner \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  clair-scanner \
  --ip clair-scanner \
  --clair="http://clair:6060" \
  lp/hugo-builder
```
