# Test Strategy for Pharos Contracts

## Overview

Define and execute a Pharos-specific test pyramid covering unit tests, integration tests (testnet fork), and end-to-end flows. Target 90%+ branch coverage for core contracts and 100% call coverage for all public/external functions.

## Test Pyramid

```
        /\
       /  \      E2E (Mainnet fork)
      /    \     1-2 critical user flows
     /------\
    /        \   Integration (Testnet fork)
   /          \  Multi-contract, PHRS transfers
  /------------\
 /              \  Unit (Foundry)
/                \ Individual functions, edge cases, revert paths
```

## 1. Unit Tests with Foundry

```solidity
// test/PharosERC20.t.sol — Unit test example
import {Test} from "forge-std/Test.sol";
import {PharosERC20} from "../contracts/PharosERC20.sol";

contract PharosERC20Test is Test {
    PharosERC20 public token;
    address public alice = address(0x1);
    address public bob = address(0x2);

    function setUp() public {
        token = new PharosERC20("Test", "TST", 18, 1_000_000e18);
        token.transfer(alice, 1000e18);
    }

    function test_MintCap() public {
        // NOTE: Verify actual revert string from PharosERC20.sol
        // If using custom errors, use: vm.expectRevert(PharosERC20.CapExceeded.selector);
        vm.expectRevert("ERC20: cap exceeded");
        token.mint(address(this), 2_000_000e18);  // Exceeds 1M cap
    }

    function test_BurnReducesTotalSupply() public {
        uint256 before = token.totalSupply();
        token.burn(100e18);
        assertEq(token.totalSupply(), before - 100e18);
    }

    function test_TransferRevertsWhenExceedsBalance() public {
        vm.prank(alice);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        token.transfer(bob, 2000e18);  // Alice only has 1000
    }
}
```

## 2. Fuzz Tests

```solidity
// Fuzz a transfer with random amounts
function testFuzz_TransferPreservesTotalSupply(uint256 amount) public {
    amount = bound(amount, 1, token.balanceOf(alice));
    uint256 supplyBefore = token.totalSupply();
    
    vm.prank(alice);
    token.transfer(bob, amount);
    
    assertEq(token.totalSupply(), supplyBefore);
    assertEq(token.balanceOf(bob), amount);
}

// Fuzz with handler-based invariant
function testFuzz_ApproveThenTransferFrom(
    uint256 amount,
    uint256 transferAmount
) public {
    amount = bound(amount, 1e18, 1000e18);
    transferAmount = bound(transferAmount, 1, amount);
    
    vm.prank(alice);
    token.approve(bob, amount);
    
    vm.prank(bob);
    token.transferFrom(alice, bob, transferAmount);
    
    assertEq(token.allowance(alice, bob), amount - transferAmount);
    assertEq(token.balanceOf(bob), transferAmount);
}
```

## 3. Invariant Tests (Critical for DeFi)

```solidity
// test/invariants/PharosERC20Invariants.t.sol
import {StdInvariant} from "forge-std/StdInvariant.sol";

contract PharosERC20Invariants is StdInvariant {
    PharosERC20 public token;
    ERC20Handler public handler;

    function setUp() public {
        token = new PharosERC20("Test", "TST", 18, 1_000_000e18);
        handler = new ERC20Handler(token);
        targetContract(address(handler));
        // Run 1000 fuzz calls
        bytes4[] memory selectors = new bytes4[](4);
        selectors[0] = handler.transfer.selector;
        selectors[1] = handler.approve.selector;
        selectors[2] = handler.mint.selector;
        selectors[3] = handler.burn.selector;
        FuzzSelector memory selector = FuzzSelector({
            address: address(handler),
            selectors: selectors
        });
        targetSelector(selector);
    }

    // Core invariant: total supply never exceeds cap
    function invariant_TotalSupplyNeverExceedsCap() public {
        assertLe(token.totalSupply(), token.cap());
    }

    // Core invariant: sum of balances equals total supply
    function invariant_SumOfBalancesEqualsTotalSupply() public {
        // Implement by tracking all holders in handler
        assertEq(token.totalSupply(), handler.totalBalance());
    }
}
```

