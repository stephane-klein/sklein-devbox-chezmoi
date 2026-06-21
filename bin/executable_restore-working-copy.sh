#!/usr/bin/env bash
# ~/bin/restore-working-copy.sh
# Extract a snapshot archive to a temporary directory and print its path.
set -euo pipefail

ARCHIVE="${1:?Usage: restore-working-copy.sh <archive.tar.gz>}"

if [[ ! -f "$ARCHIVE" ]]; then
    echo "Error: file not found: $ARCHIVE" >&2
    exit 1
fi

BASENAME="$(basename "$ARCHIVE" .tar.gz)"
DEST="/tmp/${BASENAME}-$(date +%Y%m%d-%H%M%S)-$$"

mkdir -p "$DEST"
tar -xzf "$ARCHIVE" -C "$DEST"

echo "${DEST}"
