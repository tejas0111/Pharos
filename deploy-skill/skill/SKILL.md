---
name: pharos-agent-deploy-suite
description: "High-risk Pharos deployment suite for broadcasting and verifying contracts on testnet (Atlantic, chain ID: 688689) and mainnet (Pacific, chain ID: 1672). Use when deploying, broadcasting, verifying, or simulating Pharos contract deployments with Foundry or Hardhat, or when configuring RPC, signers, post-deploy checks, and explorer interactions. Keywords: deploy, broadcast, verify, testnet, mainnet, RPC, explorer, forge script, hardhat deploy, PHAROS_TESTNET_RPC_URL, PHAROS_MAINNET_RPC_URL, PRIVATE_KEY, ETHERSCAN_API_KEY, simulate, dry-run, gas estimation, signer, nonce, release, go live, production, Atlantic, Pacific, 688689, 1672, PROS, PHRS, fund, faucet, forge create, forge script, broadcast transaction, contract verification, deployment."
slash: true
metadata:
  audience: developer
  version: 1.0.0
  category: workflow
---

# Pharos Agent Deploy Suite

High-risk deployment skill for broadcasting and verifying Pharos contracts on testnet (Atlantic, chain ID: 688689) and mainnet (Pacific, chain ID: 1672). **Every broadcast requires explicit approval.** No exceptions.

## Quick Start

```
You: "Deploy this contract to Pharos testnet"
 → Routes to testnet-deployment subskill
 → Pre-flight: validate RPC, chain ID, deployer balance, simulation
 → Present plan → wait for approval → broadcast → verify

You: "Deploy to mainnet"
 → Routes to mainnet-deployment subskill
 → Pre-flight: all testnet checks + mainnet banner warning
 → Present plan → wait for explicit approval → broadcast → verify

You: "Verify the deployed contract"
 → Routes to appropriate verify script
 → Presents explorer link and verification result
```

## Quick Reference

| Rule | Detail |
|---|---|
| Simulate before broadcast | Run simulation/dry-run first on every deployment |
| Testnet before mainnet | Default to testnet unless user explicitly requests mainnet |
| Explicit approval required | Every broadcast, mainnet or testnet, must be approved |
| No invented config | Never guess RPC URLs, chain IDs, private keys, or API endpoints |
| Use existing scripts | Prefer repo's deploy scripts or bundled templates over new flows |
| Pre-flight checklist | Run before every broadcast (see Pre-Flight section) |

## When to Use

Trigger when the user says any of:

```
deploy • broadcast • forge script • forge create • hardhat deploy
verify • explorer • testnet • mainnet • RPC URL • private key • signer
deployment • release to mainnet • testnet rehearsal • go live • production
simulate • dry-run • gas estimation • nonce • deploy and verify
claim • faucet • get testnet tokens
```

Do NOT trigger for: writing contracts, testing, debugging, frontend work, architecture review, or any development task — route those to `pharos-agent-dev-suite`.

## Script Selection Decision Tree

Choose the correct script by answering these questions in order:

```
1. Which toolchain does the repo use?
   ├── foundry.toml exists, or user mentions "forge"     → Foundry scripts
   ├── hardhat.config.* exists, or user mentions "hardhat" → Hardhat scripts
   └── Neither or unknown → Ask the user: "Are you using Foundry or Hardhat?"

2. Which network?
   ├── User says "testnet", "test", "dry-run", or nothing → testnet
   └── User says "mainnet", "production", "release"       → mainnet

3. Is this a simulation or a real broadcast?
   ├── First deploy, or user says "simulate", "dry-run", "check"  → SIMULATE_ONLY=1
   ├── User says "deploy", "broadcast", "send"                     → broadcast
   └── User says "verify only"                                     → verify script

4. Does the user want verification?
   ├── User says "verify", "explorer", or nothing after deploy     → set VERIFY=1
   └── User says "skip verify", "no explorer"                      → VERIFY=0
```

### Script Table

