#!/bin/bash
CATPUUCCIN_DELTA_DIR="$HOME/.config/git/catppuccin.gitconfig"
if [ ! -f "$CATPUUCCIN_DELTA_DIR" ]; then
    mkdir -p "$(dirname "$CATPUUCCIN_DELTA_DIR")"
    curl -fsSL https://raw.githubusercontent.com/catppuccin/delta/main/catppuccin.gitconfig \
        -o "$CATPUUCCIN_DELTA_DIR"
fi
