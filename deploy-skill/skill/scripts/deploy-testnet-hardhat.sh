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
