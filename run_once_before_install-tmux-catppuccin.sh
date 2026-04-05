#!/bin/bash
CATPPUCCIN_DIR="$HOME/.config/tmux/plugins/catppuccin"
if [ ! -d "$CATPPUCCIN_DIR" ]; then
    mkdir -p "$(dirname "$CATPPUCCIN_DIR")"
    curl -L https://github.com/catppuccin/tmux/archive/refs/tags/v2.1.3.tar.gz | tar -xz -C /tmp
    mv /tmp/tmux-2.1.3 "$CATPPUCCIN_DIR"
fi
