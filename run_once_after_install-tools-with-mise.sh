#!/bin/bash
if [ -f "$HOME/.config/mise/config.toml" ]; then
  (
    cd
    mise install -y
    mise prune -y
  )
fi
