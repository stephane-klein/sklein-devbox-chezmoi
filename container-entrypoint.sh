#!/bin/sh
set -e

# Clean up stale gopass-agent socket from previous container stop
# (gopass starts its agent on-demand, the socket may be stale)
rm -f /tmp/user/1000/gopass/gopass-age-agent.sock

# Run one-time initialization scripts
for script in /etc/entrypoint-init.d/*; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        "$script"
    fi
done

export PEBBLE=/var/lib/pebble
exec /usr/local/bin/pebble run