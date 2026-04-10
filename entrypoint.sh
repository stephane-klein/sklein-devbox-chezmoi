#!/bin/bash
set -e

# Load sklein-devbox environment variables (saved by cont-init.d)
if [ -f "/home/sklein/.config/sklein-devbox/env" ]; then
    source "/home/sklein/.config/sklein-devbox/env"
fi

# Healthcheck mode - return immediately without running the full entrypoint
if [ "$SSH_ORIGINAL_COMMAND" = "healthcheck" ]; then
    echo "ready"
    exit 0
fi

export XDG_RUNTIME_DIR="/tmp/user/$(id -u)"
export GPG_TTY=$(tty)

# Gopass interactive setup (if needed)
if [ ! -f "/home/sklein/.config/gopass/age/identities" ]; then
    if [ ! -f "/tmp/sklein-devbox-age-key" ]; then
        read -s -p "Enter AGE key: " AGE_KEY
        echo
    fi
    read -s -p "Enter AGE passphrase: " GOPASS_AGE_PASSWORD
    echo
    export GOPASS_AGE_PASSWORD

    if [ -f "/tmp/sklein-devbox-age-key" ]; then
        gopass age identities add "$(cat /tmp/sklein-devbox-age-key)"
    else
        gopass age identities add "${AGE_KEY}"
    fi
fi

# Gopass remote setup (if needed)
if [ "${SKLEIN_DEVBOX_GOPASS:-}" = "1" ] && [ ! -d "/home/sklein/.local/share/gopass/stores/root" ]; then
    if [ -f "/tmp/sklein-devbox-ssh-key" ]; then
        SSH_KEY_FILE=$(mktemp /home/sklein/.ssh/sklein-devbox-XXXXX)
        cat /tmp/sklein-devbox-ssh-key > "${SSH_KEY_FILE}"
        chmod 600 "${SSH_KEY_FILE}"
        export GIT_SSH_COMMAND="ssh -i ${SSH_KEY_FILE}"
    else
        export GIT_SSH_COMMAND="ssh -F /tmp/host-ssh/config"
    fi
    gopass --yes setup \
        --crypto age \
        --remote git@github.com:stephane-klein/sklein-devbox-secrets.git \
        --name "Stéphane Klein" \
        --email "contact@stephane-klein.info"
    unset GIT_SSH_COMMAND
fi

# Start gopass agent if needed
if [ "${SKLEIN_DEVBOX_GOPASS:-}" = "1" ] && [ ! -S "${XDG_RUNTIME_DIR}/gopass/gopass-age-agent.sock" ]; then
    mkdir -p "${XDG_RUNTIME_DIR}/gopass"
    gopass age agent start 1>/dev/null &
    sleep 0.5
fi

# Chezmoi init/apply
if [ ! -d "/home/sklein/.local/share/chezmoi" ]; then
    chezmoi init https://github.com/stephane-klein/sklein-devbox-chezmoi.git
fi

if [ ! -f "/home/sklein/.config/chezmoi/chezmoistate.boltdb" ]; then
    chezmoi apply
fi

unset GOPASS_AGE_PASSWORD

# Execute command directly (already running as sklein)
if [ $# -eq 0 ]; then
    exec /bin/zsh
else
    exec "$@"
fi
