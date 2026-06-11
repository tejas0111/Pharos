#!/usr/bin/env bash
# Verify a deployed contract on Pharos Atlantic Testnet explorer (Hardhat)
# Usage:
#   DEPLOYED_ADDRESS=0x123... ./scripts/verify-testnet-hardhat.sh
#   DEPLOYED_ADDRESS=0x123... HARDHAT_NETWORK=pharosTestnet ./scripts/verify-testnet-hardhat.sh
set -euo pipefail

# === Pharos Testnet Config ===
PHAROS_TESTNET_CHAIN_ID=688689

# === Required Env Vars ===
: "${PHAROS_TESTNET_RPC_URL:?  Set PHAROS_TESTNET_RPC_URL}"
: "${DEPLOYED_ADDRESS:?        Set DEPLOYED_ADDRESS to the contract address to verify}"

# === Optional Env Vars ===
HARDHAT_NETWORK="${HARDHAT_NETWORK:-pharosTestnet}"

echo "--- Verifying contract on Pharos Atlantic Testnet ---"
echo "  Contract: $DEPLOYED_ADDRESS"
echo "  Explorer: https://atlantic.pharosscan.xyz/address/$DEPLOYED_ADDRESS"
echo ""

exec npx hardhat verify \
  --network "$HARDHAT_NETWORK" \
  "$DEPLOYED_ADDRESS" \
  "$@"
