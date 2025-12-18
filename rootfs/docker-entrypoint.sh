#!/bin/bash

set -ex

TEMP_CERTS="/tmp/certs"
HOOKS_DIR="/etc/ca-certificates/update.d"

mkdir -p "${TEMP_CERTS}"

update-ca-certificates --fresh --verbose \
    --etccertsdir "${TEMP_CERTS}" \
    --hooksdir "/dev/null"

mkdir -p "${CA_OUTPUT_DIR}"

find "${TEMP_CERTS}" -type f -exec cp -Lpf {} "${CA_OUTPUT_DIR}" \;
find "${TEMP_CERTS}" -type l -exec cp -Lpf {} "${CA_OUTPUT_DIR}" \;

if [ -d "$HOOKS_DIR" ]
then
  echo "Running hooks in $HOOKS_DIR..."

  run-parts --verbose --exit-on-error "$HOOKS_DIR"

  echo "done."
fi
