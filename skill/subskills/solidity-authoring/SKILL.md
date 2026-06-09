---
name: pharos-solidity-authoring
description: "Write or refactor Pharos Solidity contracts with clear structure, custom errors, events, modifiers, and testable patterns. Use when implementing, writing, or refactoring Solidity smart contracts for Pharos, including ERC-20/721/1155 tokens, staking, vault, AMM, lending, or DeFi/RealFi protocols. Keywords: Solidity, write contract, implement, refactor, smart contract, ERC-20, ERC-721, ERC-1155, staking, vault, AMM, lending, DeFi, RealFi, Pharos, PHRS, custom errors, events, modifiers, Foundry, forge, Remix."
metadata:
  audience: developer
  version: 1.1.0
  category: contract
slash: true
---

# Solidity Authoring

Write or refactor Solidity contracts with clear structure, custom errors, events, modifiers, and testable patterns for Pharos mainnet (chain ID 1672) using PHRS as native currency (18 decimals).

## When to Use

write Solidity, implement contract, refactor contract, contract code, Solidity, write a contract, implement the staking contract, write smart contract

## When NOT to Use

designing architecture (use contract-architecture), reviewing code (use contract-review), or writing tests (use test-generation)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=https://atlantic.dplabs-internal.com` or `PHAROS_MAINNET_RPC=https://rpc.pharos.xyz` in your environment or `.env`.
- **Private key**: Set `PRIVATE_KEY` environment variable (keep this secret, never commit).
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification (https://pharosscan.xyz).
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Foundry config**: `foundry.toml` should have `[rpc_endpoints]` section with `pharos_testnet` and `pharos_mainnet` entries.

## Pharos-Specific Contract Patterns

### Chain ID Validation

Always verify the target chain in constructors and critical functions:

```solidity
error WrongChain(uint256 actual, uint256 expected);

uint256 public constant PHAROS_MAINNET = 1672;
uint256 public constant PHAROS_TESTNET = 688689;

modifier onlyPharosMainnet() {
    if (block.chainid != PHAROS_MAINNET) revert WrongChain(block.chainid, PHAROS_MAINNET);
    _;
}
```

### PHRS Native Currency Handling

PHRS is the native currency (18 decimals). Unlike ETH, PHRS forwards **all remaining gas** in `.call{value:}` — there is **no 2300 gas stipend**. Always specify a gas limit or use a pull-over-push pattern:

```solidity
// WRONG — forwards all gas, dangerous in loops
(bool sent,) = payable(receiver).call{value: amount}("");

// RIGHT — cap gas to prevent reentrancy
(bool sent,) = payable(receiver).call{value: amount, gas: 10000}("");

// RIGHT — pull-over-push (recommended)
mapping(address => uint256) public pendingWithdrawals;

function withdraw() external {
    uint256 amount = pendingWithdrawals[msg.sender];
    pendingWithdrawals[msg.sender] = 0;
    (bool sent,) = payable(msg.sender).call{value: amount, gas: 10000}("");
    if (!sent) pendingWithdrawals[msg.sender] = amount; // revert on failure
}
```

### PHRS Receive Pattern for Staking/Vault

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PharosStaking {
    error WrongChain(uint256 actual, uint256 expected);

    uint256 public constant PHAROS_CHAIN_ID = 1672;
    mapping(address => uint256) public stakes;
    mapping(address => uint256) public rewards;

    constructor() {
        if (block.chainid != PHAROS_CHAIN_ID) revert WrongChain(block.chainid, PHAROS_CHAIN_ID);
    }

    function stake() external payable {
        stakes[msg.sender] += msg.value;
    }

    function unstake(uint256 amount) external {
        require(stakes[msg.sender] >= amount, "insufficient stake");
        stakes[msg.sender] -= amount;
        (bool sent,) = payable(msg.sender).call{value: amount, gas: 10000}("");
        require(sent, "PHRS transfer failed");
    }

    // PHRS-native receive — no 2300 gas stipend
    receive() external payable {}
}
```

## Workflow

1. Capture the contract goal, inputs, outputs, and invariants.
2. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
3. Draft the contract shape, custom errors, events, and modifiers.
4. Include Pharos chain ID validation and PHRS gas stipend warnings.
5. Present the implementation plan and ask for confirmation.
6. Write the contract in a way that is easy to test and review.

## Output

- contract draft
- event and error plan
- implementation notes
- test hooks
- invariants

## Examples

- "Write a Pharos staking contract with PHRS stake/unstake and chain ID 1672 validation"
- "Refactor this PHRS token contract to use custom errors and events"
- "Implement a PHRS staking contract with deposit, withdraw, and reward distribution using pull-over-push"
- "Add chain ID validation and gas-stipend-safe .call to this Pharos vault contract"

## Verification

forge build or npx hardhat compile. Then forge test for unit tests. Verify chain ID in deployment script (see foundry-hardhat-contract-workflow).

## Related

contract-architecture (design), interface-abi-design (ABI), test-generation (tests)

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the contract code with errors, events, modifiers, and NatSpec — show the complete contract in your response
- Do NOT wait for approval to draft — show everything in your response before asking for confirmation

**Phase 2 — Execute (wait for approval):**
- Do NOT Write contract files to disk, modify existing files, or compile/deploy
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions