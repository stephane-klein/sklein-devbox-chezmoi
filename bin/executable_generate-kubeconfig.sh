#!/usr/bin/env bash
# ~/bin/generate-kubeconfig.sh
set -euo pipefail

ENTRIES=(
  "homelab/k3s.kubeconfig"
)

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

KUBECONFIG_FILES=()
for entry in "${ENTRIES[@]}"; do
  file="$TMPDIR/$(echo "$entry" | tr '/' '-')"
  if ! gopass show "$entry" > "$file" 2>/dev/null; then
    echo "Warning: gopass entry '$entry' not found, skipping" >&2
    continue
  fi
  KUBECONFIG_FILES+=("$file")
done

if [ ${#KUBECONFIG_FILES[@]} -eq 0 ]; then
  echo "No kubeconfig entries found in gopass" >&2
  exit 1
fi

mkdir -p "$HOME/.kube"

KCFG=$(IFS=:; echo "${KUBECONFIG_FILES[*]}")
KUBECONFIG="$KCFG" kubectl config view --flatten > "$HOME/.kube/config"

echo "Wrote $HOME/.kube/config (${#KUBECONFIG_FILES[@]} source(s))"