| Situation | Script |
|---|---|
| Foundry + testnet + simulate | `SIMULATE_ONLY=1 ./scripts/deploy-testnet.sh` |
| Foundry + testnet + broadcast | `./scripts/deploy-testnet.sh` |
| Foundry + testnet + broadcast + verify | `VERIFY=1 ./scripts/deploy-testnet.sh` |
| Foundry + mainnet + simulate | `SIMULATE_ONLY=1 ./scripts/deploy-mainnet.sh` |
| Foundry + mainnet + broadcast | `./scripts/deploy-mainnet.sh` |
| Foundry + mainnet + broadcast + verify | `VERIFY=1 ./scripts/deploy-mainnet.sh` |
| Hardhat + testnet + deploy | `./scripts/deploy-testnet-hardhat.sh` |
| Hardhat + mainnet + deploy | `./scripts/deploy-mainnet-hardhat.sh` |
| Hardhat + testnet + verify | `DEPLOYED_ADDRESS=0x... ./scripts/verify-testnet-hardhat.sh` |
| Hardhat + mainnet + verify | `DEPLOYED_ADDRESS=0x... ./scripts/verify-mainnet-hardhat.sh` |

## Foundry Config for Pharos

To use the bundled Foundry scripts, your `foundry.toml` should include:

```toml
[profile.default]
src = "contracts"
out = "out"
libs = ["lib"]
solc_version = "0.8.26"
evm_version = "cancun"

[rpc_endpoints]
pharos-mainnet = "https://rpc.pharos.xyz"
pharos-testnet = "https://atlantic.dplabs-internal.com"
pharos-testnet-v2 = "https://testnet.dplabs-internal.com"
pharos-devnet = "https://devnet.dplabs-internal.com"

[etherscan]
pharos-mainnet = { key = "${ETHERSCAN_API_KEY}" }
pharos-testnet = { key = "${ETHERSCAN_API_KEY}" }
pharos-testnet-v2 = { key = "${ETHERSCAN_API_KEY}" }
```

The `[rpc_endpoints]` section is optional but recommended — it lets you run `forge script --rpc-url pharos-testnet` without setting the env var.

## Hardhat Config for Pharos

To use the bundled Hardhat scripts, your `hardhat.config.ts` should include:

```typescript
const PHAROS_TESTNET_RPC = process.env.PHAROS_TESTNET_RPC_URL || 'https://atlantic.dplabs-internal.com';
const PHAROS_MAINNET_RPC = process.env.PHAROS_MAINNET_RPC_URL || 'https://rpc.pharos.xyz';
const PRIVATE_KEY = process.env.PRIVATE_KEY || '';

const config: HardhatUserConfig = {
  networks: {
    pharosTestnet: {
      url: PHAROS_TESTNET_RPC,
      chainId: 688689,
      accounts: [PRIVATE_KEY],
    },
    pharosMainnet: {
      url: PHAROS_MAINNET_RPC,
      chainId: 1672,
      accounts: [PRIVATE_KEY],
    },
    pharosTestnetV2: {
      url: process.env.PHAROS_TESTNET_V2_RPC_URL || 'https://testnet.dplabs-internal.com',
      chainId: 688688,
      accounts: [PRIVATE_KEY],
    },
    pharosDevnet: {
      url: process.env.PHAROS_DEVNET_RPC_URL || 'https://devnet.dplabs-internal.com',
      chainId: 50002,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
```

## Getting Testnet PHRS

Before deploying to testnet, the deployer address needs testnet PHRS for gas:

1. Go to the Pharos testnet faucet: https://testnet.pharosnetwork.xyz
2. Connect your wallet or paste your deployer address
3. Request testnet PHRS (usually received within seconds)
4. Verify balance: `cast balance --rpc-url $PHAROS_TESTNET_RPC_URL <address>`

If the faucet is unavailable, try:
- Pharos Discord faucet channel: https://discord.com/invite/pharos
- Pharos testnet bridge (if available)

Never use mainnet PROS for testnet deployment. Testnet PHRS has no real value.

## Pre-Flight Checklist

Before any broadcast, confirm with the user (or via repo config) that these conditions are met:

