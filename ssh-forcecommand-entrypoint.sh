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

# Trap for graceful tmux shutdown when sshd dies (SIGHUP) or receives SIGTERM
# Only for interactive sessions (not healthcheck)
if [ -z "$SSH_ORIGINAL_COMMAND" ] || [ "$SSH_ORIGINAL_COMMAND" = "/bin/zsh" ] || [ "$SSH_ORIGINAL_COMMAND" = "/bin/bash" ]; then
    cleanup_tmux() {
        # Gracefully kill the tmux server of THIS session only
        if [ -n "$TMUX" ]; then
            # TMUX contains "socket,pid" - extract the socket path
            local tmux_socket="${TMUX%,*}"
            if [ -S "$tmux_socket" ] 2>/dev/null; then
                tmux -S "$tmux_socket" kill-server 2>/dev/null || true
            else
                # Fallback: kill by default socket
                tmux kill-server 2>/dev/null || true
            fi
        fi
        exit 0
    }
    trap cleanup_tmux HUP TERM INT
fi

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

# Start gopass agent service if enabled and not already running
if [ "${SKLEIN_DEVBOX_GOPASS:-}" = "1" ]; then
    if [ ! -S "${XDG_RUNTIME_DIR}/gopass/gopass-age-agent.sock" ]; then
        # Clean up stale socket if exists
        rm -f "${XDG_RUNTIME_DIR}/gopass/gopass-age-agent.sock"
        # Start the s6 service for gopass agent
        s6-svc -u /run/service/gopass-agent 2>/dev/null || true
        sleep 0.5
    fi
fi

# Chezmoi init/apply
if [ ! -d "/home/sklein/.local/share/chezmoi" ]; then
    chezmoi init git@github.com:stephane-klein/sklein-devbox-chezmoi.git
fi

if [ ! -f "/home/sklein/.config/chezmoi/chezmoistate.boltdb" ]; then
    chezmoi apply
fi

# Start gpg-agent service if configuration exists
if [ -f "$HOME/.config/gnupg/gpg-agent.conf" ]; then
    s6-svc -u /run/service/gpg-agent 2>/dev/null || true
fi

unset GOPASS_AGE_PASSWORD

# Execute command directly (already running as sklein)
# SSH_ORIGINAL_COMMAND contains the command passed via SSH when ForceCommand is used
if [ -n "$SSH_ORIGINAL_COMMAND" ]; then
    # Execute the original SSH command
    exec /bin/zsh -i -c "$SSH_ORIGINAL_COMMAND"
elif [ $# -eq 0 ]; then
    exec /bin/zsh
else
    exec "$@"
fi
