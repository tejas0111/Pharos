---
name: pharos-rwa-compliance
description: "Implement Real-World Asset (RWA) patterns on Pharos: whitelist-based transfer control (ERC-3643 on Pharos), stablecoin depeg protection (oracle-triggered circuit breaker), redemption queues, liquidity reserves (5-10% buffer), NAV-based pricing, legal isolation (SPV), Supra DORA + Chainlink oracles. Pharos-specific KYC/AML registry, Pharos RWA token standard, PharosScan compliance monitoring. Use when tokenizing real-world assets or configuring RWA compliance on Pharos. Keywords: RWA, real-world asset, tokenized asset, stablecoin, depeg protection, circuit breaker, whitelist transfer, redemption queue, liquidity reserve, NAV pricing, SPV, legal isolation, Supra DORA, compliance, transfer restriction, KYC, accredited investor, security token, regulated token, MiCA, SEC, Pharos RWA, ERC-3643 Pharos, Pharos KYC registry, PharosScan compliance, Pharos jurisdiction, on-chain verification flow."
metadata:
  audience: developer
  version: 1.2.0
  category: rwa
slash: true
---

# RWA Compliance

Implement Real-World Asset (RWA) patterns on Pharos: whitelist-based transfer control, stablecoin depeg protection, redemption queues, liquidity reserves, NAV-based pricing, legal isolation.

## When to Use

RWA, real-world asset, tokenized asset, stablecoin, depeg protection, circuit breaker, whitelist transfer, redemption queue, liquidity reserve, NAV pricing, SPV, legal isolation, Supra DORA, compliance, transfer restriction, KYC, accredited investor, security token, regulated token, MiCA, SEC, Pharos RWA, ERC-3643 Pharos, Pharos KYC registry, PharosScan compliance, Pharos jurisdiction, on-chain verification flow

## When NOT to Use

- **Standard ERC-20/721 development** — If the user needs a plain token without whitelist transfers or compliance restrictions, use `solidity-authoring`.
- **DeFi protocol design** — If the user is building a DEX, lending pool, or yield aggregator without RWA-specific features, use `contract-architecture`.
- **Security review** — If the user wants a formal vulnerability assessment, use `security-audit` (which can review RWA contracts separately).
- **Stablecoin without RWA backing** — If the user wants a simple algorithmic or over-collateralized stablecoin (e.g., CDP-style) without real-world asset backing, use `contract-architecture`.
- **KYC/off-chain identity** — If the user needs an off-chain identity or KYC provider integration (not on-chain whitelist enforcement), route to `contract-architecture` or a dedicated identity subskill.

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: Private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=https://atlantic.dplabs-internal.com` or `PHAROS_MAINNET_RPC=https://rpc.pharos.xyz` in your environment or `.env`.
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification.
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
## Workflow

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
4. Show the plan and ask for approval before implementing.
### 1. Whitelist Transfer Control

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPharosKYC {
    function isVerified(address account) external view returns (bool);
    function isWhitelisted(address account, uint256 jurisdictionId) external view returns (bool);
}

