#!/usr/bin/env bash
set -euo pipefail

: "${PHAROS_TESTNET_RPC_URL:?Set PHAROS_TESTNET_RPC_URL}"
: "${PRIVATE_KEY:?Set PRIVATE_KEY}"

SCRIPT_TARGET="${SCRIPT_TARGET:-script/Deploy.s.sol:Deploy}"
SIMULATE_ONLY="${SIMULATE_ONLY:-0}"
VERIFY="${VERIFY:-0}"

cmd=(
  forge
  script
  "$SCRIPT_TARGET"
  --rpc-url "$PHAROS_TESTNET_RPC_URL"
  --private-key "$PRIVATE_KEY"
)

if [[ "$SIMULATE_ONLY" != "1" ]]; then
  cmd+=(--broadcast)
fi

if [[ "$VERIFY" == "1" ]]; then
  : "${ETHERSCAN_API_KEY:?Set ETHERSCAN_API_KEY when VERIFY=1}"
  cmd+=(--verify --etherscan-api-key "$ETHERSCAN_API_KEY")
fi

cmd+=("$@")
exec "${cmd[@]}"
