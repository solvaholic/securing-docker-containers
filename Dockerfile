FROM alpine:3.12

LABEL maintainer="solvaholic <me@foo.bar>"

RUN apk add --no-cache \
    curl \
    git \
    openssh-client \
    rsync

ENV VERSION 0.64.0
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# TODO: Put downloads in a volume.
# TODO: Set CMD to 'make server' or so.

WORKDIR /usr/local/src

RUN curl -L \
      https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_linux-64bit.tar.gz \
      | tar -xz \
    && mv hugo /usr/local/bin/hugo \

    && curl -L \
      https://bin.equinox.io/c/dhgbqpS8Bvy/minify-stable-linux-amd64.tgz | tar -xz \
    && mv minify /usr/local/bin/ \

    && addgroup -Sg 1000 hugo \
    && adduser -SG hugo -u 1000 -h /src hugo

WORKDIR /src

EXPOSE 1313
