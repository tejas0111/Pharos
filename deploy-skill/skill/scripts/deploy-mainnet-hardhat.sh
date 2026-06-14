#!/usr/bin/env bash
# Pharos Pacific Mainnet deployment script (Hardhat)
# Usage:
#   ./scripts/deploy-mainnet-hardhat.sh                      # Deploy
#   DEPLOY_TAGS=upgrade ./scripts/deploy-mainnet-hardhat.sh   # Deploy with tags
#   HARDHAT_NETWORK=pharosMainnet ./scripts/deploy-mainnet-hardhat.sh
set -euo pipefail

# === Pharos Mainnet Config ===
PHAROS_MAINNET_CHAIN_ID=1672

# === Env Vars (with .env support) ===
if [ -f .env ]; then
  set -a; source .env; set +a
fi
PHAROS_MAINNET_RPC_URL="${PHAROS_MAINNET_RPC_URL:-https://rpc.pharos.xyz}"
: "${PRIVATE_KEY:?              Set PRIVATE_KEY (deployer private key, hex)}"

# === Optional Env Vars ===
DEPLOY_TAGS="${DEPLOY_TAGS:-deploy}"
HARDHAT_NETWORK="${HARDHAT_NETWORK:-pharosMainnet}"
SIMULATE_ONLY="${SIMULATE_ONLY:-0}"

# === Pre-flight: confirm mainnet intent ===
echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!            PHAROS PACIFIC MAINNET DEPLOY            !!"
echo "!!  This will deploy a REAL contract with REAL value.  !!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""

# === Pre-flight: check for cast (Foundry) ===
if ! command -v cast &> /dev/null; then
  echo "WARNING: 'cast' not found. Skipping chain ID and balance checks."
  echo "  Install Foundry: curl -L https://foundry.paradigm.xyz | bash"
  CHAIN_VALIDATION=0
else
  CHAIN_VALIDATION=1
fi

# === Pre-flight: validate chain ID ===
if [ "$CHAIN_VALIDATION" = "1" ]; then
  echo "--- Pre-flight: Checking chain ID ---"
  DETECTED_CHAIN_ID=$(cast chain-id --rpc-url "$PHAROS_MAINNET_RPC_URL" 2>/dev/null || echo "unreachable")
  if [ "$DETECTED_CHAIN_ID" != "$PHAROS_MAINNET_CHAIN_ID" ]; then
    echo "  ERROR: Expected chain ID $PHAROS_MAINNET_CHAIN_ID, got '$DETECTED_CHAIN_ID'"
    echo "  Check PHAROS_MAINNET_RPC_URL or target network."
    echo "  Pharos Pacific Mainnet RPC: https://rpc.pharos.xyz (chain ID: $PHAROS_MAINNET_CHAIN_ID)"
    exit 1
  fi
  echo "  Chain ID: $DETECTED_CHAIN_ID ✓"
fi

# === Pre-flight: check deployer balance ===
if [ "$CHAIN_VALIDATION" = "1" ]; then
  echo "--- Pre-flight: Checking deployer balance ---"
  DEPLOYER_ADDR=$(cast wallet address --private-key "$PRIVATE_KEY" 2>/dev/null || echo "unknown")
  echo "  Deployer: $DEPLOYER_ADDR"
  BALANCE=$(cast balance --rpc-url "$PHAROS_MAINNET_RPC_URL" "$DEPLOYER_ADDR" 2>/dev/null || echo "0")
  echo "  Balance: $BALANCE (wei)"
  if [ "$BALANCE" = "0" ] || [ "$BALANCE" = "0 wei" ]; then
    echo "  ERROR: Deployer balance is 0. You need PROS for gas."
    exit 1
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

# === Build deploy command ===
DEPLOY_CMD=(npx hardhat deploy --network "$HARDHAT_NETWORK" --tags "$DEPLOY_TAGS")

# === Execute ===
if [[ "$SIMULATE_ONLY" == "1" ]]; then
  echo "--- SIMULATE ONLY: Showing what would be deployed ---"
  echo "  Network: $HARDHAT_NETWORK (chain ID: $PHAROS_MAINNET_CHAIN_ID)"
  echo "  RPC URL: $PHAROS_MAINNET_RPC_URL"
  echo "  Tags: $DEPLOY_TAGS"
  echo ""
  echo "To broadcast, run:"
  echo "  SIMULATE_ONLY=0 $0"
  echo "Or simply:"
  echo "  $0"
  echo ""
  echo "--- Simulation complete (no broadcast) ---"
  exit 0
fi

echo "--- Deploying to Pharos Pacific Mainnet (Hardhat) ---"
echo "  Network: $HARDHAT_NETWORK (chain ID: $PHAROS_MAINNET_CHAIN_ID)"
echo "  Tags: $DEPLOY_TAGS"
echo ""

exec "${DEPLOY_CMD[@]}" "$@"
