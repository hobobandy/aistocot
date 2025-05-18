# syntax=docker/dockerfile:1
############################################
### Stage 1: Fetch & extract dispatcher ###
############################################
FROM python:3.13.3-slim-bookworm AS builder

# allow version bumping
ENV DISPATCHER_VERSION=2.2
ENV BASE_URL=https://www.aishub.net/downloads/dispatcher/packages/${DISPATCHER_VERSION}

# avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# install only what we need to fetch, verify, and unpack
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      wget \
      bzip2 \
      tar \
      coreutils \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# 1) download payload + its .md5  
# 2) verify checksum (build fails on mismatch)  
# 3) extract into /home/ais
RUN wget -qO full.tar.bz2     ${BASE_URL}/full.tar.bz2 \
 && wget -qO full.tar.bz2.md5 ${BASE_URL}/full.tar.bz2.md5 \
 && md5sum -c full.tar.bz2.md5 \
 && mkdir -p /home/ais \
 && tar xjf full.tar.bz2 -C /home/ais \
 && rm -rf /tmp/*

############################################
### Stage 2: Minimal runtime image       ###
############################################
FROM python:3.13.3-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive

# tini for proper PID-1 signal handling
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      tini \
      ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# non-root runtime user
RUN groupadd -r ais && useradd -r -g ais ais

# copy over just the extracted dispatcher tree
COPY --from=builder --chown=ais:ais /home/ais /home/ais

WORKDIR /home/ais
USER ais

############################################
### START: User Configuration            ###
############################################

# AIS Input Server Mode (if different than UDP, other CLI switches may be required in CMD at end of file)
ENV MODE=udp-server

# AIS Input Host/Port (0.0.0.0 to listen on any IP address)
ENV LISTEN_HOST=0.0.0.0
ENV LISTEN_PORT=2233

# Destination of the AIS messages (host:port)
ENV DEST_HOST=127.0.0.1
ENV DEST_PORT=2222

# Downsampling - reduces outgoing traffic by transmitting only 1 position report per ship in the specified time frame (in seconds, from 0 to 60)
ENV WAIT=5

############################################
### END: User Configuration              ###
############################################

# document ports
EXPOSE ${LISTEN_PORT} ${DEST_PORT}

COPY --chown=ais:ais entrypoint.sh /home/ais/entrypoint.sh
RUN chmod +x /home/ais/entrypoint.sh

ENTRYPOINT ["/usr/bin/tini","--","/home/ais/entrypoint.sh"]
