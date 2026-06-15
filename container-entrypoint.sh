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

export PEBBLE=/var/lib/pebble
exec /usr/local/bin/pebble run