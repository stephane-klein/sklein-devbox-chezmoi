#!/usr/bin/env bash
# ~/bin/gopass-setup.sh
set -euo pipefail

gopass --yes setup \
    --crypto age \
    --remote git@github.com:stephane-klein/sklein-devbox-secrets.git \
    --name "Stéphane Klein" \
    --email "contact@stephane-klein.info"
