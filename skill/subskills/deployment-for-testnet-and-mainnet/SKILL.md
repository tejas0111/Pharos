---
name: pharos-deployment-for-testnet-and-mainnet
description: "Plan and validate Pharos contract deployments across Atlantic Testnet (688689) and mainnet (Pacific 1672) with environment-aware safeguards and release checklists. Use when planning testnet vs mainnet deployment strategy, release checklists, environment safeguards, or network-specific deployment flows for Pharos. Keywords: testnet, mainnet, deployment, release, deploy flow, Pharos, Pacific, 688689, 1672, Foundry, Hardhat, forge script, hardhat deploy, environment-aware, safeguards, checklist."
metadata:
  audience: developer
  version: 1.1.0
  category: deployment
  slash: true
---

# Deployment for Testnet and Mainnet

Use when the user needs a safe deployment plan for both Pharos networks.

## Network Comparison

| Property         | Mainnet (Pacific)       | Atlantic Testnet               |
|------------------|-------------------------|--------------------------|
| Chain ID         | 1672                    | 688689                   |
| RPC URL          | https://rpc.pharos.xyz | https://atlantic.dplabs-internal.com |
| Explorer         | https://pharosscan.xyz   | https://pharosscan.xyz     |
| Block time       | ~2s                     | ~2s                      |
| PHRS price       | market                  | faucet (free)            |
| Deploy risk      | high (real value)       | low (test environment)   |

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

```bash
# .env
PRIVATE_KEY=0x...
PHAROSSCAN_API_KEY=...
```

## Concrete Deploy Commands

### foundry.toml

```toml
[rpc_endpoints]
pharos_mainnet = "https://rpc.pharos.xyz"
pharos_testnet = "https://atlantic.dplabs-internal.com"

[etherscan]
pharos_mainnet = { key = "${PHAROSSCAN_API_KEY}", url = "https://www.pharosscan.xyz/api" }
pharos_testnet = { key = "${PHAROSSCAN_API_KEY}", url = "https://atlantic.pharosscan.xyz/api" }
```

### Deploy Script (DeployPharosStaking.s.sol)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {PharosStaking} from "../src/PharosStaking.sol";

contract DeployPharosStaking is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        uint256 chainId = block.chainid;
        require(chainId == 1672 || chainId == 688689, "Wrong chain");

        address deployer = vm.addr(pk);
        vm.startBroadcast(pk);

        PharosStaking staking = new PharosStaking(/* constructor args */);

        vm.stopBroadcast();

        console.log("Deployed at:", address(staking));
        console.log("Chain ID:", chainId);
    }
}
```

### Testnet Deploy

```bash
# Dry run first
forge script script/DeployPharosStaking.s.sol --rpc-url pharos_testnet --sender $DEPLOYER

# Broadcast
forge script script/DeployPharosStaking.s.sol --rpc-url pharos_testnet --broadcast --sender $DEPLOYER

# Verify on PharosScan
forge verify-contract \
  --chain-id 688689 \
  --verifier custom \
  --verifier-url https://pharosscan.xyz/api \
  --etherscan-api-key $PHAROSSCAN_API_KEY \
  --constructor-args $(cast abi-encode "constructor(uint256,address)" 1000000 0xRecipient) \
  0xDeployedAddress src/PharosStaking.sol:PharosStaking
```

### Mainnet Deploy (with Multi-Sig)

```bash
# Simulate
forge script script/DeployPharosStaking.s.sol --rpc-url pharos_mainnet --sender $DEPLOYER --slow

# Broadcast
forge script script/DeployPharosStaking.s.sol --rpc-url pharos_mainnet --broadcast --slow

# Transfer ownership to Safe
cast send --rpc-url https://rpc.pharos.xyz --chain-id 1672 \
  0xDeployedAddress "transferOwnership(address)" 0xPharosSafeAddress \
  --private-key $PRIVATE_KEY

# Verify
forge verify-contract \
  --chain-id 1672 \
  --verifier custom \
  --verifier-url https://pharosscan.xyz/api \
  --etherscan-api-key $PHAROSSCAN_API_KEY \
  --constructor-args $(cast abi-encode "constructor(uint256,address)" 1000000 0xRecipient) \
  0xDeployedAddress src/PharosStaking.sol:PharosStaking
```

## Release Checklist

### Atlantic Testnet (688689)

- [ ] Atlantic Testnet (688689) deployment complete via `forge script script/Deploy.s.sol --rpc-url pharos_testnet --broadcast --sender $DEPLOYER`
- [ ] Contract verified on PharosScan: `forge verify-contract --chain-id 688689 --verifier custom --verifier-url https://atlantic.pharosscan.xyz/api --etherscan-api-key $PHAROSSCAN_API_KEY 0xDeployed src/Contract.sol:Contract`
- [ ] Integration tests passed against testnet deployment: `forge test --fork-url https://atlantic.dplabs-internal.com`
- [ ] Testnet deployment artifacts committed

### Mainnet (1672)

- [ ] Mainnet (1672) deployment simulated with `forge script script/Deploy.s.sol --rpc-url pharos_mainnet --sender $DEPLOYER --slow`
- [ ] Multi-sig owners confirmed for mainnet (Pharos Safe: 0x41675C099F32341bf84BFc5382aF534df5C7461a)
- [ ] PHRS gas budget estimated for mainnet deploy (check current gas price: `cast gas-price --rpc-url https://rpc.pharos.xyz`)
- [ ] Deployer wallet funded with enough PHRS (estimated + 20% buffer)
- [ ] Mainnet deployment executed via `forge script script/Deploy.s.sol --rpc-url pharos_mainnet --broadcast --slow`
- [ ] Contract verified: `forge verify-contract --chain-id 1672 --verifier custom --verifier-url https://www.pharosscan.xyz/api --etherscan-api-key $PHAROSSCAN_API_KEY --constructor-args $(cast abi-encode "constructor(uint256)" 1000000) 0xDeployed src/Contract.sol:Contract`

## Release Flow

```
testnet deploy (688689)
  -> verify on testnet PharosScan
  -> run integration tests
  -> staging review / QA sign-off
  --> mainnet dry-run (1672)
    -> multi-sig approval
    -> mainnet broadcast
    -> verify on PharosScan
    -> frontend config update
```

## Rollback Plan

- Keep deployer wallet funded with at least enough PHRS for one emergency re-deploy
- Maintain previous deployment artifacts for quick revert
- If mainnet deploy fails mid-transaction: wait for revert, fix issue, re-deploy
- If verified contract has a bug: deploy new version, update frontend config, verify new address

## When NOT to Use

- **Single deployment** — For deploying to just one network, use `deployment-and-verification`.
- **Simple verification** — For just verifying a contract on PharosScan, use `post-deploy`.
- **Multi-chain bridge** — For cross-chain deployments, use `cross-chain-bridge`.

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

1. Identify the target network, deployment artifact, and release assumptions.
2. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
3. Separate testnet validation from mainnet release steps using the checklist.
4. Show the deployment plan and ask for explicit approval.
5. Use the smallest safe verification step after deployment.

## Output

- network plan with chain IDs and RPC URLs
- deployment steps per network
- release checklist with Pharos-specific items
- verification checklist for PharosScan
- rollback plan with PHRS reserve

## Verification

High risk. Do not change deployment behavior before approval.

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the network-specific deployment scripts, foundry.toml config, .env template, and CI pipeline — show commands for both networks
- Do NOT wait for approval to draft — show everything in your response before asking for confirmation

**Phase 2 — Execute (wait for approval):**
- Do NOT Broadcast to testnet or mainnet, change deploy scripts, modify constructor args, or spend real funds
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions