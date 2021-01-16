ARG ALPINE_VERSION=3.12

FROM alpine:${ALPINE_VERSION} as hugoBuild

LABEL name="Securing Docker Containers" \
      version="n/a" \
      maintainer="solvaholic <solvaholic@users.noreply.github.com>"

RUN apk add --no-cache \
    curl=7.69.1-r3 \
    git=2.26.2-r0 \
    openssh-client=8.3_p1-r1 \
    rsync=3.1.3-r3

ENV HUGO_VERSION 0.64.0
ENV HUGO_SHASUM 99c4752bd46c72154ec45336befdf30c28e6a570c3ae7cc237375cf116cba1f8
ENV HUGO_TGZ hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
ENV HUGO_UID 1501
ENV HUGO_GID 1501

HEALTHCHECK --interval=1m --timeout=10s \
  CMD curl -f http://localhost:1313 || exit 1

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# TODO: Put downloads in a volume.
WORKDIR /usr/local/src/hugo
ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_TGZ} .
RUN sha256sum ${HUGO_TGZ} | grep -q ${HUGO_SHASUM}
RUN tar -xzf ${HUGO_TGZ} \
    && mv hugo /usr/local/bin/hugo \
    && addgroup -Sg ${HUGO_GID} hugo \
    && adduser -SG hugo -u ${HUGO_UID} -h /src hugo

USER hugo

WORKDIR /src

EXPOSE 1313

ENTRYPOINT [ "/bin/ash", "-c" ]
CMD [ "hugo", "server", "-w", "--bind=0.0.0.0" ]