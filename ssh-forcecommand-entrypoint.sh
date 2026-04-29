#!/bin/bash

touch /home/sklein/.zshrc

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
        if [ -n "$TMUX" ]; then
            local tmux_socket="${TMUX%,*}"
            if [ -S "$tmux_socket" ] 2>/dev/null; then
                tmux -S "$tmux_socket" kill-server 2>/dev/null || true
            else
                tmux kill-server 2>/dev/null || true
            fi
        fi
        exit 0
    }
    trap cleanup_tmux HUP TERM INT
fi

# Run idempotent initialization unless disabled
if [ "${SKLEIN_DEVBOX_DISABLE_INIT:-}" != "1" ]; then
    /usr/local/bin/sklein-devbox-init.sh || true
else
    echo "Note: Automatic initialization is disabled."
    echo "You can run 'sklein-devbox-init.sh' manually to set up gopass, chezmoi, and other configurations."
fi

# Start gopass agent service if enabled and not already running
if [ "${SKLEIN_DEVBOX_GOPASS:-}" = "1" ]; then
    if [ ! -S "${XDG_RUNTIME_DIR}/gopass/gopass-age-agent.sock" ]; then
        rm -f "${XDG_RUNTIME_DIR}/gopass/gopass-age-agent.sock"
        s6-svc -u /run/service/gopass-agent 2>/dev/null || true
        sleep 0.5
    fi
fi

# Start gpg-agent service if configuration exists
if [ -f "$HOME/.config/gnupg/gpg-agent.conf" ]; then
    s6-svc -u /run/service/gpg-agent 2>/dev/null || true
fi

# Execute command directly (already running as sklein)
if [ -n "$SSH_ORIGINAL_COMMAND" ]; then
    exec /bin/zsh -i -c "$SSH_ORIGINAL_COMMAND"
elif [ $# -eq 0 ]; then
    exec /bin/zsh
else
    exec "$@"
fi
