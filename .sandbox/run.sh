#!/usr/bin/env bash
# Start (or reopen) the workspace sandbox with the workspace kits attached.
# Usage: .sandbox/run.sh [name]   (default name: monorepo)
set -euo pipefail

name="${1:-"base-template"}"
cd "$(dirname "$0")/.."

if sbx ls | awk -v n="$name" '$1 == n { found = 1 } END { exit !found }'; then
  exec sbx run --name "$name"
fi

# v3 kits need exactly one workload kit plus any mixins; the built-in "claude"
# agent is not a v3 kit, so it cannot fill that role. Docker's published Claude
# workload kit does, pinned to a tag.
claude_kit="docker.io/docker/sbx-kit-claude:2.1.316"

exec sbx run "$claude_kit" --name "$name" \
  --kit ./.sandbox/mise \
  --kit ./.sandbox/network-policy
