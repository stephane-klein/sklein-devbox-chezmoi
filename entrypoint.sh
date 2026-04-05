#!/bin/bash
set -e

HOST_UID=$(stat -c %u /workspace 2>/dev/null || echo 1000)

if [ "$HOST_UID" != "1000" ]; then
    usermod -u "$HOST_UID" sklein
    groupmod -g "$HOST_UID" sklein
fi

# Setup XDG_RUNTIME_DIR
USER_UID=$(id -u sklein)
XDG_RUNTIME_DIR="/tmp/user/${USER_UID}"
mkdir -p "${XDG_RUNTIME_DIR}"
chmod 700 "${XDG_RUNTIME_DIR}"
chown sklein:sklein "${XDG_RUNTIME_DIR}"
export XDG_RUNTIME_DIR

mkdir -p /home/sklein/.config/gopass/age/
chown -R sklein:sklein /home/sklein/.config/gopass/age/

export GPG_TTY=$(tty)

if [ ! -f "/home/sklein/.config/gopass/age/identities" ]; then
    if [ ! -f "/tmp/sklein-devbox-age-key" ]; then
        read -s -p "Enter AGE key: " AGE_KEY
        echo
    fi
    read -s -p "Enter AGE passphrase: " GOPASS_AGE_PASSWORD
    echo
    export GOPASS_AGE_PASSWORD

    if [ -f "/tmp/sklein-devbox-age-key" ]; then
        gosu sklein gopass age identities add "$(cat /tmp/sklein-devbox-age-key)"
    else
        gosu sklein gopass age identities add "${AGE_KEY}"
    fi
fi

# Clone secrets repository if --gopass enabled and not already cloned
if [ "${SKLEIN_DEVBOX_GOPASS:-}" = "1" ] && [ ! -d "/home/sklein/.local/share/gopass/stores/root" ]; then
    mkdir -p /home/sklein/.ssh
    ssh-keyscan github.com >> /home/sklein/.ssh/known_hosts 2>/dev/null
    chown -R sklein:sklein /home/sklein/.ssh

    if [ -f "/tmp/sklein-devbox-ssh-key" ]; then
        SSH_KEY_FILE=$(mktemp /home/sklein/.ssh/sklein-devbox-XXXXX)
        cat /tmp/sklein-devbox-ssh-key > "${SSH_KEY_FILE}"
        chmod 600 "${SSH_KEY_FILE}"
        chown sklein:sklein "${SSH_KEY_FILE}"
        export GIT_SSH_COMMAND="ssh -i ${SSH_KEY_FILE}"
    else
        echo "Enter SSH private key content (Ctrl+D to finish):"
        SSH_KEY_CONTENT=$(cat)
        if [ -n "${SSH_KEY_CONTENT}" ]; then
            SSH_KEY_FILE=$(mktemp)
            echo "${SSH_KEY_CONTENT}" > "${SSH_KEY_FILE}"
            chmod 600 "${SSH_KEY_FILE}"
            chown sklein:sklein "${SSH_KEY_FILE}"
            export GIT_SSH_COMMAND="ssh -i ${SSH_KEY_FILE}"
        fi
    fi
    gosu sklein gopass --yes setup \
        --crypto age \
        --remote git@github.com:stephane-klein/sklein-devbox-secrets.git \
        --name "Stéphane Klein" \
        --email "contact@stephane-klein.info"

    unset GIT_SSH_COMMAND
fi

# Start gopass age agent if enabled and configured
if [ "${SKLEIN_DEVBOX_GOPASS:-}" = "1" ] && [ -d "/home/sklein/.config/gopass" ]; then
    AGENT_SOCKET="${XDG_RUNTIME_DIR}/gopass/gopass-age-agent.sock"

    if [ -S "${AGENT_SOCKET}" ]; then
        echo "gopass age agent already running"
    else
        mkdir -p "$(dirname "${AGENT_SOCKET}")"
        chown sklein:sklein "$(dirname "${AGENT_SOCKET}")"

        gosu sklein gopass age agent start 1>/dev/null &
        sleep 0.5
    fi
fi

if [ ! -d "/home/sklein/.local/share/chezmoi" ]; then
    gosu sklein chezmoi init https://github.com/stephane-klein/sklein-devbox-chezmoi.git
fi

if [ ! -f "/home/sklein/.config/chezmoi/chezmoistate.boltdb" ]; then
    gosu sklein chezmoi apply
fi

unset GOPASS_AGE_PASSWORD

exec gosu sklein "$@"