| # | Check | How to verify |
|---|---|---|
| 1 | RPC URL is correct for the target network | Read from env var; confirm with user |
| 2 | Signer private key is set | Confirm `PRIVATE_KEY` is exported; never display its value |
| 3 | Deployer has enough gas | Run a balance check JSON-RPC call on the target network |
| 4 | Correct deploy script selected | Check `SCRIPT_TARGET` or contract path |
| 5 | Contract compiles cleanly | Run `forge build` or `npx hardhat compile` |
| 6 | Solc version matches the network | Check compiler overrides in `foundry.toml` or `hardhat.config.ts` |
| 7 | Nonce is correct | Check nonce of the deployer address if prior txs are pending |
| 8 | Constructor args are correct | Review the deploy script/args for the correct initial values |
| 9 | Verification API key is set | If `VERIFY=1`, confirm `ETHERSCAN_API_KEY` is exported |
| 10 | Simulation passes | Run `SIMULATE_ONLY=1` and confirm no revert or error |

**Mainnet-only pre-flight checks** (additional):

| # | Check | Why |
|---|---|---|
| 11 | Confirm chain ID matches mainnet | `cast chain-id` against known Pharos mainnet ID |
| 12 | Balance check: deployer has sufficient funds | Mainnet gas costs are real; check balance is 2x estimated gas |
| 13 | Contract bytecode is final | Confirm no pending changes to the source after compilation |
| 14 | Timelock/multi-sig is ready | If the contract uses upgradeable proxy or admin role, confirm ownership transfer plan |

## Pharos Resources

| Resource | URL |
|---|---|
| Official Docs | https://docs.pharos.xyz |
| PharosScan (Mainnet) | https://www.pharosscan.xyz |
| PharosScan (Testnet) | https://atlantic.pharosscan.xyz |
| Testnet Faucet | https://testnet.pharosnetwork.xyz |
| GitHub | https://github.com/PharosNetwork |
| Discord | https://discord.com/invite/pharos |
| RPC Providers | https://docs.pharos.xyz/tooling-and-infrastructure/rpc |

## Pharos Network Reference

Official Pharos network configurations for deployment:

| Network | Chain ID | RPC URL | Explorer | Symbol | Faucet |
|---|---|---|---|---|---|---|
| Pacific Mainnet | 1672 | `https://rpc.pharos.xyz` | https://www.pharosscan.xyz | PROS | N/A (real value) |
| Atlantic Testnet (deprecated) | 688689 | `https://atlantic.dplabs-internal.com` | https://atlantic.pharosscan.xyz | PHRS | https://testnet.pharosnetwork.xyz |
| Testnet v2 | 688688 | `https://testnet.dplabs-internal.com` | https://testnet.pharosscan.xyz | PHRS | https://testnet.pharosnetwork.xyz |
| Devnet | 50002 | `https://devnet.dplabs-internal.com` | https://pharosscan.xyz | PHRS | N/A |

### Alternative RPC Providers

| Provider | Testnet | Mainnet |
|---|---|---|
| ZAN | `https://api.zan.top/node/v1/pharos/testnet/{apikey}` | `https://api.zan.top/node/v1/pharos/mainnet/{apikey}` |

Always verify the chain ID matches the target network before broadcasting.

> Ready-to-use config files are in the `config/` directory: `pharos.json` (machine-readable chain data), `chains.ts` (wagmi/viem chain definitions), `foundry.toml`, `hardhat.config.ts`, and `.env.example` (environment template). Copy them into your project and adjust as needed.

```bash
# Check chain ID via cast (Foundry)
cast chain-id --rpc-url $PHAROS_TESTNET_RPC_URL
# Expected: 688689

cast chain-id --rpc-url $PHAROS_MAINNET_RPC_URL
# Expected: 1672
```

Never hardcode RPC URLs, chain IDs, or private keys in scripts or config files. Always use environment variables.

## Environment Variables

These are required by the bundled scripts. The user must set them before deployment:

| Variable | Required for | Notes |
|---|---|---|
| `PHAROS_TESTNET_RPC_URL` | Testnet deploy | Testnet JSON-RPC endpoint |
| `PHAROS_MAINNET_RPC_URL` | Mainnet deploy | Mainnet JSON-RPC endpoint |
| `PRIVATE_KEY` | All deploys | Signer private key (hex with or without 0x prefix) |
| `ETHERSCAN_API_KEY` | Verification (Foundry) | Only needed when `VERIFY=1` |
| `DEPLOYED_ADDRESS` | Hardhat verification | Contract address after deployment |
| `HARDHAT_NETWORK` | Hardhat commands | Defaults to `pharosTestnet` / `pharosMainnet` |

