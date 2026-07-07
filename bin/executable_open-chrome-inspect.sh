#!/bin/bash
IP="127.0.0.1"  # ou <ip-netbird>
WS=$(curl -s "http://$IP:9222/json" | jq -r '[.[] | select(.type=="page")][0].webSocketDebuggerUrl' | sed "s/localhost/$IP/;s|127.0.0.1|$IP|")
WS_PATH=$(echo "$WS" | sed 's|^ws://||')
xdg-open "http://$IP:9222/devtools/inspector.html?ws=$WS_PATH"
