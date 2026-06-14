---
name: pharos-refactoring-and-code-health
description: "Improve Pharos code structure, readability, naming, and separation of concerns without changing behavior. Use when refactoring, cleaning up, simplifying, removing duplication, paying down technical debt, or restructuring Pharos Solidity contracts and TypeScript dapps. Keywords: refactor, code health, cleanup, simplify, remove duplication, technical debt, restructure, readability, Pharos, Solidity, TypeScript, Next.js, React, Foundry, Hardhat."
metadata:
  audience: developer
  version: 1.2.0
  category: contract
slash: true
---

# Refactoring and Code Health

Improve structure, readability, naming, and separation of concerns without changing behavior. Includes Pharos-specific patterns for Solidity storage gaps, PHRS transfer safety, and wagmi hook parameterization.

## Pharos-Specific Refactoring Patterns

### Solidity — Add Storage Gap for Upgradeability

```solidity
// Before — no gap, next dev may corrupt storage on upgrade
contract MyContract is Initializable, UUPSUpgradeable {
    uint256 public value;
}

// After — 50-slot gap protects future upgrades
contract MyContract is Initializable, UUPSUpgradeable {
    uint256 public value;
    /// @custom:storage-gap Storage gap for upgrade safety
    // Gap MUST be last — after all state vars, before constructor
    uint256[50] private __gap;
}
```

### Solidity — Replace Full-Gas PHRS Transfer with Capped

```solidity
// Before — forwards all gas (reentrancy risk on Pharos, no 2300 stipend)
(bool sent,) = payable(to).call{value: amount}("");

// After — cap gas to limit reentrancy
(bool sent,) = payable(to).call{value: amount, gas: 10000}("");

// Better — pull-over-push
function withdraw() external {
    uint256 amount = pendingWithdrawals[msg.sender];
    pendingWithdrawals[msg.sender] = 0;
    (bool sent,) = payable(msg.sender).call{value: amount, gas: 10000}("");
    if (!sent) pendingWithdrawals[msg.sender] = amount;
}
```

### TypeScript — Parameterize Hook by Address

```typescript
// Before — coupled to useAccount (can't read other wallets)
function usePhrsBalance() {
  const { address } = useAccount()
  return useBalance({ address, chainId: 1672 })
}

// After — parameterized, reusable
function usePhrsBalance(address: `0x${string}` | undefined) {
  return useBalance({ address, chainId: 1672 })
}
```

### NatSpec Convention for Pharos Contracts

```solidity
/// @notice What this function does
/// @param param Description
/// @return Return description
/// @dev Pharos: PHRS has no 2300 gas stipend — use gas cap
/// @custom:pharos-chain 1672
```

## When to Use

refactor, code health, cleanup, simplify, remove duplication, technical debt, restructure, improve structure, readability

## When NOT to Use

adding new features (use the relevant authoring subskill), or fixing bugs (use bug-finding-and-debugging)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: Private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=https://atlantic.dplabs-internal.com` or `PHAROS_MAINNET_RPC=https://rpc.pharos.xyz` in your environment or `.env`.
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification.
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Tests passing**: The current test suite should pass before refactoring.
## Workflow

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Identify the code smells or maintenance costs.
4. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
5. Propose the refactor scope and behavior guarantees.
6. Show the plan and ask if the direction is correct.
7. Refactor with tests or checks that preserve behavior.
## Output

- refactor plan
- behavior guarantees
- cleanup notes
- verification result

## Examples

- "Refactor this usePhrsBalance hook to remove the useAccount dependency for Pharos mainnet (1672)"
- "Add a storage gap and NatSpec to this Pharos upgradeable contract"
- "Clean up the duplicated address validation logic across the Pharos staking codebase"
- "Replace full-gas PHRS .call with capped gas in the Pharos vault withdraw function"
- "Extract PHRS transfer logic into a library contract"

## Verification

No change in test results. forge test and npm test still pass. Diff shows no behavior change.

## Related

performance-optimization (performance-driven changes), solidity-authoring (contract refactors)

## Gate


Medium risk. Present the refactor plan and behavior guarantees first; proceed only after the user agrees on scope.
