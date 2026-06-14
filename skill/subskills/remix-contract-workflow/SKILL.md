---
name: pharos-remix-contract-workflow
description: "Set up Remix-based Pharos contract development, testing, and quick iteration flows. Use when using Remix IDE, browser-based Solidity, quick contract iteration, or online Solidity development for Pharos smart contracts. Keywords: Remix, browser Solidity, quick contract iteration, Remix workflow, Remix IDE, online Solidity, Pharos, smart contract, Solidity, quick prototype, test, MetaMask, inject provider, PharosScan, verify, remixd, custom RPC, chain ID, 688689, 1672."
metadata:
  audience: developer
  version: 1.2.0
  category: tooling
  slash: true
---

# Remix Contract Workflow

Set up Remix-based contract development, testing, and quick iteration flows.

## When to Use

Remix, browser Solidity, quick contract iteration, Remix workflow, Remix IDE, online Solidity, deploy to Pharos from Remix

## When NOT to Use

local development environment (use foundry-hardhat-contract-workflow), or production deployment (use deployment-and-verification)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: Private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Remix IDE**: Browser-based Solidity IDE at https://remix.ethereum.org with MetaMask connected.
- **RPC endpoint**: Pharos network configured in MetaMask (`https://atlantic.dplabs-internal.com` or `https://rpc.pharos.xyz`).
- **Private key**: Stored in MetaMask (keep this secret, never commit).
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification.
- **Network reachability**: Verify MetaMask shows the correct Pharos chain ID (1672 mainnet / 688689 testnet).
## Workflow

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Identify the contract task and Remix-specific constraints.
4. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
5. Choose the smallest workflow or file structure that fits the task.
6. Show the plan and proceed once it looks right.
7. Verify the result with a simple local or browser-based check.
## Output

- Remix plan
- file notes
- workflow steps
- verification suggestion

## Remix Environment Setup

In Remix IDE, select the **Environment** dropdown and choose **Injected Provider - MetaMask**. This connects Remix to MetaMask, which must already have the Pharos network configured.

## MetaMask Custom RPC Configuration

### Pharos Mainnet

| Field | Value |
|-------|-------|
| Network Name | Pharos Mainnet |
| RPC URL | https://rpc.pharos.xyz |
| Chain ID | 1672 |
| Currency Symbol | PHRS |

### Pharos Atlantic Testnet

| Field | Value |
|-------|-------|
| Network Name | Pharos Atlantic Testnet |
| RPC URL | https://atlantic.dplabs-internal.com |
| Chain ID | 688689 |
| Currency Symbol | PHRS |

Add these networks in MetaMask: Settings > Networks > Add Network > manually.

## Deployment Flow

1. Write or paste your Solidity contract in Remix file explorer.
2. Compile with the appropriate Solidity version (Solidity compiler tab).
3. Switch to the **Deploy & Run Transactions** tab.
4. Set **Environment** to **Injected Provider - MetaMask** (auto-detects Pharos network).
5. Confirm MetaMask connects to the correct Pharos network (check chain ID badge).
6. Select your compiled contract from the **Contract** dropdown.
7. Click **Deploy** and confirm the MetaMask transaction.
8. Wait for confirmation on Pharos (blocks finalize quickly).

## Gas and Finality on Pharos

- Pharos uses EIP-1559 fee model; base fee typically 1-10 gwei
- Block time ~2 seconds — transactions finalize within ~12 blocks (~24s)
- For Remix deploys, use Remix auto-estimate or set gas limit to ~3-5M for simple contracts

## Verification on PharosScan

After deployment from Remix:

1. Copy the deployed contract address from Remix.
2. Go to https://pharosscan.xyz and select the correct Pharos network.
3. Navigate to the contract address page.
4. Click **Verify and Publish**.
5. Enter the contract name, compiler version, and optimization settings matching your Remix compilation.
6. Paste the flattened Solidity source (or use the Remix **Flattener** plugin).
7. If your constructor has arguments, encode them:
   ```bash
   # Get constructor args from Remix (copy from "Deployed Contracts" section)
   # Or use cast to encode:
   cast abi-encode "constructor(uint256,address)" 1000000 0xRecipient
   ```
   Paste the encoded hex into the "Constructor Arguments" field on PharosScan.
8. Submit verification.

Alternatively, flatten in Remix using the **Flattener** plugin, then paste the single file.

## Common Remix Errors on Pharos

| Error | Cause | Fix |
|-------|-------|-----|
| "Gas estimation failed" | Insufficient gas limit for deployment | Increase gas manually in MetaMask or use Remix auto-estimate |
| "Nonce too low" | MetaMask nonce mismatch | Reset MetaMask account activity (Settings > Advanced > Clear activity tab data) |
| "Chain ID mismatch" | MetaMask on wrong network | Switch MetaMask to Pharos mainnet (1672) or testnet (688689) |
| "Execution reverted" | Constructor validation failed | Check constructor args and ensure sufficient PHRS balance |
| "Intrinsic gas too low" | Gas limit below 21000 floor | Remix usually handles this; if manual, set gas >= 21000 |
| "Already known" | Transaction resubmitted | Wait for pending tx to clear; check tx status on PharosScan |

## Verification

Manual check in Remix IDE, confirm tx on PharosScan, verify chain ID matches 1672 or 688689.

## Related

foundry-hardhat-contract-workflow (local alternative), framework-integration (config setup), deployment-and-verification (production deployments)

## Gate


Low risk for testnet prototyping. Do not deploy to mainnet (1672) or paste sensitive RPC URLs into Remix without explicit user approval.
