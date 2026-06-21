#!/usr/bin/env bash
# ~/bin/snapshot-working-copy.sh
# Quick local snapshot of a working directory, including VCS metadata.
# Stored in ~/snapshot/YYYY-MM-DD_HHMM/ — treat these as ephemeral.
set -euo pipefail

TARGET_DIR="${1:-.}"

cd "$TARGET_DIR"

PROJECT_NAME="$(basename "$(pwd)")"
SNAPSHOT_DIR="${HOME}/snapshot/$(date +%Y-%m-%d_%H%M)"

mkdir -p "$SNAPSHOT_DIR"

FILENAME="${PROJECT_NAME}.tar.gz"
OUTPUT="${SNAPSHOT_DIR}/${FILENAME}"

tar -czf "$OUTPUT" -C "$(pwd)" .

echo "Snapshot created: ${OUTPUT} ($(du -h "$OUTPUT" | cut -f1))"
