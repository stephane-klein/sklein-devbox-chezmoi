#!/bin/bash
CATPPUCCIN_DIR="$HOME/.config/tmux/plugins/catppuccin"
if [ ! -d "$CATPPUCCIN_DIR" ]; then
    mkdir -p "$(dirname "$CATPPUCCIN_DIR")"
    git clone --depth=1 -b v2.1.3 https://github.com/catppuccin/tmux.git "$CATPPUCCIN_DIR"
fi