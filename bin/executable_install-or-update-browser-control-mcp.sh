#!/usr/bin/env bash
# ~/bin/install-or-update-browser-control-mcp.sh
set -euo pipefail

INSTALL_DIR="${HOME}/.local/share/browser-control-mcp"
SERVER_DIR="${INSTALL_DIR}/mcp-server"
REPO_URL="https://github.com/eyalzh/browser-control-mcp.git"

echo "=== Install or update browser-control-mcp ==="

rm -rf "${INSTALL_DIR}"

echo "Cloning ${REPO_URL}..."
git clone --depth 1 "${REPO_URL}" "${INSTALL_DIR}"

echo "Removing .git..."
rm -rf "${INSTALL_DIR}/.git"

echo "Installing npm dependencies..."
(cd "${SERVER_DIR}" && npm install)

echo "Building TypeScript..."
(cd "${SERVER_DIR}" && npm run build)

echo "=== Done ==="
echo "Server compiled at: ${SERVER_DIR}/dist/server.js"
