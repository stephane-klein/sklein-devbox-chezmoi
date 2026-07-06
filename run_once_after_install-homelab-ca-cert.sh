#!/bin/bash
if command -v gopass &>/dev/null; then
    gopass show homelab/certs/ca/ca.crt 2>/dev/null | sudo tee /etc/pki/ca-trust/source/anchors/homelab-ca.crt > /dev/null && sudo update-ca-trust
fi
