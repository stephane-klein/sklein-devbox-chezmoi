#!/bin/bash
if command -v incus &>/dev/null; then
    "$HOME/bin/setup-incus-remote.sh"
else
    echo "WARNING: incus not on PATH yet, incus remote setup deferred to next apply" >&2
    exit 1
fi