Never hardcode these in config files or scripts. Use env vars at runtime.

## Deploy Subskills

Route to the network-specific variant:

| Subskill | Use when |
|---|---|
| `testnet-deployment` | "Deploy this contract to Pharos testnet" / testnet rehearsal |
| `mainnet-deployment` | "Deploy this contract to Pharos mainnet" / mainnet release |
| `post-deploy` | Post-deployment verification, artifact capture, and frontend config update |

## Bundled Scripts

All scripts live in `scripts/` and are parameterized via environment variables.

### Foundry

| Script | Purpose | Env vars | Pre-flight checks |
|---|---|---|---|
| `scripts/deploy-testnet.sh` | Deploy via Foundry to testnet | `PHAROS_TESTNET_RPC_URL`, `PRIVATE_KEY`, optional: `SCRIPT_TARGET`, `SIMULATE_ONLY`, `VERIFY` | Chain ID validation (688689), deployer balance check |
| `scripts/deploy-mainnet.sh` | Deploy via Foundry to mainnet | `PHAROS_MAINNET_RPC_URL`, `PRIVATE_KEY`, optional: `SCRIPT_TARGET`, `SIMULATE_ONLY`, `VERIFY` | Chain ID validation (1672), deployer balance check, mainnet banner warning |

Foundry script usage:

```bash
# Simulate only (no broadcast) — validates chain ID and balance
SIMULATE_ONLY=1 ./scripts/deploy-testnet.sh

# Deploy + verify on testnet
VERIFY=1 ./scripts/deploy-testnet.sh

# Custom deploy script
SCRIPT_TARGET=script/MyDeploy.s.sol:MyDeploy ./scripts/deploy-mainnet.sh
```

The Foundry scripts automatically validate the chain ID and check deployer balance before running. If the RPC points to the wrong network, the script exits with an error before any broadcast.

### Hardhat

| Script | Purpose | Env vars | Pre-flight checks |
|---|---|---|---|
| `scripts/deploy-testnet-hardhat.sh` | Deploy via Hardhat to testnet | `PHAROS_TESTNET_RPC_URL`, `PRIVATE_KEY`, optional: `DEPLOY_TAGS`, `HARDHAT_NETWORK` | Hardhat installation check |
| `scripts/deploy-mainnet-hardhat.sh` | Deploy via Hardhat to mainnet | `PHAROS_MAINNET_RPC_URL`, `PRIVATE_KEY`, optional: `DEPLOY_TAGS`, `HARDHAT_NETWORK` | Hardhat installation check, mainnet banner warning |
| `scripts/verify-testnet-hardhat.sh` | Verify contract on testnet explorer | `PHAROS_TESTNET_RPC_URL`, `DEPLOYED_ADDRESS`, optional: `HARDHAT_NETWORK` | Prints explorer URL for manual confirmation |
| `scripts/verify-mainnet-hardhat.sh` | Verify contract on mainnet explorer | `PHAROS_MAINNET_RPC_URL`, `DEPLOYED_ADDRESS`, optional: `HARDHAT_NETWORK` | Prints explorer URL, mainnet banner warning |

Hardhat script usage:

```bash
# Default deploy (uses "deploy" tag)
./scripts/deploy-testnet-hardhat.sh

# Deploy with specific tags
DEPLOY_TAGS=upgrade ./scripts/deploy-mainnet-hardhat.sh

# Verify after deployment
DEPLOYED_ADDRESS=0x123... ./scripts/verify-testnet-hardhat.sh
```

## Core Behavior

1. **Confirm** the target network, contract artifact, toolchain, RPC config, signer config, and verification target.
2. **Check** if the repo already has deploy scripts or config — use those instead of inventing new flows.
3. **Run pre-flight** checklist (see above) — present results to the user.
4. **Draft** the smallest safe deployment plan including simulation steps.
5. **Present** the plan and ask for explicit approval before any broadcast.
6. **Execute** the chosen deploy command only after approval.
7. **Capture** the deployed address, tx hash, explorer link, and verification result.
8. **Run post-deploy verification** (see below).
9. **If verification fails**, report the exact failure and stop. Do not retry with a different approach without user approval.

## Post-Deploy: Frontend Config Update

After a successful deployment, the dapp frontend needs the new contract address and ABI. Prompt the user to update:

