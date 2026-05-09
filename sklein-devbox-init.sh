#!/bin/bash

INIT_DIR="${HOME}/.local/share/sklein-devbox/init-steps"
mkdir -p "${INIT_DIR}"
WELCOME_SHOWN_FILE="${INIT_DIR}/welcome-shown"

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/user/$(id -u)}"

FORCE=0
STATUS=0

while [ $# -gt 0 ]; do
    case "$1" in
        --force) FORCE=1 ;;
        --status) STATUS=1 ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: sklein-devbox-init.sh [--force] [--status]"
            exit 1
            ;;
    esac
    shift
done

# Setup SSH for git operations (used by both gopass setup and chezmoi init)
SSH_KEY_FILE=""
if [ -f "/tmp/sklein-devbox-ssh-key" ]; then
    mkdir -p /home/sklein/.ssh
    SSH_KEY_FILE=$(mktemp /home/sklein/.ssh/sklein-devbox-XXXXX)
    cat /tmp/sklein-devbox-ssh-key > "${SSH_KEY_FILE}"
    chmod 600 "${SSH_KEY_FILE}"
    export GIT_SSH_COMMAND="ssh -i ${SSH_KEY_FILE}"
else
    export GIT_SSH_COMMAND="ssh -F /tmp/host-ssh/config"
fi

# Cleanup function for trap - removes SSH key file and unsets env var on exit
cleanup_ssh() {
    unset GIT_SSH_COMMAND
    if [ -n "${SSH_KEY_FILE}" ] && [ -f "${SSH_KEY_FILE}" ]; then
        rm -f "${SSH_KEY_FILE}"
    fi
}
trap cleanup_ssh EXIT

if [ "${FORCE}" = "1" ]; then
    rm -f "${WELCOME_SHOWN_FILE}"
fi

WELCOME_ALREADY_SHOWN=0
if [ -f "${WELCOME_SHOWN_FILE}" ]; then
    WELCOME_ALREADY_SHOWN=1
fi

show_step_status() {
    [ -f "${INIT_DIR}/gopass-identities.done" ] && echo "[init] gopass-identities: done" || echo "[init] gopass-identities: pending"
    [ -f "${INIT_DIR}/gopass-store.done" ]     && echo "[init] gopass-store: done"     || echo "[init] gopass-store: pending"
    [ -f "${INIT_DIR}/chezmoi-init.done" ]     && echo "[init] chezmoi-init: done"     || echo "[init] chezmoi-init: pending"
    [ -f "${INIT_DIR}/chezmoi-apply.done" ]    && echo "[init] chezmoi-apply: done"    || echo "[init] chezmoi-apply: pending"
}

if [ "${STATUS}" = "1" ]; then
    show_step_status
    exit 0
fi

if [ "${FORCE}" = "1" ]; then
    rm -f "${INIT_DIR}/gopass-identities.done"
    rm -f "${INIT_DIR}/gopass-store.done"
    rm -f "${INIT_DIR}/chezmoi-init.done"
    rm -f "${INIT_DIR}/chezmoi-apply.done"
fi

# Show current status at the beginning of normal execution
if [ "${WELCOME_ALREADY_SHOWN}" = "0" ]; then
    show_step_status
fi

# Step 1: gopass age identities
if [ ! -f "${INIT_DIR}/gopass-identities.done" ]; then
    echo "[init] Setting up gopass age identities..."

    # Check if identities file exists and test it with passphrase
    if [ -f "${HOME}/.config/gopass/age/identities" ] && [ -s "${HOME}/.config/gopass/age/identities" ]; then
        read -s -p "Enter AGE passphrase: " GOPASS_AGE_PASSWORD
        echo
        export GOPASS_AGE_PASSWORD

        if gopass age identities list >/dev/null 2>&1; then
            touch "${INIT_DIR}/gopass-identities.done"
        else
            echo "[init] Incorrect passphrase. Please run skleni-devbox-init.sh to start over."
            exit 1
        fi
    fi

    if [ ! -f "${INIT_DIR}/gopass-identities.done" ]; then
        # Either no identities file, or the passphrase didn't work
        if [ -f "/tmp/sklein-devbox-age-key" ]; then
            # Only ask for passphrase if not already asked above
            if [ -z "${GOPASS_AGE_PASSWORD}" ]; then
                read -s -p "Enter AGE passphrase: " GOPASS_AGE_PASSWORD
                echo
                export GOPASS_AGE_PASSWORD
            fi
            gopass age identities add "$(cat /tmp/sklein-devbox-age-key)"
        else
            read -s -p "Enter AGE key: " AGE_KEY
            echo
            read -s -p "Enter AGE passphrase: " GOPASS_AGE_PASSWORD
            echo
            export GOPASS_AGE_PASSWORD
            gopass age identities add "${AGE_KEY}"
        fi

        if [ $? -eq 0 ]; then
            touch "${INIT_DIR}/gopass-identities.done"
        else
            echo "WARNING: sklein-devbox-init.sh failed at step 'gopass-identities'."
            echo "This step will be retried automatically on next connection."
            echo "Run 'sklein-devbox-init.sh' to retry now, or 'sklein-devbox-init.sh --force' to restart ALL steps from scratch."
            exit 1
        fi
    fi
