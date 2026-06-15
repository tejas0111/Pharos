#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Token Launch & Distribute Agent
# ============================================================================
# Demonstrates Skill-to-Agent composition: deploys ERC-20, checks balance,
# transfers tokens — chaining 3 MCP tools into a single workflow.
#
# Prerequisites:
#   - PRIVATE_KEY set in environment (or .env)
#   - Foundry installed (forge, cast)
#   - pharos_testnet RPC configured in foundry.toml
#
# Usage:
#   export PRIVATE_KEY=0x...
#   bash agent/token-workflow.sh
# ============================================================================

echo "════════════════════════════════════════════════"
echo "  Pharos Token Agent — Atlantic Testnet (688689)"
echo "════════════════════════════════════════════════"
echo ""

# --- Source .env if present ---
if [ -f .env ]; then
  set -a; source .env; set +a
fi

: "${PRIVATE_KEY:?  Set PRIVATE_KEY in .env or environment}"

RPC_URL="${PHAROS_TESTNET_RPC_URL:-https://atlantic.dplabs-internal.com}"

# --- Step 1: Deploy ERC-20 ---
echo "┌─ Step 1/3: Deploy PharosERC20 ──────────────────────┐"
echo "│                                                     │"
TOKEN_ADDRESS=$(forge create contracts/PharosERC20.sol:PharosERC20 \
  --rpc-url "$RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --constructor-args "PharosToken" "PHT" 1000000000000000000000000 \
  --json 2>/dev/null | grep -o '"deployedTo":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN_ADDRESS" ]; then
  echo "│  ✗ Deploy failed. Check output above.               │"
  echo "└─────────────────────────────────────────────────────┘"
  exit 1
fi
echo "│  ✓ Deployed at: $TOKEN_ADDRESS"
echo "└─────────────────────────────────────────────────────┘"
echo ""

# --- Step 2: Check deployer balance ---
echo "┌─ Step 2/3: Check Deployer Balance ─────────────────┐"
echo "│                                                     │"
DEPLOYER=$(cast wallet address --private-key "$PRIVATE_KEY" 2>/dev/null)
echo "│  Deployer: $DEPLOYER"
BALANCE_RAW=$(cast call "$TOKEN_ADDRESS" \
  "balanceOf(address)(uint256)" "$DEPLOYER" \
  --rpc-url "$RPC_URL" 2>/dev/null)
BALANCE_PHT=$(cast --from-wei "$BALANCE_RAW" 2>/dev/null || echo "$BALANCE_RAW")
echo "│  Balance: $BALANCE_PHT PHT"
echo "└─────────────────────────────────────────────────────┘"
echo ""

# --- Step 3: Transfer to test address ---
echo "┌─ Step 3/3: Transfer 100 PHT ───────────────────────┐"
echo "│                                                     │"
RECIPIENT="0x0000000000000000000000000000000000001234"
AMOUNT_WEI=$(cast --to-wei 100 2>/dev/null || echo "100000000000000000000")

cast send "$TOKEN_ADDRESS" \
  "transfer(address,uint256)" "$RECIPIENT" "$AMOUNT_WEI" \
  --rpc-url "$RPC_URL" \
  --private-key "$PRIVATE_KEY" > /dev/null 2>&1

echo "│  ✓ Sent 100 PHT → $RECIPIENT"
echo "└─────────────────────────────────────────────────────┘"
echo ""

# --- Verify post-transfer balances ---
echo "┌─ Post-Transfer Summary ────────────────────────────┐"
echo "│                                                     │"
DEPLOYER_BALANCE=$(cast call "$TOKEN_ADDRESS" \
  "balanceOf(address)(uint256)" "$DEPLOYER" \
  --rpc-url "$RPC_URL" 2>/dev/null)
RECIPIENT_BALANCE=$(cast call "$TOKEN_ADDRESS" \
  "balanceOf(address)(uint256)" "$RECIPIENT" \
  --rpc-url "$RPC_URL" 2>/dev/null)
echo "│  Deployer  balance: $(cast --from-wei "$DEPLOYER_BALANCE") PHT"
echo "│  Recipient balance: $(cast --from-wei "$RECIPIENT_BALANCE") PHT"
echo "│                                                     │"
echo "└─────────────────────────────────────────────────────┘"
echo ""

echo "════════════════════════════════════════════════"
echo "  Workflow Complete!"
echo "  Token: $TOKEN_ADDRESS"
echo "  Explorer: https://atlantic.pharosscan.xyz/address/$TOKEN_ADDRESS"
echo "════════════════════════════════════════════════"
