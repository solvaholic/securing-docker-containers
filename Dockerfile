FROM alpine:3.12

LABEL maintainer="solvaholic <me@foo.bar>"

RUN apk add --no-cache \
    curl \
    git \
    openssh-client \
    rsync

ENV
  - VERSION 0.64.0
  - SHASUM 99c4752bd46c72154ec45336befdf30c28e6a570c3ae7cc237375cf116cba1f8

HEALTHCHECK --interval=1m --timeout=10s \
  CMD curl -f http://localhost:1313 || exit 1

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# TODO: Put downloads in a volume.

WORKDIR /usr/local/src

RUN curl -OL https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_Linux-64bit.tar.gz
 \
      | tar -xz \
    && mv hugo /usr/local/bin/hugo \

    && curl -L \
      https://bin.equinox.io/c/dhgbqpS8Bvy/minify-stable-linux-amd64.tgz | tar -xz \
    && mv minify /usr/local/bin/ \

    && addgroup -Sg 1000 hugo \
    && adduser -SG hugo -u 1000 -h /src hugo

WORKDIR /src

EXPOSE 1313
