#!/usr/bin/env bash
# ~/bin/install-or-update-neovim.sh

nvim --headless "+Lazy! sync" \
  -c "MasonToolsInstallSync" \
  -c "TSInstallSync" \
  +qa
