---
name: pharos-test-generation
description: "Write Foundry/Hardhat tests for Pharos contracts with Pharos-specific fixtures (PhrsToken, test accounts), fork URLs (testnet/mainnet), chain assertions (chain IDs 1672/688689, ~2s block times), and SolAid/PharosScan verification checks. Use when generating unit/integration/e2e tests, fixtures, or mock data for Pharos Solidity contracts or frontend components. Keywords: write tests, generate tests, fixtures, mock data, unit test, integration test, e2e test, Foundry, Hardhat, Solidity, Pharos, forge test, hardhat test, wagmi, viem, PhrsToken, 1672, 688689."
metadata:
  audience: developer
  version: 1.1.0
  category: testing
  slash: true
---

# Test Generation

Write unit, integration, or end-to-end tests from the chosen strategy.

## When to Use

write tests, generate tests, fixtures, mock data, test files, add tests for, test this function, unit test, integration test

## When NOT to Use

planning what to test (use testing-strategy first), or debugging a failure (use bug-finding-and-debugging)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=https://atlantic.dplabs-internal.com` or `PHAROS_MAINNET_RPC=https://rpc.pharos.xyz` in your environment or `.env`.
- **Private key**: Set `PRIVATE_KEY` environment variable (keep this secret, never commit).
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification (https://pharosscan.xyz).
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Foundry config**: `foundry.toml` should have `[rpc_endpoints]` section with `pharos_testnet` and `pharos_mainnet` entries.

## Workflow

1. Use the approved test strategy and identify concrete cases.
2. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
3. Draft the tests with Pharos fixtures, fork URLs, and chain-specific assertions.
4. Show the test plan and ask if the cases are correct.
5. Generate the tests and verify they fail or pass as intended.

## Pharos-Specific Test Conventions

### Foundry Config for Tests

```toml
# foundry.toml
[rpc_endpoints]
pharos_mainnet = "https://rpc.pharos.xyz"
pharos_testnet = "https://atlantic.dplabs-internal.com"
```

### Foundry Fork Setup

```solidity
// Pharos testnet fork
vm.createSelectFork("pharos_testnet");

// Pharos mainnet fork at a specific block
vm.createSelectFork("pharos_mainnet", blockNumber);
```

### Hardhat Fork Setup

```typescript
import { ethers } from "hardhat";
const provider = new ethers.JsonRpcProvider("https://atlantic.dplabs-internal.com");
const deployer = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
```

### Pharos Chain Assertions

```solidity
// Chain ID checks
assertEq(block.chainid, 688689); // Pharos Atlantic Testnet
assertEq(block.chainid, 1672);   // Pharos mainnet (Pacific)

// Block time is ~2 seconds on Pharos
uint256 blockTime = block.timestamp - vm.getBlockTimestamp(block.number - 1);
assertApproxEqAbs(blockTime, 2, 1);
```

### Pharos Staking Test — Complete Example

```solidity
// test/PharosStaking.t.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/PharosStaking.sol";

contract PharosStakingTest is Test {
    PharosStaking staking;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        vm.createSelectFork("pharos_mainnet");
        staking = new PharosStaking();
    }

    function test_ChainId() public {
        assertEq(block.chainid, 1672);
    }

    function test_Stake() public {
        vm.deal(alice, 100 ether);
        vm.prank(alice);
        staking.stake{value: 10 ether}();
        assertEq(staking.stakes(alice), 10 ether);
    }

    function test_Unstake() public {
        vm.deal(alice, 100 ether);
        vm.prank(alice);
        staking.stake{value: 10 ether}();
        vm.prank(alice);
        staking.unstake(5 ether);
        assertEq(staking.stakes(alice), 5 ether);
    }

    function test_Revert_ZeroStake() public {
        vm.prank(alice);
        vm.expectRevert(); // or custom error
        staking.stake{value: 0}();
    }

    function test_Revert_InsufficientStake() public {
        vm.prank(alice);
        vm.expectRevert();
        staking.unstake(1 ether);
    }

    // Fuzz test
    function testFuzz_Stake_TotalStaked(uint96 amount) public {
        vm.assume(amount > 0 && amount < 100_000 ether);
        vm.deal(alice, amount);
        vm.prank(alice);
        staking.stake{value: amount}();
        assertEq(staking.stakes(alice), amount);
    }

    // Fork test against live contract
    function testFork_LiveStaking() public {
        address liveContract = 0xYourDeployedAddress;
        uint256 preBalance = address(liveContract).balance;
        assertTrue(preBalance > 0, "No PHRS staked on live contract");
    }
}
```

### Foundry Fuzz and Invariant Patterns

```solidity
// Fuzz — random inputs
function testFuzz_Stake_AnyAmount(uint256 amount) public {
    vm.assume(amount > 0 && amount < type(uint96).max);
    vm.deal(alice, amount);
    vm.prank(alice);
    staking.stake{value: amount}();
    assertEq(staking.stakes(alice), amount);
    assertEq(staking.totalStaked(), amount);
}

// Invariant — total staked always equals sum of individual stakes
function invariant_TotalStaked() public {
    assertEq(staking.totalStaked(), staking.stakes(alice) + staking.stakes(bob));
}
```

## Output

- test files
- fixtures
- assertions
- coverage notes

## Examples

- "Generate Forge tests for the PHRS unstake path: cooldown, zero-amount, reentrancy, and max-stake edge cases on testnet fork (688689)"
- "Create wagmi test for tx lifecycle (pending/confirming/success/reverted) on Pharos testnet"
- "Write fuzz tests for IPharosStaking reward calculation: uneven stakes, partial claims, compounding"
- "Write Pharos-specific Foundry tests with fork URLs and chain ID assertions"

## Verification

forge test or npx hardhat test or npm test. Confirm tests pass (or fail as expected for TDD).

## Related

testing-strategy (planning), contract-testing-for-testnet-and-mainnet (network-specific), bug-finding-and-debugging (fixing failures)

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the mini-strategy (Tier | File | Command | Chain ID | Cases) and sample test skeleton — show the plan first
- Do NOT wait for approval to draft — show everything in your response before asking for confirmation

**Phase 2 — Execute (wait for approval):**
- Do NOT Write test files, generate test code, or modify existing tests
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions