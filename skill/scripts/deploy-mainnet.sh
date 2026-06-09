#!/usr/bin/env bash
# Pharos Pacific Mainnet deployment script (Foundry)
# Usage:
#   SIMULATE_ONLY=1 ./scripts/deploy-mainnet.sh         # Simulate only
#   ./scripts/deploy-mainnet.sh                           # Deploy
#   VERIFY=1 ./scripts/deploy-mainnet.sh                  # Deploy + verify
#   SCRIPT_TARGET=script/MyDeploy.s.sol:MyDeploy ./scripts/deploy-mainnet.sh
set -euo pipefail

# === Source .env if present ===
if [ -f .env ]; then
  set -a; source .env; set +a
fi

# === Pharos Mainnet Config ===
PHAROS_MAINNET_CHAIN_ID=1672

# === Dependency checks ===
for cmd in cast forge; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "ERROR: '$cmd' not found. Install Foundry: curl -L https://foundry.paradigm.xyz | bash"
    exit 1
  fi
done

# === Required Env Vars ===
PHAROS_MAINNET_RPC_URL="${PHAROS_MAINNET_RPC_URL:-https://rpc.pharos.xyz}"
: "${PRIVATE_KEY:?              Set PRIVATE_KEY in .env (deployer private key, hex with or without 0x)}"

# === Optional Env Vars ===
SCRIPT_TARGET="${SCRIPT_TARGET:-script/Deploy.s.sol:Deploy}"
SIMULATE_ONLY="${SIMULATE_ONLY:-0}"
VERIFY="${VERIFY:-0}"

# === Pre-flight: confirm mainnet intent ===
echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!            PHAROS PACIFIC MAINNET DEPLOY            !!"
echo "!!  This will deploy a REAL contract with REAL value.  !!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""

# === Pre-flight: validate chain ID ===
echo "--- Pre-flight: Checking chain ID ---"
DETECTED_CHAIN_ID=$(cast chain-id --rpc-url "$PHAROS_MAINNET_RPC_URL" 2>/dev/null || echo "unreachable")
if [ "$DETECTED_CHAIN_ID" != "$PHAROS_MAINNET_CHAIN_ID" ]; then
  echo "  ERROR: Expected chain ID $PHAROS_MAINNET_CHAIN_ID, got '$DETECTED_CHAIN_ID'"
  echo "  Check PHAROS_MAINNET_RPC_URL or target network."
  echo "  Pharos Pacific Mainnet RPC: https://rpc.pharos.xyz (chain ID: $PHAROS_MAINNET_CHAIN_ID)"
  exit 1
fi
echo "  Chain ID: $DETECTED_CHAIN_ID ✓"

# === Pre-flight: check deployer balance ===
echo "--- Pre-flight: Checking deployer balance ---"
DEPLOYER_ADDR=$(cast wallet address --private-key "$PRIVATE_KEY" 2>/dev/null || echo "unknown")
echo "  Deployer: $DEPLOYER_ADDR"
BALANCE=$(cast balance --rpc-url "$PHAROS_MAINNET_RPC_URL" "$DEPLOYER_ADDR" 2>/dev/null || echo "0")
echo "  Balance: $BALANCE (wei)"
if [ "$BALANCE" = "0" ] || [ "$BALANCE" = "0 wei" ]; then
  echo "  ERROR: Deployer balance is 0. You need PROS for gas."
  exit 1
fi

# === Build command ===
cmd=(
  forge
  script
  "$SCRIPT_TARGET"
  --rpc-url "$PHAROS_MAINNET_RPC_URL"
  --private-key "$PRIVATE_KEY"
)

if [[ "$SIMULATE_ONLY" != "1" ]]; then
  cmd+=(--broadcast)
fi

if [[ "$VERIFY" == "1" ]]; then
  : "${ETHERSCAN_API_KEY:?  Set ETHERSCAN_API_KEY when VERIFY=1}"
  cmd+=(--verify --etherscan-api-key "$ETHERSCAN_API_KEY")
fi

cmd+=("$@")

# === Execute ===
if [[ "$SIMULATE_ONLY" == "1" ]]; then
  echo "--- Running simulation only (no broadcast) ---"
else
  echo "--- Broadcasting deployment to Pharos Pacific Mainnet ---"
fi
exec "${cmd[@]}"
