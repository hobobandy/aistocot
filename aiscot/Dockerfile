# syntax=docker/dockerfile:1
FROM python:3.13.3-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive

# pin versions via build args
ARG PYTAK_VERSION=7.1.0-beta10
ARG AISCOT_VERSION=7.0.10

# install dependencies + .debs in one layer
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      wget \
      coreutils \
      ca-certificates \
      python3-cryptography \
      python3-aiohttp \
 && wget -O /tmp/pytak.deb \
      "https://github.com/snstac/pytak/releases/download/v${PYTAK_VERSION}/pytak_latest_all.deb" \
 && wget -O /tmp/aiscot.deb \
      "https://github.com/snstac/aiscot/releases/download/v${AISCOT_VERSION}/aiscot_latest_all.deb" \
 && apt-get install -f -y /tmp/pytak.deb /tmp/aiscot.deb \
 && rm -rf /var/lib/apt/lists/* /tmp/*.deb

# non-root user for runtime security
RUN mkdir -p /opt/aiscot \
 && chown aiscot:aiscot /opt/aiscot

WORKDIR /opt/aiscot
USER aiscot

# copy only what’s needed
COPY --chown=aiscot:aiscot config.ini .

ENTRYPOINT ["aiscot"]
CMD ["-c", "config.ini"]