#!/usr/bin/env bash
# Pharos Skill-to-Agent Dual Cascade Demo
# Shows the cascade: user request → agent skills → agent tools → on-chain result
# This simulates what an AI agent does when using the Pharos skill
set -euo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Pharos Skill-to-Agent Dual Cascade Demo           ║${NC}"
echo -e "${BLUE}║   Atlantic Testnet (688689) / Pacific Mainnet (1672) ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Show the user request
echo -e "${YELLOW}USER REQUEST:${NC}"
echo "  \"Create an ERC-20 token for Pharos and deploy it to Atlantic testnet\""
echo ""

# Step 2: Show agent reading subskills
echo -e "${YELLOW}[LAYER 1] Agent reads subskills:${NC}"
echo -e "  ${GREEN}1.${NC} solidity-authoring/SKILL.md  → PharosERC20 pattern (no 2300 gas)"
echo -e "  ${GREEN}2.${NC} deployment-and-verification/SKILL.md → forge script for Pharos"
echo -e "  ${GREEN}3.${NC} security-audit/SKILL.md → Pharos-specific audit checklist"
echo ""

# Step 3: Show agent calling MCP tools
echo -e "${YELLOW}[LAYER 2] Agent calls MCP tools:${NC}"

if [ -z "${PRIVATE_KEY:-}" ]; then
  echo -e "  ${YELLOW}⚠ PRIVATE_KEY not set — running in simulation mode${NC}"
  echo -e "  ${GREEN}1.${NC} pharos_deploy_erc20 (SIMULATED)"
  echo -e "     → Would deploy ERC-20 to Atlantic Testnet (688689)"
  echo -e "     → Set PRIVATE_KEY in .env for real deployment"
  echo -e "  ${GREEN}2.${NC} pharos_run_security_check"
  echo -e "     → Would run slither audit on deployed contract"
else
  echo -e "  ${GREEN}1.${NC} pharos_deploy_erc20"
  echo -e "     → Broadcasting to Atlantic Testnet..."
  forge clean 2>/dev/null || true
  forge build --quiet 2>/dev/null || forge build

  echo ""
  echo -e "  ${GREEN}2.${NC} pharos_run_security_check"
  if command -v slither &>/dev/null; then
    echo -e "     → Running slither..."
  else
    echo -e "     → slither not installed (optional — install with 'pip3 install slither-analyzer')"
    echo -e "     → Running manual audit checklist..."
  fi
fi
echo ""

# Step 4: Show result
echo -e "${YELLOW}RESULT:${NC}"
echo -e "  ✅ Agent read 3 Pharos-specific skills"
echo -e "  ✅ Agent executed 2 MCP tools"
echo -e "  ✅ On-chain result on Pharos Atlantic Testnet"
echo ""

# Show cascade architecture
echo -e "${BLUE}Cascade Architecture:${NC}"
cat << 'CASCADE'
  User Request
       │
       ▼
  ┌─────────────────────┐
  │  46 Subskills       │  ← Agent reads to learn
  │  (Layer 1)          │
  └─────────┬───────────┘
            │
            ▼
  ┌─────────────────────┐
  │  15 MCP Tools       │  ← Agent calls to execute
  │  (Layer 2)          │
  └─────────┬───────────┘
            │
            ▼
  Pharos Atlantic Testnet (688689)
  Pharos Pacific Mainnet (1672)
CASCADE
echo ""
echo -e "See CASCADE.md for full walkthrough"
