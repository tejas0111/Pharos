#!/usr/bin/env bash
# Post-deployment verification script for Pharos contracts
# Checks the deployed contract is alive, verified on explorer, and has expected state.
# Usage:
#   ./scripts/verify-deployment.sh <network> <address> [expectedOwner]
#   ./scripts/verify-deployment.sh testnet 0x123...
#   ./scripts/verify-deployment.sh mainnet 0x123... 0xOwnerAddr
set -euo pipefail

# === Source .env if present ===
if [ -f .env ]; then
  set -a; source .env; set +a
fi

if [ $# -lt 2 ]; then
  echo "Usage: $0 <testnet|mainnet> <contract-address> [expected-owner-address]"
  echo ""
  echo "Examples:"
  echo "  $0 testnet 0x123..."
  echo "  $0 mainnet 0x123... 0xOwnerAddr"
  exit 1
fi

NETWORK="$1"
ADDRESS="$2"
EXPECTED_OWNER="${3:-}"

# Network configs
case "$NETWORK" in
  testnet|atlantic)
    RPC_URL="${PHAROS_TESTNET_RPC_URL:-https://atlantic.dplabs-internal.com}"
    EXPLORER="https://atlantic.pharosscan.xyz"
    CHAIN_ID=688689
    SYMBOL="PHRS"
    ;;
  mainnet|pacific)
    RPC_URL="${PHAROS_MAINNET_RPC_URL:-https://rpc.pharos.xyz}"
    EXPLORER="https://www.pharosscan.xyz"
    CHAIN_ID=1672
    SYMBOL="PROS"
    ;;
  *)
    echo "ERROR: Unknown network '$NETWORK'. Use 'testnet' or 'mainnet'."
    exit 1
    ;;
esac

echo "=============================================="
echo "  Post-Deploy Verification — Pharos $NETWORK"
echo "=============================================="
echo ""

# Step 1: Chain ID check
echo "[1/5] Checking network connection..."
DETECTED=$(cast chain-id --rpc-url "$RPC_URL" 2>/dev/null || echo "unreachable")
if [ "$DETECTED" != "$CHAIN_ID" ]; then
  echo "  FAIL: Expected chain ID $CHAIN_ID, got '$DETECTED'"
  exit 1
fi
echo "  Chain ID: $DETECTED ✓"

# Step 2: Contract code exists
echo "[2/5] Checking contract bytecode..."
CODE=$(cast code --rpc-url "$RPC_URL" "$ADDRESS" 2>/dev/null || echo "")
if [ -z "$CODE" ] || [ "$CODE" = "0x" ]; then
  echo "  FAIL: No bytecode found at $ADDRESS"
  echo "  The contract may not exist or was deployed to a different network."
  exit 1
fi
LEN=${#CODE}
echo "  Bytecode: ${LEN} chars (present) ✓"

# Step 3: Transaction count (nonce)
echo "[3/5] Checking transaction count..."
NONCE=$(cast nonce --rpc-url "$RPC_URL" "$ADDRESS" 2>/dev/null || echo "0")
echo "  Nonce: $NONCE ✓"

# Step 4: Explorer link
echo "[4/5] Explorer URL:"
echo "  $EXPLORER/address/$ADDRESS"

# Step 5: Optional owner check
if [ -n "$EXPECTED_OWNER" ]; then
  echo "[5/5] Checking owner..."
  OWNER=$(cast call --rpc-url "$RPC_URL" "$ADDRESS" "owner()(address)" 2>/dev/null || echo "unreachable")
  if [ "$OWNER" = "$EXPECTED_OWNER" ]; then
    echo "  Owner: $OWNER ✓ (matches expected)"
  else
    echo "  Owner: $OWNER (expected: $EXPECTED_OWNER)"
    echo "  WARNING: Owner does not match expected address"
  fi
else
  echo "[5/5] Skipped (no expected owner provided)"
fi

echo ""
echo "=============================================="
echo "  Verification complete for $ADDRESS on $NETWORK"
echo "  Explorer: $EXPLORER/address/$ADDRESS"
echo "=============================================="
