#!/bin/sh

set -e

run_hooks() {
  if [ -d "$1" ]
  then
    echo "Running hooks in $1..."

    run-parts --verbose --exit-on-error "$1"

    echo "done."
  fi
}

TEMP_CERTS="/tmp/certs"

set -x

mkdir -p "${TEMP_CERTS}"

run_hooks "/etc/ca-certificates/pre-update.d"

update-ca-certificates --fresh --verbose \
    --etccertsdir "${TEMP_CERTS}" \
    --hooksdir "/dev/null"

mkdir -p "${CA_OUTPUT_DIR}"

find "${TEMP_CERTS}" -type f -exec cp -Lpf {} "${CA_OUTPUT_DIR}" \;
find "${TEMP_CERTS}" -type l -exec cp -Lpf {} "${CA_OUTPUT_DIR}" \;

run_hooks "/etc/ca-certificates/post-update.d"
