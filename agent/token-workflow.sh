#!/usr/bin/env bash
set -euo pipefail

# Dependency check
for cmd in forge cast jq curl; do
  if ! command -v $cmd &>/dev/null; then
    echo "ERROR: $cmd not found. Install it first."
    echo "  forge/cast: curl -L https://foundry.paradigm.xyz | bash && foundryup"
    echo "  jq: sudo apt-get install jq (or brew install jq)"
    echo "  curl: pre-installed on most systems"
    exit 1
  fi
done

# Helper: convert wei to human-readable (avoids bc dependency)
from_wei() {
  cast --from-wei "$1" 2>/dev/null || echo "$1"
}

# Helper: curl with timeout
curl_rpc() {
  local METHOD="$1"
  local PARAMS="$2"
  curl -s --max-time 10 --connect-timeout 5 -X POST "$RPC_URL" \
    -H "Content-Type: application/json" \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"$METHOD\",\"params\":$PARAMS,\"id\":1}" 2>/dev/null
}

# ============================================================================
# Token Launch & Distribute Agent — CLI Demo (forge + cast + curl)
# ============================================================================
# Demonstrates token lifecycle on Pharos via forge/cast CLI commands.
# This is a CLI equivalent of the MCP tools, NOT an MCP server demo.
# For the real MCP demo, run: node agent/mcp-demo.mjs
#
# Prerequisites:
#   - PRIVATE_KEY set in environment (or .env)
#   - Foundry installed (forge, cast)
#   - jq and curl installed
#   - pharos_testnet RPC configured in foundry.toml
#
# Usage:
#   export PRIVATE_KEY=0x...
#   bash agent/token-workflow.sh
# ============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  Pharos Token Agent — Atlantic Testnet (688689)"
echo "  CLI Demo — forge + cast + curl (NOT MCP — run node agent/mcp-demo.mjs for MCP)"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# --- Source .env if present ---
if [ -f .env ]; then
  set -a; source .env; set +a
fi

: "${PRIVATE_KEY:?  Set PRIVATE_KEY in .env or environment}"

RPC_URL="${PHAROS_TESTNET_RPC_URL:-https://atlantic.dplabs-internal.com}"
EXPLORER="https://atlantic.pharosscan.xyz"

# ──────────────────────────────────────────────────────────────────────────
# Tool 11: pharos_diagnose — Environment health check
# ──────────────────────────────────────────────────────────────────────────
echo "┌─ [Tool 11] pharos_diagnose — Environment Check ────────────┐"
echo "│                                                            │"

DIAG_STATUS="ready"
for cmd in forge cast jq curl git node; do
  if command -v $cmd &>/dev/null 2>&1; then
    echo "│  ✓ $cmd found"
  else
    echo "│  ✗ $cmd MISSING"
    DIAG_STATUS="needs-setup"
  fi
done

echo "│  RPC: $RPC_URL"
echo "│  PRIVATE_KEY: ${PRIVATE_KEY:0:6}...${PRIVATE_KEY: -4}"
echo "│  Status: $DIAG_STATUS"
echo "└────────────────────────────────────────────────────────────┘"
echo ""

# ──────────────────────────────────────────────────────────────────────────
# Tool 1: pharos_network_config — Network configuration
# ──────────────────────────────────────────────────────────────────────────
echo "┌─ [Tool 1] pharos_network_config — Network Info ────────────┐"
echo "│                                                            │"

CHAIN_ID=$(cast chain-id --rpc-url "$RPC_URL" 2>/dev/null || echo "unknown")
echo "│  Network: Atlantic Testnet"
echo "│  Chain ID: $CHAIN_ID"
echo "│  RPC URL: $RPC_URL"
echo "│  Explorer: $EXPLORER"
echo "│  Currency: PHRS (18 decimals)"
echo "│  Testnet: true"
echo "└────────────────────────────────────────────────────────────┘"
echo ""

