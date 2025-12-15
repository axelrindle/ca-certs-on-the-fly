#!/bin/bash

set -ex

TEMP_CERTS="/tmp/certs"

mkdir -p "${TEMP_CERTS}"

update-ca-certificates --fresh --verbose \
    --etccertsdir "${TEMP_CERTS}"

mkdir -p "${CA_OUTPUT_DIR}"

find "${TEMP_CERTS}" -type f -exec cp -Lpf {} "${CA_OUTPUT_DIR}" \;
find "${TEMP_CERTS}" -type l -exec cp -Lpf {} "${CA_OUTPUT_DIR}" \;
