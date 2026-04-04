#!/bin/bash
if [ -f "$HOME/.config/mise/config.toml" ]; then
    mise install
fi
