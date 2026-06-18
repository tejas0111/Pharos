---
name: pharos-foundry-hardhat-contract-workflow
description: "Set up Pharos Solidity development workflows for Foundry or Hardhat, including tests, scripts, and local runs with anvil. Use when configuring Foundry (forge/anvil/cast), Hardhat, forge test, hardhat test, forge script, or contract development workflows for Pharos blockchain. Keywords: Foundry, Hardhat, forge, anvil, cast, Solidity workflow, forge init, hardhat init, forge test, hardhat test, forge script, Pharos, 688689, 1672, contract development, foundry.toml, hardhat.config, pharos.json, PharosScan, etherscan, deploy script, chain ID."
metadata:
  audience: developer
  version: 1.2.0
  category: tooling
  slash: true
---

# Foundry and Hardhat Contract Workflow

Set up Solidity development workflows for Foundry or Hardhat, including tests, scripts, and local runs.

## When to Use

Foundry, Hardhat, forge, anvil, Solidity workflow, contract workflow, forge init, hardhat init, forge test, hardhat test, deploy to Pharos

## When NOT to Use

writing individual contracts (use solidity-authoring), or debugging build failures (use ci-and-build-troubleshooting)

## Prerequisites
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST verify `.env` exists and variables are set using `grep -q` (NEVER `cat`, `head`, `tail` — those expose secrets) before any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **Hardhat** (optional): `npx hardhat compile` must succeed if using Hardhat.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=$PHAROS_TESTNET_RPC_URL` or `PHAROS_MAINNET_RPC=$PHAROS_MAINNET_RPC_URL` in your environment or `.env`.
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification.
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
## Workflow
- **Strict .env Check**: Confirm `.env` exists with `test -f .env` and check variables via `grep -q` (without printing values). NEVER print `.env` contents. Do NOT proceed if missing or if the user suggests `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Identify the contract task and the local dev stack.
4. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
5. Choose the smallest Foundry or Hardhat workflow that fits the request.
6. Show the plan and proceed once it looks right.
7. Verify the workflow with the smallest useful command or file change.
## Output

- workflow plan
- script notes
- test notes
- verification command

## Foundry Configuration (foundry.toml)

Add RPC endpoints and PharosScan API for Pharos networks:

```toml
[rpc_endpoints]
pharos_mainnet = "$PHAROS_MAINNET_RPC_URL"
pharos_testnet = "$PHAROS_TESTNET_RPC_URL"

[etherscan]
pharos_mainnet = { key = "${PHAROSSCAN_API_KEY}", url = "$PHAROSSCAN_MAINNET_API_URL" }
pharos_testnet = { key = "${PHAROSSCAN_API_KEY}", url = "$PHAROSSCAN_TESTNET_API_URL" }
```

## Forge Script Examples

Select a fork before running scripts:

```solidity
// In your script:
vm.createSelectFork("pharos_testnet");
```

Deploy directly:

```bash
forge script script/Deploy.s.sol --rpc-url pharos_testnet --broadcast
forge script script/Deploy.s.sol --rpc-url pharos_mainnet --broadcast
```

## Deploy Script Template

```solidity
// script/Deploy.s.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MyContract} from "../src/MyContract.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MyContract contractInstance = new MyContract();

        vm.stopBroadcast();

        // Log Pharos chain ID for verification
        uint256 chainId = block.chainid;
        require(
            chainId == 1672 || chainId == 688689,
            string.concat("Unexpected chain ID: ", vm.toString(chainId))
        );
    }
}
```

## Chain ID Verification

Always verify the target chain ID before broadcasting:
- Pharos Mainnet: **1672**
- Pharos Atlantic Testnet: **688689**

```solidity
require(block.chainid == 688689, "Not Pharos Atlantic Testnet");
```

## Pharos Config Reference

The repo contains Pharos-specific deployment configs:

```
config/pharos.json
```

This file defines Pharos network parameters (RPC URLs, chain IDs, contract addresses) consumed by deploy scripts. Reference it for chain-agnostic deploy logic.

## Hardhat Configuration (hardhat.config.ts)

```typescript
import { HardhatUserConfig } from "hardhat/config";

const config: HardhatUserConfig = {
  networks: {
    pharosMainnet: {
      url: process.env.PHAROS_MAINNET_RPC_URL!,
      chainId: 1672,
      accounts: [process.env.PRIVATE_KEY!],
    },
    pharosTestnet: {
      url: process.env.PHAROS_TESTNET_RPC_URL!,
      chainId: 688689,
      accounts: [process.env.PRIVATE_KEY!],
    },
  },
  etherscan: {
    apiKey: {
      pharosMainnet: process.env.PHAROSSCAN_API_KEY!,
      pharosTestnet: process.env.PHAROSSCAN_API_KEY!,
    },
    customChains: [
      {
        network: "pharosMainnet",
        chainId: 1672,
        urls: {
          apiURL: "$PHAROSSCAN_MAINNET_API_URL",
          browserURL: "https://www.pharosscan.xyz",
        },
      },
      {
        network: "pharosTestnet",
        chainId: 688689,
        urls: {
          apiURL: "$PHAROSSCAN_TESTNET_API_URL",
          browserURL: "https://atlantic.pharosscan.xyz",
        },
      },
    ],
  },
};
```

Deploy with:

```bash
npx hardhat run scripts/deploy.ts --network pharosTestnet
npx hardhat run scripts/deploy.ts --network pharosMainnet
```

## Verification

forge test or npx hardhat test, then confirm chain ID during broadcast.

## Related

framework-integration (initial setup), solidity-authoring (writing contracts), deployment-and-verification (production deployments)

## Gate


Low risk. Present the plan and proceed once the user agrees.

### Anti-Generic Rules (foundry-hardhat-contract-workflow)
- Every deploy script step MUST name the script path (e.g., `script/Deploy.s.sol:Deploy`).
- Every forge command MUST include the specific test or script name (e.g., `forge test --match-contract StakingTest -vvv`).
- Verification MUST name the exact chain ID (688689 for testnet, 1672 for mainnet) and RPC URL.
- Before broadcast, MUST confirm `cast chain-id --rpc-url <name>` matches the target.
- Do NOT hardcode private keys — use `$PRIVATE_KEY` env var with explicit warning.
- Every foundry.toml change MUST name the specific section and fields added.