### Foundry Config for Invariant Tests

```toml
# foundry.toml
[invariant]
runs = 256          # Number of invariant test sequences
depth = 100         # Number of fuzz calls per sequence
fail_on_revert = false  # Allow reverts during sequence
```

## 4. Fork Tests (Integration)

```solidity
// Fork Atlantic testnet to test against deployed contracts
function testFork_LendingPoolDeposit() public {
    string memory RPC = "https://atlantic.dplabs-internal.com";
    vm.createSelectFork(RPC, 4_500_000);  // Block number for consistency
    
    // Interact with already-deployed contracts
    // Replace with actual deployed addresses from DEPLOYMENTS.md
    IPharosLendingPool pool = IPharosLendingPool(LENDING_POOL_ADDRESS);
    IPharosERC20 token = IPharosERC20(TOKEN_A_ADDRESS);
    
    // Fund test account via impersonation
    vm.prank(WHALE_ADDRESS);
    token.transfer(address(this), 10_000e18);
    
    token.approve(address(pool), 10_000e18);
    pool.deposit(address(token), 10_000e18);
    
    (uint256 shares, uint256 assets) = pool.getPosition(address(this), address(token));
    assertGt(shares, 0);
    assertEq(assets, 10_000e18);
}
```

## 5. Gas Tests

```solidity
// Track gas costs for critical operations
function testGas_Transfer() public {
    uint256 gasBefore = gasleft();
    
    vm.prank(alice);
    token.transfer(bob, 100e18);
    
    uint256 gasUsed = gasBefore - gasleft();
    emit log_named_uint("Transfer gas cost", gasUsed);
    assertLt(gasUsed, 100_000, "Transfer too expensive");
}
```

## 6. MCP Tool Behavioral Tests

```javascript
// test/mcp/behavioral.mjs — Test actual MCP tool behavior
import { describe, it } from "node:test";
import assert from "node:assert/strict";

// NOTE: callTool() helper is defined in mcp-server/test-helpers.mjs
// It spawns the MCP server, sends a JSON-RPC request, and returns the response.

// Each MCP tool should have at least one test validating:
// - It returns the expected JSON-RPC response format
// - It handles missing parameters with proper error
// - Its output matches expected schema (address format, hex strings, etc.)

describe("pharos_deploy_contract", () => {
    it("should error on missing contract name", async () => {
        const response = await callTool("pharos_deploy_contract", {});
        assert.ok(response.isError);
        assert.ok(response.content[0].text.includes("required"));
    });
});
```

## Coverage Targets

| Contract | Branch Coverage | Call Coverage | Notes |
|----------|----------------|---------------|-------|
| PharosERC20 | 95%+ | 100% | Cap, burn, snapshots |
| PharosLendingPool | 90%+ | 100% | Liquidation math, interest |
| DEXPool | 90%+ | 100% | Swap math, fee tiers |
| StakingPool | 90%+ | 100% | Reward accrual, unstaking |
| PharosSPNPaymaster | 95%+ | 100% | Whitelist, budget, replay |
| PharosZkLogin | 90%+ | 100% | Proof verification, nonce |
| PharosTimelockController | 90%+ | 100% | Queue, execute, cancel |

## Pharos-Specific Edge Cases to Test

- **Chain reorgs**: `vm.roll()` to simulate 1-2 block rollback; verify event log consistency
- **Gas volatility**: Test `tx.gasprice` ranging from 1-100 gwei; ensure user operations still succeed
- **SPN sponsorship expiry**: Ensure expired sponsorship signatures are rejected
- **Cross-chain messages**: Test source chain deposit, Pharos claim, relay failure recovery
- **ZkLogin ephemeral key expiry**: Ensure expired ephemeral keys cannot submit UserOperations

## Related Subskills

- `contract-testing-for-testnet-and-mainnet` — Testing against live networks
- `test-generation` — Automated test generation patterns
- `contract-review` — Reviewing test coverage before deployment
- `bug-finding-and-debugging` — Debugging failing tests
