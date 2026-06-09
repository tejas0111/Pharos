---
name: pharos-contract-testing-for-testnet-and-mainnet
description: "Design Pharos contract test coverage with testnet fork (688689) and mainnet fork (1672) setups, chain-specific test suites via --match-test, deploy-and-test forge script workflows, and PharosScan verification in CI. Use when planning network-specific testing, fork tests, environment-aware test suites, or testnet vs mainnet contract validation for Pharos. Keywords: contract testing, testnet tests, mainnet tests, fork tests, network fork, Pharos, 688689, 1672, Foundry, forge, anvil, environment-aware, integration testing, PharosScan."
metadata:
  audience: developer
  version: 1.1.0
  category: testing
  slash: true
---

# Contract Testing for Testnet and Mainnet

Design contract test coverage and environment-aware checks for both network contexts.

## When to Use

contract testing, testnet tests, mainnet tests, network-specific testing, environment-aware tests, fork tests, network fork

## When NOT to Use

general unit test generation (use test-generation), or planning deployment (use deployment-for-testnet-and-mainnet)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=https://atlantic.dplabs-internal.com` or `PHAROS_MAINNET_RPC=https://rpc.pharos.xyz` in your environment or `.env`.
- **Private key**: Set `PRIVATE_KEY` environment variable (keep this secret, never commit).
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification (https://pharosscan.xyz).
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Foundry config**: `foundry.toml` should have `[rpc_endpoints]` section with `pharos_testnet` and `pharos_mainnet` entries.

## Pharos Fork Test Setup

### Pharos Mainnet Fork

```solidity
// Fork Pharos mainnet (Pacific, chain ID 1672) at a specific block
uint256 constant MAINNET_BLOCK = 1_234_567; // pin to stable block
vm.createSelectFork("pharos_mainnet", MAINNET_BLOCK);
```

### Pharos Testnet Fork

```solidity
// Fork Pharos Atlantic Testnet (chain ID 688689)
vm.createSelectFork("pharos_testnet");
```

### foundry.toml for Named RPCs

```toml
[rpc_endpoints]
pharos_mainnet = "https://rpc.pharos.xyz"
pharos_testnet = "https://atlantic.dplabs-internal.com"
```

### Chain-Skip Helper

```solidity
modifier skipIfNotNetwork(uint256 targetChainId) {
    if (block.chainid != targetChainId) return;
    _;
}

function testMainnet_Stake() public skipIfNotNetwork(1672) {
    // only runs on mainnet fork
}

function testTestnet_Stake() public skipIfNotNetwork(688689) {
    // only runs on testnet fork
}
```

### CI Matrix for Both Networks

```yaml
# .github/workflows/test.yml
name: Pharos Contract Tests
on: [push]
jobs:
  test:
    strategy:
      matrix:
        network: [pharos_mainnet, pharos_testnet]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: foundry-rs/foundry-toolchain@v1
      - run: forge install --no-commit || true
      - run: forge test --fork-url ${{ matrix.network }} -vvv
```

### Hardhat Fork Config

```typescript
// hardhat.config.ts
networks: {
  pharosMainnet: {
    url: "https://rpc.pharos.xyz",
    chainId: 1672,
  },
  pharosTestnet: {
    url: "https://atlantic.dplabs-internal.com",
    chainId: 688689,
  },
}
```

## Chain-Specific Test Suites

Run subset of tests against a specific network using Foundry's `--match-test`:

```bash
# Run only mainnet-specific tests
forge test --match-test testMainnet* --fork-url https://rpc.pharos.xyz

# Run only testnet-specific tests
forge test --match-test testTestnet* --fork-url https://atlantic.dplabs-internal.com

# Run all Pharos tests
forge test --match-contract PharosTest
```

## Deploy-and-Test Workflow

1. Deploy contract with `forge script` to testnet or mainnet.
2. Write a fork test that loads the deployed contract at its on-chain address.
3. Assert deployed state, owner, initial parameters.
4. Run interactions and verify state changes against the fork.

```solidity
address deployed = vm.envAddress("DEPLOYED_CONTRACT");
MyContract c = MyContract(deployed);
assertEq(c.owner(), expectedOwner);
```

## PharosScan Verification in CI Pipeline

After deploying to Pharos testnet or mainnet, verify source code on PharosScan as part of CI:

```bash
# In CI workflow
forge verify-contract <address> src/MyContract.sol:MyContract \
  --chain-id <chainId> \
  --verifier-url https://pharosscan.xyz/api \
  --etherscan-api-key $PHAROSSCAN_API_KEY

# Then fork-test against the verified contract
forge test --match-test testVerified* \
  --fork-url https://atlantic.dplabs-internal.com
```

## Workflow

1. Separate local unit coverage from network-aware checks.
2. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
3. Plan how testnet and mainnet constraints differ (block time, gas price, finality).
4. Choose fork URL and block number for each network context.
5. Write chain-specific test files with `testMainnet`/`testTestnet` prefix convention.
6. Include deploy-and-verify step in CI after deployment.
7. Show the test plan and ask for approval before generating tests.

## Output

- test matrix
- network coverage plan
- fixture notes
- verification command

## Examples

- "Design contract tests that cover both Pharos testnet (688689) and mainnet (1672) assumptions with skipIfNotNetwork helper"
- "Plan the network-specific test checks for this Pharos deployment flow using CI matrix"
- "Write fork tests that validate mainnet behavior against a local fork pinned at block 1,234,567"
- "Set up Pharos mainnet and testnet fork tests with PharosScan CI verification and --match-test testMainnet/testTestnet"
- "Add a CI matrix that runs forge test against both pharos_mainnet and pharos_testnet RPC endpoints"

## Verification

forge test --fork-url pharos_mainnet or pharos_testnet. CI matrix runs both.

## Related

testing-strategy (general planning), deployment-for-testnet-and-mainnet (deploy counterpart)

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the full test matrix with fork URLs, network-specific assertions (chain IDs 1672/688689), and CI pipeline config for both testnet and mainnet
- Do NOT wait for approval to draft — show the complete test plan in your response before asking for confirmation

**Phase 2 — Execute (wait for approval):**
- Do NOT generate network-aware tests, run fork tests that spend real funds, or modify test configuration
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before generating any test files or running fork tests