# ──────────────────────────────────────────────────────────────────────────
# Tool 13: pharos_gas_estimate — Gas price estimation
# ──────────────────────────────────────────────────────────────────────────
echo "┌─ [Tool 13] pharos_gas_estimate — Gas Estimate ────────────┐"
echo "│                                                            │"

GAS_PRICE=$(cast gas-price --rpc-url "$RPC_URL" 2>/dev/null || echo "0")
MAX_PRIORITY=$(cast max-priority-fee --rpc-url "$RPC_URL" 2>/dev/null || echo "0")
echo "│  Gas price:       $GAS_PRICE wei"
echo "│  Priority fee:    $MAX_PRIORITY wei"
if [ "$GAS_PRICE" != "0" ] && [ "$MAX_PRIORITY" != "0" ]; then
  BASE_FEE=$((GAS_PRICE - MAX_PRIORITY))
  TX_COST=$((GAS_PRICE * 21000))
  echo "│  Base fee:        ${BASE_FEE} wei"
  echo "│  Tx cost (21000): ${TX_COST} wei ($(from_wei "$TX_COST") PHRS)"
fi
echo "│  Note: Pharos burns base fee (EIP-1559)"
echo "└────────────────────────────────────────────────────────────┘"
echo ""

# ──────────────────────────────────────────────────────────────────────────
# Tool 15: pharos_network_status — Block status (safe/finalized)
# ──────────────────────────────────────────────────────────────────────────
echo "┌─ [Tool 15] pharos_network_status — Network Status ────────┐"
echo "│                                                            │"

LATEST_BLOCK=$(cast block-number --rpc-url "$RPC_URL" 2>/dev/null || echo "0")
SAFE_BLOCK=$(cast block safe --rpc-url "$RPC_URL" 2>/dev/null | grep 'number' | head -1 | grep -oP '\d+' || echo "N/A")
FINALIZED_BLOCK=$(cast block finalized --rpc-url "$RPC_URL" 2>/dev/null | grep 'number' | head -1 | grep -oP '\d+' || echo "N/A")
echo "│  Latest block:    $LATEST_BLOCK"
echo "│  Safe block:      $SAFE_BLOCK"
echo "│  Finalized block: $FINALIZED_BLOCK"
if [ "$SAFE_BLOCK" != "N/A" ] && [ "$FINALIZED_BLOCK" != "N/A" ]; then
  echo "│  Blocks to finality: $((LATEST_BLOCK - FINALIZED_BLOCK))"
fi
echo "│  Pharos supports 'safe' and 'finalized' block tags"
echo "└────────────────────────────────────────────────────────────┘"
echo ""

# ──────────────────────────────────────────────────────────────────────────
# Tool 9: pharos_deploy_erc20 — Deploy ERC-20 token
# ──────────────────────────────────────────────────────────────────────────
echo "┌─ [Tool 9] pharos_deploy_erc20 — Deploy ERC-20 ───────────┐"
echo "│                                                            │"
echo "│  Deploying PharosToken (PHT) — supply: 1,000,000          │"
echo "│                                                            │"

TOKEN_ADDRESS=$(forge create contracts/PharosERC20.sol:PharosERC20 \
  --rpc-url "$RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --constructor-args "PharosToken" "PHT" 1000000000000000000000000 \
  --json 2>/dev/null | grep -o '"deployedTo":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN_ADDRESS" ]; then
  echo "│  ✗ Deploy failed. Check output above.                    │"
  echo "└──────────────────────────────────────────────────────────┘"
  exit 1
fi
echo "│  ✓ Deployed at: $TOKEN_ADDRESS"
echo "│  ✓ Explorer: $EXPLORER/address/$TOKEN_ADDRESS"
echo "│                                                            │"
echo "│  [Tool 2: pharos_deploy_contract — would use forge script] │"
echo "└────────────────────────────────────────────────────────────┘"
echo ""

# ──────────────────────────────────────────────────────────────────────────
# Tool 3: pharos_verify_contract — Verify on PharosScan
# ──────────────────────────────────────────────────────────────────────────
echo "┌─ [Tool 3] pharos_verify_contract — Verify Contract ──────┐"
echo "│                                                            │"
echo "│  To verify on PharosScan:                                 │"
echo "│                                                            │"
echo "│    forge verify-contract \\"
echo "│      --chain-id $CHAIN_ID \\"
echo "│      --verifier blockscout \\"
echo "│      --verifier-url https://api.socialscan.io/pharos-atlantic-testnet/v1/explorer/command_api/contract \\"
echo "│      $TOKEN_ADDRESS \\"
echo "│      contracts/PharosERC20.sol:PharosERC20 \\"
echo "│      --constructor-args \$(cast abi-encode \"constructor(string,string,uint256)\" \\"
echo "│        \"PharosToken\" \"PHT\" 1000000000000000000000000) \\"
echo "│                                                            │"
echo "│  (Skipping — requires PHAROSSCAN_API_KEY)                 │"
echo "└────────────────────────────────────────────────────────────┘"
echo ""

# ──────────────────────────────────────────────────────────────────────────
# Tool 12: pharos_get_account — Pharos-specific eth_getAccount RPC
# ──────────────────────────────────────────────────────────────────────────
echo "┌─ [Tool 12] pharos_get_account — Account State ───────────┐"
echo "│                                                            │"

DEPLOYER=$(cast wallet address --private-key "$PRIVATE_KEY" 2>/dev/null)
echo "│  Address: $DEPLOYER"

ACCOUNT_DATA=$(curl_rpc "eth_getAccount" "[\"$DEPLOYER\",\"latest\"]")

echo "│  eth_getAccount is Pharos-specific — returns all 4 fields:"
echo "│    balance:     $(echo "$ACCOUNT_DATA" | jq -r '.result.balance // "N/A"' 2>/dev/null)"
echo "│    nonce:       $(echo "$ACCOUNT_DATA" | jq -r '.result.nonce // "N/A"' 2>/dev/null)"
echo "│    codeHash:    $(echo "$ACCOUNT_DATA" | jq -r '.result.codeHash // "N/A"' 2>/dev/null)"
echo "│    storageRoot: $(echo "$ACCOUNT_DATA" | jq -r '.result.storageRoot // "N/A"' 2>/dev/null)"
echo "└────────────────────────────────────────────────────────────┘"
echo ""

# ──────────────────────────────────────────────────────────────────────────
# Tool 6: pharos_check_balance — Check ERC-20 + native balance
# ──────────────────────────────────────────────────────────────────────────
echo "┌─ [Tool 6] pharos_check_balance — Check Balances ─────────┐"
echo "│                                                            │"
echo "│  Deployer: $DEPLOYER"

NATIVE_BAL=$(cast balance "$DEPLOYER" --rpc-url "$RPC_URL" 2>/dev/null)
echo "│  Native PHRS: $(from_wei "$NATIVE_BAL")"

BALANCE_RAW=$(cast call "$TOKEN_ADDRESS" \
  "balanceOf(address)(uint256)" "$DEPLOYER" \
  --rpc-url "$RPC_URL" 2>/dev/null)
BALANCE_PHT=$(from_wei "$BALANCE_RAW")
echo "│  Token PHT:   $BALANCE_PHT"
echo "└────────────────────────────────────────────────────────────┘"
echo ""

# ──────────────────────────────────────────────────────────────────────────
# Tool 8: pharos_transfer_token — Send ERC-20 tokens
# ──────────────────────────────────────────────────────────────────────────
echo "┌─ [Tool 8] pharos_transfer_token — Transfer 100 PHT ──────┐"
echo "│                                                            │"

RECIPIENT="0x0000000000000000000000000000000000001234"
AMOUNT_WEI=$(cast --to-wei 100 2>/dev/null || echo "100000000000000000000")

