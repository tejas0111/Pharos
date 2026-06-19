---
name: pharos-testing-strategy
description: "Design Pharos-specific test pyramid (Foundry unit, testnet fork integration, mainnet fork e2e) with coverage targets per SolAid/PharosScan, edge cases for Pharos chain reorg depth, PHRS gas price volatility, and cross-chain bridge tests. Use when planning test strategy, coverage goals, edge cases, or test plans for Pharos Solidity dapps and frontend integrations. Keywords: test strategy, coverage, fixtures, edge cases, test plan, test approach, Pharos, Solidity, Foundry, Hardhat, wagmi, viem, contract testing, dapp testing, integration testing, reorg, bridge, PHRS, gas price."
metadata:
  audience: developer
  version: 1.2.0
  category: testing
  slash: true
---

# Testing Strategy

Choose the right test mix, fixtures, and coverage focus before writing tests.

## When to Use

test strategy, coverage, fixtures, edge cases, test plan, what should I test, test approach, test coverage plan

## When NOT to Use

writing concrete tests (use test-generation), or running tests (that's a CI task, not a subskill)

## Prerequisites
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST verify `.env` exists and variables are set using `grep -q` (NEVER `cat`, `head`, `tail` — those expose secrets) before any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=$PHAROS_TESTNET_RPC_URL` or `PHAROS_MAINNET_RPC=$PHAROS_MAINNET_RPC_URL` in your environment or `.env`.
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification (https://www.pharosscan.xyz).
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Foundry config**: `foundry.toml` should have `[rpc_endpoints]` section with `pharos_testnet` and `pharos_mainnet` entries.
## Pharos-Specific Test Pyramid

1. **Unit (Foundry)** – Test individual contract functions with `forge test`. Use Pharos fixtures (PHRS token addresses, test accounts). Assert chain ID (1672 / 688689), block time ~2s.
2. **Integration (testnet fork)** – Fork Pharos testnet with `vm.createSelectFork("pharos_testnet")`. Test multi-contract interactions, cross-contract calls, PHRS transfers.
3. **E2E (mainnet fork)** – Fork Pharos mainnet with `vm.createSelectFork("pharos_mainnet", blockNumber)`. Simulate real user flows, bridge transactions, oracle price feeds.

## Foundry Config for Testing

```toml
# foundry.toml
[fuzz]
runs = 1000
max_test_rejects = 10000

[invariant]
runs = 256
depth = 16

[rpc_endpoints]
pharos_mainnet = "$PHAROS_MAINNET_RPC_URL"
pharos_testnet = "$PHAROS_TESTNET_RPC_URL"
```

```bash
# Coverage
forge coverage --fork-url $PHAROS_TESTNET_RPC_URL --report lcov
# Gas report
forge test --gas-report --fork-url $PHAROS_TESTNET_RPC_URL
```

## Pharos Coverage Targets

- SolAid integration: 90%+ branch coverage for core logic
- PharosScan verification: verify contract source after deploy as part of CI
- All public/external functions: 100% called in at least one test
- Revert paths: test all require/assert failures

## Pharos-Specific Edge Cases

### Chain Reorg Depth
Pharos finality may differ from Ethereum. Test that contract state is resilient to reorg depths of 1-2 blocks. Use `vm.roll()` to simulate reorg scenarios.

### PHRS Gas Price Volatility
PHRS gas prices can spike. Test that `tx.gasprice` assumptions hold within a realistic range (e.g., 1-100 gwei). Use `vm.txGasPrice()` to set gas price in tests.

### Cross-Chain Bridge Tests
If your dapp bridges assets, test:
- Deposit on source chain (fork test)
- Claim on Pharos (fork test)
- Relayer failure / timeout recovery
- Event emission format matches bridge expectations

## Workflow
- **Strict .env Check**: Confirm `.env` exists with `test -f .env` and check variables via `grep -q` (without printing values). NEVER print `.env` contents. Do NOT proceed if missing or if the user suggests `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Identify the contract, UI, or integration risks that matter most.
4. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
5. Choose unit, integration, and regression coverage appropriately.
6. Map Pharos-specific risks (reorg, gas price, bridge) to test layers.
7. Present the testing plan with explicit assumptions.
8. Wait for confirmation before generating tests or fixtures.
## Output

- test matrix
- fixture plan
- coverage goals
- regression checklist

## Examples

- "Design the test strategy for a Pharos staking contract on testnet 688689"
- "Plan coverage for PHRS stake → claim → unstake flow on Pharos"
- "Plan test coverage for a Pharos upgradeable vault with reorg-depth and PHRS gas price edge cases"
- "Plan a Pharos-specific test strategy covering reorg depth and PHRS gas volatility"

## Verification

Review of the test matrix. No test files yet.

## Related

test-generation (execution), contract-testing-for-testnet-and-mainnet (network-aware tests)

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the `PLAN.md` with the full implementation strategy, environment-aware safeguards, and verification steps.
- Wait for explicit 'Approve' or 'Proceed' from the user.

**Phase 2 — Execute (wait for approval):**
- Execute the approved plan from `PLAN.md`.
- Do NOT Generate tests, write test files, or modify test fixtures
- Perform a final "Ready to Broadcast?" check for any high-risk on-chain actions.
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions.
## Contract-Specific Test Coverage

### PharosLendingPool
- **Unit:** `test/PharosLendingPool.t.sol` — supply, borrow, liquidate, interest accrual
- **Fuzz:** Random amounts within [1, 1000] ETH for supply/borrow
- **Edge:** Zero-amount reverts, max capacity reached, liquidation at boundary

### DEXPool
- **Unit:** `test/DEXPool.t.sol` — addLiquidity, removeLiquidity, swap
- **Invariant:** `k = reserveA * reserveB` must never decrease after swap
- **Edge:** Swap with zero liquidity, excessive slippage

### StakingPool
- **Unit:** `test/StakingPool.t.sol` — stake, withdraw, claimRewards
- **Fuzz:** Random stake durations [1 hour, 30 days]
- **Edge:** Withdraw during lock period, reward calculation after rate change

### PharosERC20
- **Invariant:** `test/PharosERC20Invariants.t.sol` — total supply never exceeds cap
- **Handler:** `test/PharosERC20Handler.sol` — fuzzed transfers, approvals, mints

### PharosSPNPaymaster
- **Unit:** `test/PharosSPNPaymaster.t.sol` — whitelist, budget checks, pause
- **Edge:** Budget exhaustion, non-whitelisted sender, paused state

### PharosZkLogin
- **Unit:** `test/PharosZkLogin.t.sol` — identity registration, key lifecycle
- **Edge:** Duplicate commitment, expired ephemeral key, key revocation

## MCP Tool Testing

Behavioral MCP tests in `mcp-server/test-behavioral.mjs` validate:
- Tool registration (all 26+ tools present with valid schemas)
- `network_config` returns chain IDs
- `check_balance` handles valid and invalid addresses
- `gas_estimate` returns reasonable estimates
- Error handling for unknown tools

Run: `node --test mcp-server/test-behavioral.mjs`

## References

- `test/` — All test files
- `test/PharosERC20Invariants.t.sol` — Invariant testing pattern
- `test/PharosERC20Handler.sol` — Handler-based fuzzing
- `mcp-server/test-behavioral.mjs` — MCP behavioral tests
- Forge docs: `forge test --gas-report`, `forge test --fuzz-seed`
