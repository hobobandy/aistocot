#!/bin/sh

set -e

exec /home/ais/bin/aisdispatcher_x86_64 \
  -m "${MODE}" \
  -d "${DEST_HOST}:${DEST_PORT}" \
  -h "${LISTEN_HOST}" \
  -p "${LISTEN_PORT}" \
  -s "aisdispatcher" \
  -w "${WAIT}"