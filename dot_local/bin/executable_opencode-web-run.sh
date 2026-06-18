#!/usr/bin/env bash
set -euo pipefail

BROWSER=/bin/true \
OPENCODE_SERVER_USERNAME=stephane \
OPENCODE_SERVER_PASSWORD=$(gopass show -o opencode/stephane/password) \
  exec mise exec -- opencode web