```typescript
// config/contracts.ts — update with deployed address
export const CONTRACTS = {
  token: {
    address: "0x...", // ← replace with deployed address
    abi: tokenABI,
    deployedAt: 1234567, // block number
  },
};
```

If the ABI changed, regenerate TypeChain/abitype bindings:

```bash
# Foundry
forge inspect Token abi > abi/Token.json

# Hardhat
npx hardhat run scripts/extract-abi.ts
```

Suggest these follow-up steps:
1. Update the frontend `.env` or config with the new address
2. Tag the release commit: `git tag v1.0.0-deployed -m "Contract deployed to mainnet"`
3. Update the README with the deployed address and explorer link

## Post-Deploy Verification Script

A standalone verification script is provided for quick post-deploy checks:

```bash
# Verify on testnet
./scripts/verify-deployment.sh testnet 0xDeployedAddress

# Verify on mainnet with owner check
./scripts/verify-deployment.sh mainnet 0xDeployedAddress 0xExpectedOwner
```

The script checks: chain ID matches expected network, bytecode exists at the address (contract is alive), transaction nonce, explorer URL is generated, and optionally the contract owner matches the expected address.

## Post-Deploy Verification Protocol

After a successful broadcast, confirm:

| Step | Action | Expected result |
|---|---|---|
| 1 | Capture deployed address from script output | Address logged to console |
| 2 | Fetch tx receipt | Transaction exists on the target network |
| 3 | Query contract code | `getCode` returns non-empty bytecode |
| 4 | Verification (if requested) | Explorer shows ✅ Verified or equivalent |
| 5 | Check contract state (owner, totalSupply, etc.) | State matches constructor args |
| 6 | Log explorer URL | `https://{network}-explorer.pharos.network/address/{addr}` |
| 7 | Save deploy artifact | Address, tx hash, block number, timestamp to a deploy log |

Report the final state:

```json
{
  "status": "deployed",
  "network": "pharos-testnet",
  "contract": "Token.sol",
  "address": "0x...",
  "deployer": "0x...",
  "txHash": "0x...",
  "blockNumber": 1234567,
  "explorerUrl": "https://testnet-explorer.pharos.network/address/0x...",
  "verified": true
}
```

For a structured post-deploy workflow covering these steps in a single subskill flow, route to the `post-deploy` subskill.

## Emergency Rollback Guidance

If a deployment goes wrong (wrong contract, wrong network, unexpected behavior):

| Scenario | Action | User must do |
|---|---|---|
| Deployed to testnet instead of mainnet | Safe — testnet is non-production. Log the address and move on. | Nothing |
| Deployed wrong contract version | Deploy the correct version with a fresh script. The old contract can be abandoned. | Nothing |
| Deployed to mainnet with wrong args | If the contract is upgradeable: deploy a proxy upgrade. If not: the contract is immutable — inform the user immediately. | Decide if they need a new deployment or a migration |
| Deployed to mainnet with a bug | If the contract has an `upgradeTo` function: deploy an upgrade. If no upgrade path: the bug is frozen — inform the user. | Bug-fix deploy or accept the bug |
| Deployer key was compromised | Inform user. They must transfer ownership, deploy from a new key, or migrate. | Rotate key immediately |
| Verification failure after successful deploy | The contract exists but isn't verified. Re-run verify with the correct args. | Confirm the source matches the deployed bytecode |

**Rule**: Never propose a migration, selfdestruct, or ownership transfer without explicit user approval. These are high-risk operations that can cause irreversible loss.

## Communication Templates

**Pre-deployment plan for approval:**

```
## Deployment Plan: {contract} to {network}

**Toolchain**: Foundry
**Target network**: pharos-testnet
**Script**: `VERIFY=1 ./scripts/deploy-testnet.sh`
**Contract**: `src/{file}.sol:{contract}`

**Pre-flight check results**:
- ✅ RPC URL: set
- ✅ Private key: set
- ✅ Balance check: {balance} native token
- ✅ Compilation: clean
- ✅ Simulation: passed
- ✅ Constructor args: {args}

**Assumptions**:
- {assumption 1}
- {assumption 2}

Do you approve this deployment?
```

**Post-deployment summary:**

