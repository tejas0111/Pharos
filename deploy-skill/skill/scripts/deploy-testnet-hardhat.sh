#!/usr/bin/env bash
# Pharos Atlantic Testnet deployment script (Hardhat)
# Usage:
#   ./scripts/deploy-testnet-hardhat.sh                      # Deploy
#   DEPLOY_TAGS=upgrade ./scripts/deploy-testnet-hardhat.sh   # Deploy with tags
#   HARDHAT_NETWORK=pharosTestnet ./scripts/deploy-testnet-hardhat.sh
set -euo pipefail

# === Pharos Testnet Config ===
PHAROS_TESTNET_CHAIN_ID=688689

# === Env Vars (with .env support) ===
if [ -f .env ]; then
  set -a; source .env; set +a
fi
PHAROS_TESTNET_RPC_URL="${PHAROS_TESTNET_RPC_URL:-https://atlantic.dplabs-internal.com}"
: "${PRIVATE_KEY:?              Set PRIVATE_KEY (deployer private key, hex)}"

# === Optional Env Vars ===
DEPLOY_TAGS="${DEPLOY_TAGS:-deploy}"
HARDHAT_NETWORK="${HARDHAT_NETWORK:-pharosTestnet}"

# === Pre-flight: check for cast (Foundry) ===
if ! command -v cast &> /dev/null; then
  echo "WARNING: 'cast' not found. Skipping chain ID validation."
  echo "  Install Foundry: curl -L https://foundry.paradigm.xyz | bash"
  CHAIN_VALIDATION=0
else
  CHAIN_VALIDATION=1
fi

# === Pre-flight: validate chain ID ===
if [ "$CHAIN_VALIDATION" = "1" ]; then
  echo "--- Pre-flight: Checking chain ID ---"
  DETECTED_CHAIN_ID=$(cast chain-id --rpc-url "$PHAROS_TESTNET_RPC_URL" 2>/dev/null || echo "unreachable")
  if [ "$DETECTED_CHAIN_ID" != "$PHAROS_TESTNET_CHAIN_ID" ]; then
    echo "  ERROR: Expected chain ID $PHAROS_TESTNET_CHAIN_ID, got '$DETECTED_CHAIN_ID'"
    echo "  Check PHAROS_TESTNET_RPC_URL or target network."
    echo "  Pharos Atlantic Testnet RPC: https://atlantic.dplabs-internal.com (chain ID: $PHAROS_TESTNET_CHAIN_ID)"
    exit 1
  fi
  echo "  Chain ID: $DETECTED_CHAIN_ID ✓"
fi

# === Pre-flight: check deployer balance ===
if [ "$CHAIN_VALIDATION" = "1" ]; then
  echo "--- Pre-flight: Checking deployer balance ---"
  DEPLOYER_ADDR=$(cast wallet address --private-key "$PRIVATE_KEY" 2>/dev/null || echo "unknown")
  echo "  Deployer: $DEPLOYER_ADDR"
  BALANCE=$(cast balance --rpc-url "$PHAROS_TESTNET_RPC_URL" "$DEPLOYER_ADDR" 2>/dev/null || echo "0")
  echo "  Balance: $BALANCE (wei)"
  if [ "$BALANCE" = "0" ] || [ "$BALANCE" = "0 wei" ]; then
    echo "  WARNING: Deployer balance is 0. You may not have enough PHRS for gas."
    echo "  Get testnet PHRS from: https://testnet.pharosnetwork.xyz"
  fi
fi

# === Pre-flight: check Hardhat is installed ===
if ! command -v npx &> /dev/null; then
  echo "ERROR: npx not found. Install Node.js and npm first."
  exit 1
fi

if ! npx hardhat --version &> /dev/null; then
  echo "ERROR: Hardhat not found in this project. Run: npm install --save-dev hardhat"
  exit 1
fi

echo "--- Deploying to Pharos Atlantic Testnet (Hardhat) ---"
echo "  Network: $HARDHAT_NETWORK (chain ID: $PHAROS_TESTNET_CHAIN_ID)"
echo "  Tags: $DEPLOY_TAGS"
echo ""

exec npx hardhat deploy \
  --network "$HARDHAT_NETWORK" \
  --tags "$DEPLOY_TAGS" \
  "$@"
