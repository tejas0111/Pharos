#!/usr/bin/env bash
# Pharos Pacific Mainnet deployment script (Hardhat)
# Usage:
#   ./scripts/deploy-mainnet-hardhat.sh                      # Deploy
#   DEPLOY_TAGS=upgrade ./scripts/deploy-mainnet-hardhat.sh   # Deploy with tags
#   HARDHAT_NETWORK=pharosMainnet ./scripts/deploy-mainnet-hardhat.sh
set -euo pipefail

# === Pharos Mainnet Config ===
PHAROS_MAINNET_CHAIN_ID=1672

# === Required Env Vars ===
: "${PHAROS_MAINNET_RPC_URL:?  Set PHAROS_MAINNET_RPC_URL (default: https://rpc.pharos.xyz)}"
: "${PRIVATE_KEY:?              Set PRIVATE_KEY (deployer private key, hex)}"

# === Optional Env Vars ===
DEPLOY_TAGS="${DEPLOY_TAGS:-deploy}"
HARDHAT_NETWORK="${HARDHAT_NETWORK:-pharosMainnet}"

# === Pre-flight: confirm mainnet intent ===
echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!            PHAROS PACIFIC MAINNET DEPLOY            !!"
echo "!!  This will deploy a REAL contract with REAL value.  !!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""

# === Pre-flight: check Hardhat is installed ===
if ! command -v npx &> /dev/null; then
  echo "ERROR: npx not found. Install Node.js and npm first."
  exit 1
fi

if ! npx hardhat --version &> /dev/null; then
  echo "ERROR: Hardhat not found in this project. Run: npm install --save-dev hardhat"
  exit 1
fi

echo "--- Deploying to Pharos Pacific Mainnet (Hardhat) ---"
echo "  Network: $HARDHAT_NETWORK (chain ID: $PHAROS_MAINNET_CHAIN_ID)"
echo "  Tags: $DEPLOY_TAGS"
echo ""

exec npx hardhat deploy \
  --network "$HARDHAT_NETWORK" \
  --tags "$DEPLOY_TAGS" \
  "$@"