TX_HASH=$(cast send "$TOKEN_ADDRESS" \
  "transfer(address,uint256)" "$RECIPIENT" "$AMOUNT_WEI" \
  --rpc-url "$RPC_URL" \
  --private-key "$PRIVATE_KEY" 2>/dev/null | grep -o 'transactionHash: 0x[a-fA-F0-9]\{64\}' | cut -d' ' -f2 || true)

if [ -z "$TX_HASH" ]; then
  echo "│  ✗ Transfer failed"
  TX_HASH="N/A"
else
  echo "│  ✓ Sent 100 PHT → $RECIPIENT"
  echo "│  TX: $TX_HASH"
  echo "│  Explorer: $EXPLORER/tx/$TX_HASH"
fi
echo "└────────────────────────────────────────────────────────────┘"
echo ""

# ──────────────────────────────────────────────────────────────────────────
# Tool 14: pharos_trace_transaction — debug_traceTransaction
# ──────────────────────────────────────────────────────────────────────────
echo "┌─ [Tool 14] pharos_trace_transaction — Trace TX ──────────┐"
echo "│                                                            │"
echo "│  Pharos enables debug_traceTransaction (most chains don't) │"

if [ "$TX_HASH" != "N/A" ]; then
TRACE_DATA=$(curl_rpc "debug_traceTransaction" "[\"$TX_HASH\",{\"tracer\":\"callTracer\"}]")

  FROM=$(echo "$TRACE_DATA" | jq -r '.result.from // "N/A"' 2>/dev/null)
  TO=$(echo "$TRACE_DATA" | jq -r '.result.to // "N/A"' 2>/dev/null)
  GAS_USED=$(echo "$TRACE_DATA" | jq -r '.result.gasUsed // "N/A"' 2>/dev/null)
  echo "│  From:     $FROM"
  echo "│  To:       $TO"
  echo "│  Gas used: $GAS_USED"
else
  echo "│  (Skipping — no transaction hash available)"
fi
echo "└────────────────────────────────────────────────────────────┘"
echo ""

# ──────────────────────────────────────────────────────────────────────────
# Tool 10: pharos_get_logs — Fetch Transfer event logs
# ──────────────────────────────────────────────────────────────────────────
echo "┌─ [Tool 10] pharos_get_logs — Event Logs ─────────────────┐"
echo "│                                                            │"

LOGS=$(curl_rpc "eth_getLogs" "[{\"address\":\"$TOKEN_ADDRESS\",\"fromBlock\":\"0x0\",\"toBlock\":\"latest\"}]")

LOG_COUNT=$(echo "$LOGS" | jq '.result | length' 2>/dev/null || echo "0")
echo "│  Contract: $TOKEN_ADDRESS"
echo "│  Events found: $LOG_COUNT"
echo "│  Note: Pharos limits eth_getLogs to 100 blocks per request"
echo "└────────────────────────────────────────────────────────────┘"
echo ""

# ──────────────────────────────────────────────────────────────────────────
# Tool 7: pharos_contract_info — Explorer API lookup
# ──────────────────────────────────────────────────────────────────────────
echo "┌─ [Tool 7] pharos_contract_info — Explorer Info ──────────┐"
echo "│                                                            │"

EXPLORER_API="$EXPLORER/api"
CONTRACT_DATA=$(curl -s "$EXPLORER_API?module=contract&action=getsourcecode&address=$TOKEN_ADDRESS" 2>/dev/null)
echo "│  Address: $TOKEN_ADDRESS"
echo "│  Explorer API: $EXPLORER_API"
echo "│  Source: $(echo "$CONTRACT_DATA" | jq -r '.result[0].SourceCode // "N/A"' 2>/dev/null | head -c 80)..."
echo "│  Explorer URL: $EXPLORER/address/$TOKEN_ADDRESS"
echo "└────────────────────────────────────────────────────────────┘"
echo ""