```
## Deployment Complete

{contract} deployed to {network}

**Address**: `0x...`
**Tx hash**: `0x...`
**Block**: #1234567
**Explorer**: https://testnet-explorer.pharos.network/address/0x...
**Verified**: ✅

**Next steps**:
- {suggestion 1}
- {suggestion 2}
```

**Deploy failure report:**

```
## Deployment Failed

**Network**: pharos-testnet
**Contract**: Token.sol
**Error**: {exact error message from forge/hardhat}

**Likely cause**: {explanation}

**Recommended fix**: {action to resolve}

**Suggested command to retry**:
```bash
{corrected command}
```

Do you want to fix and retry, or abort?
```

**Verification failure after successful deploy:**

```
## Verification Failed

**Contract**: `0x...` was deployed successfully but verification failed.

**Error**: {exact error}

**Likely cause**: {explanation — e.g., wrong API key, mismatch between deployed bytecode and source, wrong compiler version}

**Options**:
1. Fix the issue and re-run verification with corrected params
2. Skip verification (contract exists on-chain but won't show source on explorer)

Which option do you prefer?
```

**Rollback/abort communication:**

```
## Deployment Aborted

**Network**: pharos-mainnet
**Stage**: Pre-flight check failed

**Issue**: {issue description}

**No transactions were broadcast.** The network state is unchanged.

**To proceed later**: {what the user needs to resolve}
```

## Output Contract

Always return all 6 fields:

1. **Summary** — network, contract, tx hash, explorer link
2. **Deployment plan** — the exact commands and config
3. **Required config** — env vars the user must set
4. **Assumptions** — RPC endpoints, chain IDs, signer assumptions
5. **Verification steps** — how to confirm the deployment
6. **Approval question** — gate before every broadcast or mainnet execution

### Output Variants

**Simulation only (pre-broadcast):**
```json
{
  "stage": "simulation",
  "network": "pharos-testnet",
  "contract": "Token.sol",
  "simulationResult": "Simulation passed — no revert, gas estimated: 245000",
  "deployCommand": "VERIFY=1 ./scripts/deploy-testnet.sh",
  "requiredEnv": ["PHAROS_TESTNET_RPC_URL", "PRIVATE_KEY"],
  "assumptions": ["Testnet RPC is publicly available"],
  "preFlightChecks": ["✅ RPC set", "✅ Key set", "✅ Balance sufficient", "✅ Compilation clean", "✅ Simulation passed"],
  "approvalQuestion": "Simulation passed. Proceed with testnet broadcast?"
}
```

**Successful broadcast + verification:**
```json
{
  "stage": "broadcast",
  "status": "success",
  "network": "pharos-testnet",
  "contract": "Token.sol",
  "address": "0x...",
  "txHash": "0x...",
  "blockNumber": 1234567,
  "explorerUrl": "https://testnet-explorer.pharos.network/address/0x...",
  "verified": true,
  "deployCommand": "VERIFY=1 ./scripts/deploy-testnet.sh",
  "nextSteps": ["Update the frontend with the new address", "Tag the release commit"]
}
```

**Verification failure after successful deploy:**
```json
{
  "stage": "post-deploy-verification",
  "status": "partial",
  "network": "pharos-testnet",
  "contract": "Token.sol",
  "address": "0x...",
  "txHash": "0x...",
  "verificationFailed": "Contract source code does not match deployed bytecode",
  "likelyCause": "Compiler version mismatch: source uses 0.8.20, deployed with 0.8.19",
  "recommendedFix": "Set solc version to 0.8.19 in foundry.toml, rebuild, and re-run verify",
  "approvalQuestion": "Fix the solc version and re-run verification?"
}
```

## Handoff from Dev Suite

When the dev suite (`pharos-agent-dev-suite`) hands off a deployment, it will provide:

1. **Contract artifact**: The compiled contract and deploy script
2. **Target network**: Testnet or mainnet with chain ID
3. **Deploy command**: The exact script and env vars needed
4. **Verification config**: Whether verification is needed and with which API key

On receiving a handoff:

1. Confirm the handoff details with the user.
2. Verify the artifact and script exist.
3. Run the pre-flight checklist before broadcasting.
4. Broadcast, verify, and report back to the user.

If the handoff is incomplete (missing contract, missing script, missing env vars), ask the user to complete the prep with `pharos-agent-dev-suite` first.

