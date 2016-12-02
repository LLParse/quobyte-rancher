FROM alpine:3.4

RUN \
  apk add --update --no-cache curl && \
  curl -sL https://github.com/quobyte/docker-volume/releases/download/v1.0-beta-2/docker-quobyte-plugin -o /usr/bin/docker-quobyte-plugin && \
  chmod +x /usr/bin/docker-quobyte-plugin

ENTRYPOINT ["/usr/bin/docker-quobyte-plugin"]
