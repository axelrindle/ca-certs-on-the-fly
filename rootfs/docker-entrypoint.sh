#!/bin/bash

set -ex

update-ca-certificates --fresh --verbose \
    --etccertsdir "${CA_OUTPUT_DIR:-/etc/ssl/certs}"