## Operating Rules

- **Do not invent** RPC URLs, private keys, chain IDs, or verification endpoints.
- **Testnet first** — always default to testnet unless the user explicitly asks for mainnet.
- **Use existing** — if the repo already has a deploy script, Hardhat task, or Foundry script, use that instead of the bundled templates.
- **Ask for missing** — if required inputs (RPC URL, signer, artifact) are not provided, ask before proceeding.
- **One deploy at a time** — deploy the requested contract, capture the result, then ask about next steps.
- **Never reuse a mainnet key on testnet** or vice versa unless the user explicitly confirms.
- **Simulate before broadcast** — run `SIMULATE_ONLY=1` before every real broadcast, even for testnet.
- **Never broadcast on mainnet** without running the full pre-flight checklist first.
- **Abort on failure** — if simulation fails, do not broadcast. Report the failure and ask for direction.
- **No mnemonic derivation** — only accept hex private keys or keystore files. Never derive from a mnemonic.

## Cast Cheatsheet (Foundry)

Useful `cast` commands for Pharos network operations:

```bash
# Check chain ID (always verify before broadcasting)
cast chain-id --rpc-url $RPC_URL

# Get deployer balance
cast balance --rpc-url $RPC_URL $DEPLOYER_ADDR

# Get contract bytecode (check if deployed)
cast code --rpc-url $RPC_URL $CONTRACT_ADDR

# Call a read function
cast call --rpc-url $RPC_URL $CONTRACT_ADDR "totalSupply()(uint256)"

# Send a write transaction
cast send --rpc-url $RPC_URL --private-key $PK $CONTRACT_ADDR "transfer(address,uint256)" $TO $AMOUNT

# Estimate gas
cast estimate --rpc-url $RPC_URL $CONTRACT_ADDR "someFunction()"

# Get transaction receipt
cast tx --rpc-url $RPC_URL $TX_HASH

# Get block number
cast block-number --rpc-url $RPC_URL

# Look up an ABI-encoded function signature
cast 4byte 0x$a9059cbb
```

## Self-Verification Checklist

Before presenting a plan, verify:

- [ ] Did I confirm the target network with the user?
- [ ] Did I check for existing deploy scripts in the repo?
- [ ] Did I run the pre-flight checklist?
- [ ] Did I include a simulation step in the plan?
- [ ] Did I present the plan before any broadcast?
- [ ] Did I ask for explicit approval?
- [ ] Did I avoid hardcoding any sensitive values?
- [ ] Did I capture the post-deploy state?
- [ ] Did I check if verification should be included?

## Common Deployment Questions

**Q: How do I estimate PROS/PHRS needed for deployment?**
A: Use `forge script --gas-estimate` for Foundry or Hardhat's built-in gas reporter. As a rough guide, a typical ERC-20 costs ~1.5-3 PROS on mainnet. Always deploy with a 50% gas buffer.

**Q: What if the deploy script says "insufficient funds"?**
A: The deployer address doesn't have enough PROS/PHRS for gas. Get testnet PHRS from https://testnet.pharosnetwork.xyz or transfer mainnet PROS to the deployer wallet. The script checks balance automatically before broadcast.

**Q: What if chain ID validation fails?**
A: Double-check your RPC URL. The script expects chain ID 688689 for testnet (Atlantic) and 1672 for mainnet (Pacific). Run `cast chain-id --rpc-url $RPC_URL` to verify.

**Q: How long does deployment take on Pharos?**
A: Blocks confirm in <1 second, so deployment is nearly instant after submission. Total time is usually 5-15 seconds including transaction propagation and block inclusion.

**Q: What are common causes of transaction revert on Pharos?**
A: Same as Ethereum: out of gas, insufficient funds, failed require statements, invalid constructor args, reentrancy protection, or overflow. Use `cast run` with a trace for debugging.

**Q: How do I verify after Hardhat deployment?**
A: Use `npx hardhat verify --network pharosTestnet <contract-address> <constructor-args>`. Ensure `ETHERSCAN_API_KEY` is set and the Hardhat config includes the chain's `url` and `chainId`.

**Q: Can I cancel or replace a stuck transaction on Pharos?**
A: Yes — send a new transaction with the same nonce, higher gas price, and zero value. Pharos has no mempool differentiation from standard Ethereum.

## Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| `PHAROS_TESTNET_RPC_URL: unset` | Env var not set | Ask user to export the variable |
| `forge: command not found` | Foundry not installed | Ask user to install Foundry (`foundryup`) |
| `npx hardhat: command not found` | Hardhat not installed | Ask user to install Hardhat or check `package.json` |
| Script target not found | `SCRIPT_TARGET` points to wrong file | Check the deploy script path in the repo |
| Verification fails | API key missing, wrong explorer URL, or contract mismatch | Check `ETHERSCAN_API_KEY`, network config, and compiled bytecode |
| Nonce too low | Previous pending tx on same key | Ask user to wait or use a different key |
| `--broadcast` failing | Insufficient gas, wrong chain, or bad RPC | Simulate first with `SIMULATE_ONLY=1`, then check RPC and balance |
| Simulation passes but broadcast fails | State change between simulation and broadcast (nonce, balance) | Re-simulate, check for other pending txs |
| Contract already verified | Same bytecode already verified on explorer | Inform user — no action needed |
| Explorer shows "Invalid address" | Wrong network or address format | Confirm the address and network match |
| Transaction reverted during broadcast | Constructor reverted or preconditions not met | Check constructor args, deployer permissions |

## Mainnet Launch Checklist

Step-by-step checklist for a safe mainnet deployment:

### 1 Week Before
- [ ] Complete all contract development and testing on testnet
- [ ] Run full security audit / contract review
- [ ] Verify all upgrade paths work correctly on testnet
- [ ] Set up mainnet RPC endpoint and verify connectivity
- [ ] Procure mainnet PROS tokens for gas (estimate: deploy + 50% buffer)
- [ ] Set up monitoring for the deployed contract (events, transactions)

### 1 Day Before
- [ ] Run final simulation on mainnet fork: `forge test --fork-url https://rpc.pharos.xyz`
- [ ] Verify constructor args are final
- [ ] Confirm multi-sig/owner address is correct
- [ ] Prepare deployer wallet (transfer only the gas needed)
- [ ] Verify `ETHERSCAN_API_KEY` works for mainnet verification
- [ ] Write the deployment transaction in a prepared script

### Deployment Day
- [ ] Confirm chain ID = 1672 (Pharos Pacific Mainnet)
- [ ] Check deployer balance has sufficient PROS
- [ ] Run simulation: `SIMULATE_ONLY=1 ./scripts/deploy-mainnet.sh`
- [ ] On approval: broadcast deployment
- [ ] Verify on explorer: https://www.pharosscan.xyz
- [ ] Run post-deploy verification: `./scripts/verify-deployment.sh mainnet <address>`
- [ ] Transfer ownership to multi-sig (if applicable)
- [ ] Tag the release commit: `git tag v1.0.0 -m "Contract deployed to mainnet"`
- [ ] Update frontend config with new address
- [ ] Announce deployment

### Post-Launch (First 48 Hours)
- [ ] Monitor for abnormal transactions or events
- [ ] Verify all expected state transitions work
- [ ] Check gas usage against estimates
- [ ] Prepare rollback plan (upgrade or redeploy if critical bug found)
- [ ] Update documentation with mainnet addresses

## Best Practices

- **Simulate first** — run `SIMULATE_ONLY=1` before any real broadcast.
- **Verify after deploy** — always run verification to confirm the deployed bytecode matches.
- **One network at a time** — never deploy to testnet and mainnet in the same session without separate approvals.
- **Capture everything** — deployed address, tx hash, block number, and explorer links are the minimum record.
- **Use repo scripts** — prefer existing deploy scripts over creating new ones, unless the user asks for a new setup.
- **Check the deployer balance** — before a mainnet deploy, confirm the signer has enough native currency for gas.
- **Tag releases** — encourage the user to tag the commit with the deployed version for traceability.
- **Keep mainnet safe** — double-check the RPC URL, chain ID, and contract artifact before every mainnet broadcast.
- **Never log private keys** — never echo, print, or log the `PRIVATE_KEY` value. Mask it in all output.
- **Abort on unexpected** — if simulation results differ from what you expect, abort and ask the user before continuing.
- **One contract per broadcast** — deploy a single contract per broadcast unless the user explicitly asks for batch deployment.
