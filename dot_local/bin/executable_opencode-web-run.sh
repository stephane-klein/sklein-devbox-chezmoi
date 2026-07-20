#!/usr/bin/env bash
set -euo pipefail

export XDG_RUNTIME_DIR=/tmp/user/1000
export GOPASS_AGE_NO_CONFIRM=1
export BROWSER=/bin/true
export OPENCODE_SERVER_USERNAME=stephane
OPENCODE_SERVER_PASSWORD=$(gopass show -o opencode/stephane/password)
export OPENCODE_SERVER_PASSWORD
exec mise exec -- opencode web
