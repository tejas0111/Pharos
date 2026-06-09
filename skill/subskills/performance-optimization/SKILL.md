---
name: pharos-performance-optimization
description: "Find and reduce runtime, render, bundle, or gas inefficiencies in Pharos code paths. Use when optimizing performance, reducing gas costs, improving bundle size, fixing slow dapp UI, or reducing transaction latency in Pharos Solidity contracts and frontends. Keywords: performance, optimize, slow, bottleneck, bundle size, latency, gas optimization, speed up, reduce gas, Pharos, Solidity, Foundry, forge, Next.js, React, TypeScript, wagmi, viem, dapp."
metadata:
  audience: developer
  version: 1.1.0
  category: contract
slash: true
---

# Performance Optimization

Find and reduce runtime, render, bundle, or gas-adjacent inefficiencies in code paths on Pharos mainnet (chain 1672) where PHRS has no 2300 gas stipend and blocks finalize in ~2s.

## Pharos-Specific Gas Optimization

### Forge Gas Snapshots

```bash
# Generate baseline snapshot
forge snapshot --gas-report --fork-url https://rpc.pharos.xyz

# Compare after optimization
forge snapshot --diff --fork-url https://rpc.pharos.xyz
```

### PHRS Transfer Optimization

```solidity
// Before — 200k gas (full gas forwarded, no limit)
function unstake(uint256 amount) external {
    stakes[msg.sender] -= amount;
    (bool sent,) = payable(msg.sender).call{value: amount}("");
    require(sent);
}

// After — ~45k gas (capped gas + pull-over-push)
mapping(address => uint256) public pendingWithdrawals;

function unstake(uint256 amount) external {
    stakes[msg.sender] -= amount;
    pendingWithdrawals[msg.sender] += amount;
}

function withdraw() external {
    uint256 amount = pendingWithdrawals[msg.sender];
    pendingWithdrawals[msg.sender] = 0;
    (bool sent,) = payable(msg.sender).call{value: amount, gas: 10000}("");
    if (!sent) pendingWithdrawals[msg.sender] = amount;
}
```

### Storage Read Optimization (SLOAD)

```solidity
// Before — 3 SLOADs (2100 warm + 2x100 cold = 2300)
function getStake(address user) external view returns (uint256) {
    return stakes[user] + rewards[user]; // two separate mapping reads
}

// After — 1 SLOAD (pack into struct)
struct UserInfo { uint256 stake; uint256 rewards; }
mapping(address => UserInfo) public users;

function getStake(address user) external view returns (uint256) {
    UserInfo memory u = users[user]; // 1 SLOAD (warm: 100)
    return u.stake + u.rewards;
}
```

### Pharos-Specific Gas Table

| Operation | Gas (Pharos) | Optimization |
|-----------|-------------|--------------|
| PHRS transfer (no cap) | ~200k | Cap at 10k gas → ~45k |
| PHRS transfer (cap 10k) | ~45k | Use pull-over-push |
| SLOAD (cold) | 2100 | Cache in memory |
| SLOAD (warm) | 100 | Reuse cached values |
| SSTORE (0→non-zero) | 22100 | Batch writes |
| SSTORE (non-zero→non-zero) | 5000 | Minimize state changes |
| LOG0 | 375 + 8/byte | Emit only necessary data |
| LOG1 | 375 + 8/byte + 375 topic | Use indexed params |
| Contract deployment | ~200k-500k | Use constructor efficiently |

### Gas Report Example

```bash
forge test --gas-report --fork-url https://atlantic.dplabs-internal.com --match-contract PharosStaking
# Output:
# ╭──────────────────┬─────────────────┬──────┬────────┬──────┬─────────╮
# │ PharosStaking    │ Gas             │ Avg  │ Med    │ Min  │ Max     │
# ├──────────────────┼─────────────────┼──────┼────────┼──────┼─────────┤
# │ stake()          │ 46521           │ ...  │ ...    │ ...  │ ...     │
# │ unstake()        │ 45123           │ ...  │ ...    │ ...  │ ...     │
# │ withdraw()       │ 35211           │ ...  │ ...    │ ...  │ ...     │
# ╰──────────────────┴─────────────────┴──────┴────────┴──────┴─────────╯
```

## When to Use

performance, optimize, slow, bottleneck, bundle size, latency, gas optimization, too slow, speed up, reduce gas

## When NOT to Use

readability or structural improvements (use refactoring-and-code-health), or bug fixes (use bug-finding-and-debugging)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=https://atlantic.dplabs-internal.com` or `PHAROS_MAINNET_RPC=https://rpc.pharos.xyz` in your environment or `.env`.
- **Private key**: Set `PRIVATE_KEY` environment variable (keep this secret, never commit).
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification.
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Baseline metrics**: Gas snapshot or Lighthouse report before optimization.

## Workflow

1. Locate the performance bottleneck or suspected hot path.
2. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
3. Propose a measurable optimization strategy.
4. Show the plan and ask for approval before changes.
5. Implement the smallest change that improves the metric and verify it.

## Output

- bottleneck analysis
- optimization plan
- metric target
- verification result

## Examples

- "Optimize the unstake() function in the Pharos staking contract — PHRS has no 2300 stipend, cap gas at 10k"
- "Reduce storage reads in the Pharos reward distribution loop by caching SLOADs"
- "Use forge snapshot to compare gas costs before/after optimizing the Pharos vault contract"
- "Find gas optimization opportunities in this Pharos staking contract's hot loop using forge gas-report"
- "Optimize the React balance polling: increase refetchInterval from 3s to 10s given Pharos 2s block time"

## Verification

Before/after metric comparison (render time, bundle size, gas estimate). Use `forge snapshot --diff` for Solidity gas changes.

## Related

refactoring-and-code-health (non-performance structure changes), solidity-authoring (contract gas optimization)

## Gate


Medium risk. Show baseline metrics and proposed change before altering refetch policies, batching contract lists, or removing watches. Do not trade correctness (chain guard, post-tx freshness) for raw speed without user sign-off.
