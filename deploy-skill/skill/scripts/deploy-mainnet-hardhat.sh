#!/usr/bin/env bash
set -euo pipefail

: "${PHAROS_MAINNET_RPC_URL:?Set PHAROS_MAINNET_RPC_URL}"
: "${PRIVATE_KEY:?Set PRIVATE_KEY}"

DEPLOY_TAGS="${DEPLOY_TAGS:-deploy}"

cmd=(
  npx
  hardhat
  deploy
  --network
  "${HARDHAT_NETWORK:-pharosMainnet}"
  --tags
  "$DEPLOY_TAGS"
)

cmd+=("$@")
exec "${cmd[@]}"
