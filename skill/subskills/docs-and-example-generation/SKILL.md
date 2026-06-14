---
name: pharos-docs-and-example-generation
description: "Write clear docs, usage instructions, and examples for Pharos developers and AI agents. Use when generating README files, usage guides, how-to docs, API documentation, or developer examples for Pharos Solidity contracts and dapps. Keywords: docs, README, examples, usage instructions, guides, documentation, how-to, API docs, Pharos, Solidity, TypeScript, Foundry, Hardhat, wagmi, viem, Next.js, developer docs."
metadata:
  audience: developer
  version: 1.2.0
  category: workflow
slash: true
---

# Docs and Example Generation

Write clear docs, usage instructions, and examples for Pharos developers, agents, and dApp users.

## Pharos Docs Templates

### Contract README Stub

```markdown
# IPharosStaking

PHRS staking contract on Pharos (mainnet 1672 / Atlantic Testnet 688689).

## Addresses

| Network | Address |
|---------|---------|
| Mainnet (1672) | `0x...` |
| Atlantic Testnet (688689) | `0x...` |

## Interface

- `stake(uint256 amount)` — Stake PHRS. Native only (no ERC-20 approval).
- `unstake(uint256 amount)` — Request unstake. Cooldown: 7 days.
- `claimRewards()` — Claim accrued staking rewards.
- `getStakedBalance(address user) returns (uint256)` — View staked amount.
- `getRewards(address user) returns (uint256)` — View pending rewards.

## Usage (viem)

```typescript
import { createWalletClient, http, parseEther } from 'viem'
import { pharosTestnet } from './pharosChain'
import { pharosStakingABI } from './abis'

const client = createWalletClient({ chain: pharosTestnet, transport: http() })
const hash = await client.writeContract({
  address: '0x...',
  abi: pharosStakingABI,
  functionName: 'stake',
  value: parseEther('100'), // PHRS is native
})
```

## Verification

```bash
forge verify-contract --chain-id 1672 --verifier-url https://www.pharosscan.xyz/api \
  --etherscan-api-key $PHAROSSCAN_API_KEY <addr> src/PharosStaking.sol:PharosStaking
```
```

### User-Facing dApp Docs

```markdown
# Connect & Stake PHRS

1. Install a wallet (MetaMask / WalletConnect)
2. Add Pharos network:
   - **Mainnet**: RPC `https://rpc.pharos.xyz`, Chain ID `1672`, Symbol `PHRS`
   - **Testnet**: RPC `https://atlantic.dplabs-internal.com`, Chain ID `688689`, Symbol `PHRS`
3. Visit [app.your-dapp.com](https://app.your-dapp.com)
4. Click **Connect Wallet** (RainbowKit)
5. Enter PHRS amount and click **Stake**
6. Confirm the transaction in your wallet
7. View your staked balance and rewards in the dashboard
```

### Deployment Checklist

```
[ ] foundry.toml has [rpc_endpoints] for pharos_mainnet + pharos_testnet
[ ] .env has PRIVATE_KEY, PHAROSSCAN_API_KEY, PHAROS_MAINNET_RPC, PHAROS_TESTNET_RPC
[ ] forge build --sizes (no bytecode overflow)
[ ] forge test --fork-url pharos_testnet (all green)
[ ] forge script Deploy --rpc-url pharos_testnet --broadcast
[ ] forge verify-contract on PharosScan (testnet) --chain-id 688689
[ ] Upgrade Safe owner set correctly on testnet
[ ] forge script Deploy --rpc-url pharos_mainnet --broadcast --verify
[ ] forge verify-contract (mainnet) --chain-id 1672
[ ] Sanity check: cast send <staking> "stake(uint256)" 1 --value 1ether
[ ] Sanity check: cast call <staking> "getStakedBalance(address)" <user>
```

### Slashing Report Example

```json
{
  "spn_id": "spn_0xabcd",
  "validator": "0x...",
  "missed_checkpoints": 6,
  "slashed_amount": "1000 PHRS",
  "reason": "Missed 6 consecutive checkpoints (threshold: 5)",
  "block": 12345678,
  "tx": "https://www.pharosscan.xyz/pharos/tx/0x..."
}
```

## Examples

- "Write developer docs for the IPharosStaking contract on mainnet 1672"
- "Generate a dApp quickstart guide with viem + RainbowKit + Pharos testnet 688689"
- "Document the deployment flow with forge verify-contract against PharosScan API"
- "Create a deployment checklist for Pharos mainnet (chain ID 1672, RPC rpc.pharos.xyz)"
- "Write a slashing report in JSON format for the Pharos SPN validator"

## Verification

Visual review; verify links point to correct PharosScan URLs for the target network.

## When NOT to Use

- **File structure scaffolding** — For generating boilerplate files (forge init, npx create-next-app), use `code-scaffolding-and-generation`.
- **Release notes** — For changelogs and version bumps, use `release-notes-and-changelog`.

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: Private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Project context**: You need the contract names, network targets (1672 mainnet / 688689 testnet), and version numbers relevant to the documentation.
- **Previous artifacts**: If documenting deployed contracts, you need deployment addresses, ABI files, or changelog history.
- **Target audience**: Clarify whether this is for developers, end users, or both.
## Workflow

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Detect the user target network — Use `references/pharos-context.md` Network Detection table to determine if the user means testnet (688689, PHRS), mainnet (1672, PROS), or is ambiguous. If the user didn't specify, ask: 'Atlantic Testnet or Mainnet?' Adapt all following steps (RPC URLs, token symbols, deploy commands, chain IDs) to match.
4. Understand the documentation need and target audience.
5. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
6. Generate the doc or example content.
7. Show the plan and ask for approval before finalizing.
8. Review and finalize the output.
## Output

- README with contract addresses per network (1672 / 688689), viem usage, verify commands
- dApp user docs with network addition params (RPC, chain ID, symbol)
- Deployment checklist with network-specific forge commands
- Slashing / event report JSON examples
- Quickstart code snippets (TypeScript, viem, RainbowKit)

## Related

code-scaffolding-and-generation (file structure), release-notes-and-changelog (changelogs), deployment-and-verification (deploy flow), wallet-and-transaction-ui (dApp integration)

## Gate


Low risk. Present the outline and sample commands first; write or edit doc files only after the user confirms scope and paths.
