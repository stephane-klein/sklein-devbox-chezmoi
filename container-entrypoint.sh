#!/bin/sh
set -e

# Clean up stale sockets from previous container stop
rm -f /tmp/user/1000/gopass/gopass-age-agent.sock
rm -f /tmp/ssh-agent.sock

# Run one-time initialization scripts
for script in /etc/entrypoint-init.d/*; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        "$script"
    fi
done

export PITCHFORK_STATE_DIR="/run/pitchfork-state/"
sudo mkdir -m 777 -p $PITCHFORK_STATE_DIR
pitchfork supervisor run --container --boot
