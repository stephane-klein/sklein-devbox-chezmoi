#!/bin/bash
if [ -f "$HOME/.config/mise/config.toml" ]; then
    find ~/.local/share/mise/installs -mindepth 2 -maxdepth 2 -type d -empty -exec rm -rf {} +

    mise install
fi