contract RWACompliance {
    error NotWhitelisted(address account);
    address public kycRegistry; // Deployed Pharos KYC/AML registry

    modifier onlyWhitelisted(address from, address to, uint256 jurisdictionId) {
        if (to != address(0) && !IPharosKYC(kycRegistry).isWhitelisted(to, jurisdictionId))
            revert NotWhitelisted(to);
        _;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal onlyWhitelisted(from, to, 1) {}
}
```

Note: PHRS has no 2300 gas stipend — ensure `.call{value:}` in redemption uses capped gas (10,000).

### 2. Stablecoin Depeg Protection

```solidity
interface IPriceFeed {
    function latestAnswer() external view returns (int256);
    function latestTimestamp() external view returns (uint256);
}

contract DepegCircuitBreaker {
    IPriceFeed public supraDORA;  // Supra DORA oracle on Pharos
    IPriceFeed public chainlink;  // Chainlink oracle on Pharos
    uint256 constant THRESHOLD = 2e16; // ±2%
    bool public paused;

    modifier whenNotPaused() { require(!paused, "Paused"); _; }

    function checkPeg() external {
        (uint256 supraPrice, uint256 clPrice) = (getPrice(supraDORA), getPrice(chainlink));
        uint256 deviation = supraPrice > clPrice ? supraPrice - clPrice : clPrice - supraPrice;
        if (deviation * 1e18 / supraPrice > THRESHOLD) paused = true;
    }
}
```

### 3. Redemption Queue (Pull-over-Push)

```solidity
contract RedemptionQueue {
    struct Request { address user; uint256 amount; uint256 timestamp; }
    Request[] public queue;
    uint256 public constant COOLDOWN = 1 days;
    uint256 public constant RESERVE_RATIO = 500; // 5% (basis points)

    function requestRedeem(uint256 amount) external {
        queue.push(Request(msg.sender, amount, block.timestamp));
    }

    function processNext() external {
        require(queue.length > 0, "Empty queue");
        Request memory r = queue[0];
        require(block.timestamp >= r.timestamp + COOLDOWN, "Cooldown");
        (bool sent,) = payable(r.user).call{value: r.amount, gas: 10000}("");
        require(sent, "PHRS transfer failed");
        // shift queue
        for (uint i = 0; i < queue.length - 1; i++) queue[i] = queue[i + 1];
        queue.pop();
    }
}
```

## Output

- whitelist transfer control contract (compliance module) integrating Pharos KYC/AML registry
- stablecoin depeg circuit breaker (oracle integration with Pharos oracle addresses)
- redemption queue contract
- liquidity reserve management contract
- NAV pricing oracle integration
- SPV isolation contract
- ERC-3643 RWA token contract (Pharos RWA standard)
- on-chain verification flow documentation
- PharosScan compliance monitoring setup
- deployment and configuration guide

## Examples

- **Query:** "Implement a whitelist-based transfer control for a tokenized real estate fund" → **Action:** Build compliance module with `_beforeTokenTransfer` hook checking whitelist from Pharos KYC registry (`IPharosKYC` interface), deploy role-based access control with compliance officer role, write test for whitelisted and non-whitelisted transfers. Use ERC-3643 standard on Pharos for jurisdiction-aware transfer restrictions.
- **Query:** "Add stablecoin depeg protection with Supra DORA and Chainlink oracles" → **Action:** Integrate dual oracle feeds via `IPriceFeed` interface, configure depeg threshold (±2%), implement circuit breaker that pauses mint/redeem, add re-peg detection for automatic resumption.
- **Query:** "Design a redemption queue with liquidity reserve buffer on Pharos" → **Action:** Build FIFO queue with cooldown period, proportional redemption logic for liquidity shortfalls, capped PHRS `.call{gas: 10000}` to prevent reentrancy, set reserve rebalancing triggers at 5-10% of total supply.
- **Query:** "Set up NAV-based pricing for an RWA token on Pharos mainnet" → **Action:** Integrate on-chain NAV feed from trusted oracle, implement `convertToShares`/`convertToAssets` with NAV, configure grace period for oracle staleness, add fallback pricing mechanism.
- **Query:** "Structure an SPV legal isolation wrapper for on-chain assets under Pharos jurisdiction" → **Action:** Deploy SPV contract as legal wrapper for off-chain assets, configure asset segregation, document role of SPV in legal structure, integrate with compliance module for accredited investor checks.
- **Query:** "Set up on-chain KYC verification before minting an RWA token" → **Action:** Build verification flow: wallet submits KYC to Pharos KYC registry → registry returns verification status → compliance contract checks `kycRegistry.isVerified(wallet)` → if verified, whitelist and mint RWA token. Monitor events via PharosScan API.

## Verification

Deploy on Pharos Atlantic Testnet (688689) with mock compliance roles. Test whitelist transfer restriction (non-whitelisted addresses cannot receive). Simulate depeg event and verify circuit breaker triggers. Test redemption queue processing order and reserve ratio enforcement. Verify on-chain flow: wallet → KYC check → whitelist → mint → PharosScan event tracking.

## Related

contract-architecture (system design), security-audit (compliance security review), upgrade-patterns (RWA contract upgrades)


## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the `PLAN.md` with the full implementation strategy, environment-aware safeguards, and verification steps.
- Wait for explicit 'Approve' or 'Proceed' from the user.

**Phase 2 — Execute (wait for approval):**
- Execute the approved plan from `PLAN.md`.
- Do NOT Deploy whitelist controls, modify transfer logic, change compliance parameters, or send onchain transactions
- Perform a final "Ready to Broadcast?" check for any high-risk on-chain actions.
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions.