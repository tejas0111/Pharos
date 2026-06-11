#!/usr/bin/env bash
set -euo pipefail

: "${PHAROS_MAINNET_RPC_URL:?Set PHAROS_MAINNET_RPC_URL}"
: "${DEPLOYED_ADDRESS:?Set DEPLOYED_ADDRESS}"

cmd=(
  npx
  hardhat
  verify
  --network
  "${HARDHAT_NETWORK:-pharosMainnet}"
  "$DEPLOYED_ADDRESS"
)

cmd+=("$@")
exec "${cmd[@]}"
