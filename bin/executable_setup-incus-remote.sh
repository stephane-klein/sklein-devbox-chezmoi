#!/usr/bin/env bash
# ~/bin/setup-incus-remote.sh
set -euo pipefail

REMOTE_NAME="incus1"
REMOTE_URL="https://incus-server1.homelab.stephane-klein.info:8443"

if [ ! -f "$HOME/.config/incus/client.crt" ] || [ ! -f "$HOME/.config/incus/client.key" ]; then
    echo "ERROR: ~/.config/incus/client.{crt,key} missing, run 'chezmoi apply' first" >&2
    exit 1
fi

if incus remote list --format csv 2>/dev/null | cut -d',' -f1 | grep -qx "$REMOTE_NAME"; then
    echo "incus remote '$REMOTE_NAME' already configured"
else
    incus remote add "$REMOTE_NAME" "$REMOTE_URL" --accept-certificate
fi
