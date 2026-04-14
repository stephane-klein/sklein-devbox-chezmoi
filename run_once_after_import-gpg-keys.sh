#!/bin/bash
if [ -f "$HOME/.config/gopass/age/identities" ] && [ -d "$HOME/.local/share/gopass/stores/root" ]; then
    "$HOME/bin/import-gpg-keys.sh"
fi
