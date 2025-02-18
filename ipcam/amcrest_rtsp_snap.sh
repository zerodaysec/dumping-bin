#!/bin/bash
set -x
HOST="${1}"
USER="${AMCREST_USER}"
PASS="${AMCREST_PW}"
PORT="37777"

echo "Snapping image from ${HOST}"
AUTH="${USER}:${PASS}"
curl -ksv -u ${USER}:${PASS} "http://${HOST}:${PORT}/cgi-bin/snapshot.cgi" > out.jpeg
