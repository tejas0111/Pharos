#!/usr/bin/env bash
set -euo pipefail

: "${PHAROS_TESTNET_RPC_URL:?Set PHAROS_TESTNET_RPC_URL}"
: "${DEPLOYED_ADDRESS:?Set DEPLOYED_ADDRESS}"

cmd=(
  npx
  hardhat
  verify
  --network
  "${HARDHAT_NETWORK:-pharosTestnet}"
  "$DEPLOYED_ADDRESS"
)

cmd+=("$@")
exec "${cmd[@]}"
