#!/bin/bash
if command -v kubectl &>/dev/null && command -v gopass &>/dev/null; then
    "$HOME/bin/generate-kubeconfig.sh"
fi
