FROM quay.io/quobyte/quobyte-server:1.3.11

RUN \
  curl -sfL -o /usr/bin/giddyup https://github.com/cloudnautique/giddyup/releases/download/v0.14.0/giddyup && \
  chmod +x /usr/bin/giddyup

ADD main.sh /opt/