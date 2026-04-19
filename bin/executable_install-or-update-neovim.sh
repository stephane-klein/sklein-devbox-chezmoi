#!/usr/bin/env bash
# ~/bin/install-or-update-neovim.sh

nvim --headless "+Lazy! restore" \
  -c "MasonToolsInstallSync" \
  -c "TSInstallSync" \
  +qa
