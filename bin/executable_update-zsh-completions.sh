#!/bin/bash
# Script to update zsh completions for GitHub CLI and Jujutsu

set -euo pipefail

COMPLETIONS_DIR="${HOME}/.config/zsh/completions"

# GitHub CLI completion
if command -v gh &> /dev/null; then
    mkdir -p "$COMPLETIONS_DIR"
    gh completion -s zsh > "${COMPLETIONS_DIR}/_gh"
    echo "✓ GitHub CLI completions updated"
else
    echo "Warning: gh not found, skipping GitHub CLI completions" >&2
fi

# Pitchfork completion
if command -v pitchfork &> /dev/null; then
    mkdir -p "$COMPLETIONS_DIR"
    pitchfork completion zsh > "${COMPLETIONS_DIR}/_pitchfork"
    echo "✓ Pitchfork completions updated"
else
    echo "Warning: pitchfork not found, skipping Pitchfork completions" >&2
fi

# Jujutsu completion (existing script)
if [[ -x "${HOME}/bin/update-jj-completion.sh" ]]; then
    "${HOME}/bin/update-jj-completion.sh"
else
    echo "Warning: ~/bin/update-jj-completion.sh not found or not executable" >&2
fi

echo ""
echo "Restart your terminal or run 'exec zsh' to apply changes"
