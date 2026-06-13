#!/usr/bin/env bash
# Verify a deployed contract on Pharos Pacific Mainnet explorer (Hardhat)
# Usage:
#   DEPLOYED_ADDRESS=0x123... ./scripts/verify-mainnet-hardhat.sh
#   DEPLOYED_ADDRESS=0x123... HARDHAT_NETWORK=pharosMainnet ./scripts/verify-mainnet-hardhat.sh
set -euo pipefail

# === Pharos Mainnet Config ===
PHAROS_MAINNET_CHAIN_ID=1672

# === Env Vars (with .env support) ===
if [ -f .env ]; then
  set -a; source .env; set +a
fi
: "${PHAROS_MAINNET_RPC_URL:?  Set PHAROS_MAINNET_RPC_URL}"
: "${DEPLOYED_ADDRESS:?        Set DEPLOYED_ADDRESS to the contract address to verify}"

# === Optional Env Vars ===
HARDHAT_NETWORK="${HARDHAT_NETWORK:-pharosMainnet}"

echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!         VERIFYING ON PHAROS PACIFIC MAINNET         !!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""
echo "--- Verifying contract on Pharos Pacific Mainnet ---"
echo "  Contract: $DEPLOYED_ADDRESS"
echo "  Explorer: https://www.pharosscan.xyz/address/$DEPLOYED_ADDRESS"
echo ""

exec npx hardhat verify \
  --network "$HARDHAT_NETWORK" \
  "$DEPLOYED_ADDRESS" \
  "$@"
