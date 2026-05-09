#!/usr/bin/env bash
set -euo pipefail

token=$(gopass show github-cli/token)
gh auth login --with-token <<< "$token"