fi

# Step 2: gopass remote store
if [ ! -f "${INIT_DIR}/gopass-store.done" ]; then
    if [ "${SKLEIN_DEVBOX_GOPASS:-}" = "1" ]; then
        echo "[init] Setting up gopass remote store..."

        if [ -d "${HOME}/.local/share/gopass/stores/root" ]; then
            if gopass ls >/dev/null 2>&1; then
                touch "${INIT_DIR}/gopass-store.done"
            else
                echo "[init] Existing store is invalid, removing..."
                rm -rf "${HOME}/.local/share/gopass/stores/root"
            fi
        fi

        if [ ! -f "${INIT_DIR}/gopass-store.done" ]; then
            gopass --yes setup \
                --crypto age \
                --remote git@github.com:stephane-klein/sklein-devbox-secrets.git \
                --name "Stéphane Klein" \
                --email "contact@stephane-klein.info"

            if [ $? -eq 0 ]; then
                touch "${INIT_DIR}/gopass-store.done"
            else
                echo "WARNING: sklein-devbox-init.sh failed at step 'gopass-store'."
                echo "This step will be retried automatically on next connection."
                echo "Run 'sklein-devbox-init.sh' to retry now, or 'sklein-devbox-init.sh --force' to restart ALL steps from scratch."
                exit 1
            fi
        fi
    else
        touch "${INIT_DIR}/gopass-store.done"
    fi
fi

# Step 3: chezmoi init
if [ ! -f "${INIT_DIR}/chezmoi-init.done" ]; then
    echo "[init] Initializing chezmoi..."

    if [ -d "${HOME}/.local/share/chezmoi/.git" ] || [ -d "${HOME}/.local/share/chezmoi/.jj" ]; then
        touch "${INIT_DIR}/chezmoi-init.done"
    else
        chezmoi init git@github.com:stephane-klein/sklein-devbox-chezmoi.git

        if [ $? -eq 0 ]; then
            touch "${INIT_DIR}/chezmoi-init.done"
        else
            echo "WARNING: sklein-devbox-init.sh failed at step 'chezmoi-init'."
            echo "This step will be retried automatically on next connection."
            echo "Run 'sklein-devbox-init.sh' to retry now, or 'sklein-devbox-init.sh --force' to restart ALL steps from scratch."
            exit 1
        fi
    fi
fi

# Step 4: chezmoi apply
if [ ! -f "${INIT_DIR}/chezmoi-apply.done" ]; then
    echo "[init] Applying chezmoi configuration..."

    # Prevent zsh new user install prompt by creating a dummy .zshrc
    # This will be overwritten by chezmoi apply with the real config
    if [ ! -f "${HOME}/.zshrc" ]; then
        touch "${HOME}/.zshrc"
    fi

    chezmoi apply

    ~/bin/update-zsh-completions.sh

    if [ $? -eq 0 ]; then
        touch "${INIT_DIR}/chezmoi-apply.done"
    else
        echo "WARNING: sklein-devbox-init.sh failed at step 'chezmoi-apply'."
        echo "This step will be retried automatically on next connection."
        echo "Run 'sklein-devbox-init.sh' to retry now, or 'sklein-devbox-init.sh --force' to restart ALL steps from scratch."
        exit 1
    fi
fi

# Show hint only when welcome has not been shown yet
if [ "${WELCOME_ALREADY_SHOWN}" = "0" ]; then
    echo ""
    echo "Hint: To re-run a specific step, remove its .done file:"
    echo "      rm ${INIT_DIR}/<step-name>.done"
    echo "      To re-run all steps from scratch, use: sklein-devbox-init.sh --force"
fi

# Suggest reloading shell when run manually
if [ -z "${SKLEIN_DEVBOX_AUTO_INIT:-}" ]; then
    echo "[init] Run 'exec zsh' to reload your shell configuration."
fi

# Create welcome-shown marker only when all steps are completed
if [ -f "${INIT_DIR}/gopass-identities.done" ] && [ -f "${INIT_DIR}/gopass-store.done" ] && [ -f "${INIT_DIR}/chezmoi-init.done" ] && [ -f "${INIT_DIR}/chezmoi-apply.done" ]; then
    touch "${WELCOME_SHOWN_FILE}"
fi