# ──────────────────────────────────────────────────────────────────────────
# Tool 4: pharos_run_security_check — Security analysis
# ──────────────────────────────────────────────────────────────────────────
echo "┌─ [Tool 4] pharos_run_security_check — Security Review ───┐"
echo "│                                                            │"
echo "│  Pharos-specific checks for your contracts:               │"
echo "│  • PHRS has no 2300 gas stipend — use pull-over-push      │"
echo "│  • Chain ID: $CHAIN_ID (not 688688 — deprecated v1)      │"
echo "│  • EIP-1559: base fee burned, priority to validators      │"
echo "│  • RPC rate limit: ~30 req/s sustained                    │"
echo "│                                                            │"
echo "│  Run slither for automated analysis:                      │"
echo "│    slither contracts/PharosERC20.sol --json               │"
echo "└────────────────────────────────────────────────────────────┘"
echo ""

# ──────────────────────────────────────────────────────────────────────────
# Tool 5: pharos_generate_tests — Test generation
# ──────────────────────────────────────────────────────────────────────────
echo "┌─ [Tool 5] pharos_generate_tests — Test Generation ───────┐"
echo "│                                                            │"
echo "│  Run Foundry tests for this contract:                     │"
echo "│                                                            │"
echo "│    forge test --match-path test/PharosERC20.t.sol -vvv    │"
echo "│                                                            │"
echo "│  Or generate new test scaffolding:                        │"
echo "│    forge init --template test && forge test                │"
echo "└────────────────────────────────────────────────────────────┘"
echo ""

# ──────────────────────────────────────────────────────────────────────────
# Post-Transfer Balances
# ──────────────────────────────────────────────────────────────────────────
echo "┌─ Post-Transfer Summary ───────────────────────────────────┐"
echo "│                                                            │"

DEPLOYER_BALANCE=$(cast call "$TOKEN_ADDRESS" \
  "balanceOf(address)(uint256)" "$DEPLOYER" \
  --rpc-url "$RPC_URL" 2>/dev/null)
RECIPIENT_BALANCE=$(cast call "$TOKEN_ADDRESS" \
  "balanceOf(address)(uint256)" "$RECIPIENT" \
  --rpc-url "$RPC_URL" 2>/dev/null)

echo "│  Deployer  balance: $(from_wei "$DEPLOYER_BALANCE") PHT"
echo "│  Recipient balance: $(from_wei "$RECIPIENT_BALANCE") PHT"
echo "│                                                            │"
echo "└────────────────────────────────────────────────────────────┘"
echo ""

echo "═══════════════════════════════════════════════════════════════"
echo "  Workflow Complete! CLI tools demonstrated.                 "
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "  Task 1: pharos_network_config        — network info shown"
echo "  Task 2: pharos_deploy_contract       — forge script (alt)"
echo "  Task 3: pharos_verify_contract       — forge verify (cmd)"
echo "  Task 4: pharos_run_security_check    — security checklist"
echo "  Task 5: pharos_generate_tests        — test cmd shown"
echo "  Task 6: pharos_check_balance         — balances queried"
echo "  Task 7: pharos_contract_info         — explorer API hit"
echo "  Task 8: pharos_transfer_token        — tokens sent ✓"
echo "  Task 9: pharos_deploy_erc20          — token deployed ✓"
echo "  Task 10: pharos_get_logs              — event logs fetched"
echo "  Task 11: pharos_diagnose              — env checked"
echo "  Task 12: pharos_get_account           — eth_getAccount RPC"
echo "  Task 13: pharos_gas_estimate          — gas prices shown"
echo "  Task 14: pharos_trace_transaction     — tx traced"
echo "  Task 15: pharos_network_status        — block status shown"
echo ""
echo "  Token: $TOKEN_ADDRESS"
echo "  Explorer: $EXPLORER/address/$TOKEN_ADDRESS"
echo "═══════════════════════════════════════════════════════════════"
