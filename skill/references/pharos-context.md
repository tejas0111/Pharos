# Pharos Context

Single source of truth for Pharos network facts. Use these values in chain config, deploy scripts, and verification steps. Do not guess RPC URLs, chain IDs, or explorer endpoints.

## Network Detection (How to Know Which Network the User Means)

When a user mentions Pharos without specifying a network, detect from their language:

| If the user says... | They mean... | Chain ID | Symbol |
|---|---|---|---|
| "testnet", "test", "dev", "faucet", "PHRS", "try it out", "experiment", "Atlantic" | **Atlantic Testnet** (primary testnet) | 688689 | PHRS |
| "mainnet", "production", "live", "PROS", "deploy", "launch", "release" | **Mainnet** | 1672 | PROS |
| Just "Pharos" with no network | Ask the user: "Atlantic Testnet (688689, PHRS) or Mainnet (1672, PROS)?" | — | — |
| "deploy", "broadcast", "ship" | Likely testnet first, then mainnet | 688689 → 1672 | PHRS → PROS |
| "fork", "local", "anvil", "test" | Local/test environment (use anvil) | 31337 | PHRS (simulated) |

**Rule**: When in doubt, default to Atlantic Testnet (688689) for development work, but ASK the user before making network-sensitive decisions (deploying, broadcasting, funding).

## Canonical Networks

| Network | Chain ID | Native | RPC | Explorer |
|---|---|---|---|---|
| Mainnet | 1672 | PROS | `https://rpc.pharos.xyz`, `https://infra.orginstake.com/pharos/evm` | `https://www.pharosscan.xyz` |
| Atlantic Testnet | 688689 | PHRS | `https://atlantic.dplabs-internal.com` | `https://atlantic.pharosscan.xyz` |

### Legacy / Deprecated

| Network | Chain ID | Notes |
|---|---|---|
| Atlantic v1 | 688688 | **SHUT DOWN**. Migrate all work to Atlantic (688689). |

## Quick Recognition Guide

When reading a user's code, config, or prompt, recognize networks from these signals:

| Signal in code | What it means |
|---|---|
| `chainId: 1672` or `id: 1672` | Mainnet (PROS) |
| `chainId: 688689` or `id: 688689` | Atlantic Testnet (PHRS) |
| `chainId: 688689` or `id: 688689` | Legacy Testnet (SHUT DOWN) |
| `"PROS"` in code comments or config | Mainnet |
| `"PHRS"` in code comments or config | Testnet |
| `rpc.pharos.xyz` | Mainnet |
| `atlantic.dplabs-internal.com` | Atlantic Testnet |
| `pharosscan.xyz` | Explorer |

## Network-Aware Behavior

When responding to users, adapt based on the detected network:

### If Atlantic Testnet (688689, PHRS):
- Use `PHRS` for native amounts (not PROS, not "ETH", not "native")
- RPC URL: `https://atlantic.dplabs-internal.com`
- Explorer: `https://atlantic.pharosscan.xyz`
- Symbol everywhere: "PHRS"
- Commands: `--rpc-url pharos_testnet --chain-id 688689`

### If Mainnet (1672, PROS):
- Use `PROS` for native amounts
- RPC URLs: `https://rpc.pharos.xyz` (Primary), `https://infra.orginstake.com/pharos/evm` (Fallback)
- Explorer: `https://www.pharosscan.xyz`
- Symbol everywhere: "PROS"
- Commands: `--rpc-url pharos_mainnet --chain-id 1672`

### If Unknown:
- Ask: "Are you targeting Pharos Atlantic Testnet (688689, PHRS) or Mainnet (1672, PROS)?"
- Do not guess. Using the wrong chain ID can deploy contracts to the wrong network or cause confusing RPC errors.

## Native Token Rules

- Decimals: **18** for PROS and PHRS.
- Native transfers: use `sendTransaction` with a `value` field (viem/wagmi/ethers). Do not treat native currency as an ERC-20.
- `msg.value` in Solidity is in wei (18 decimals).
- **Mainnet symbol: PROS. Testnet symbol: PHRS.** Never call PROS "PHRS" or PHRS "PROS." Never call either one "ETH" or generic "native."
- When displaying amounts: format with `formatEther` (viem) or `formatUnits(value, 18)` to show human-readable PHRS/PROS.

## Viem `defineChain` Blocks

```typescript
import { defineChain } from 'viem';

export const pharosMainnet = defineChain({
  id: 1672,
  name: 'Pharos Mainnet',
  nativeCurrency: { name: 'PROS', symbol: 'PROS', decimals: 18 },
  rpcUrls: {
    default: { http: ['https://rpc.pharos.xyz', 'https://infra.orginstake.com/pharos/evm'] },
  },
  blockExplorers: {
    default: { name: 'PharosScan', url: 'https://www.pharosscan.xyz' },
  },
});

export const pharosTestnet = defineChain({
  id: 688689,
  name: 'Pharos Atlantic Testnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: {
    default: { http: ['https://atlantic.dplabs-internal.com'] },
  },
  blockExplorers: {
    default: { name: 'PharosScan', url: 'https://atlantic.pharosscan.xyz' },
  },
  testnet: true,
});
```

## Foundry Config

```toml
[rpc_endpoints]
pharos_mainnet = "${PHAROS_MAINNET_RPC_URL:-https://rpc.pharos.xyz}"
pharos_testnet = "${PHAROS_TESTNET_RPC_URL:-https://atlantic.dplabs-internal.com}"
```

Common env vars:

| Variable | Purpose |
|---|---|
| `PHAROS_TESTNET_RPC_URL` | Atlantic Testnet RPC override |
| `PHAROS_MAINNET_RPC_URL` | Mainnet RPC override |
| `PRIVATE_KEY` | Deployer key for scripts (Stored in .env) |
| `PHAROSSCAN_API_KEY` | PharosScan verification (required for mainnet) |

## Deploy Command Template

For Atlantic Testnet:
```bash
forge script script/Deploy.s.sol:DeployCounter \
  --rpc-url pharos_testnet \
  --broadcast \
  --chain-id 688689 \
  -vvvv
```

For mainnet:
```bash
forge script script/Deploy.s.sol:DeployCounter \
  --rpc-url pharos_mainnet \
  --broadcast \
  --chain-id 1672 \
  -vvvv
```

Always verify chain ID before broadcast:
```bash
cast chain-id --rpc-url pharos_testnet
# Expected: 688689 (testnet) or 1672 (mainnet)
```

## Security and Verification

1. **Pre-flight Consistency Check**: Always verify that the deployed contract matches the frontend ABI and the .env variables are correct before deployment. See the root `SKILL.md` 'Deploy Protocol' section for the full checklist.
2. **Private Key**: Never hardcode private keys. Use `${PRIVATE_KEY}` and ensure it is loaded from a `.env` file that is ignored by git.
3. **Simulation**: Mandatory `SIMULATE_ONLY=1` or dry-run before any broadcast.

## Subskill Cross-Links

Read this file when chain facts matter. Pair with the subskill that owns the task:

| Subskill | Use pharos-context for |
|---|---|
| `framework-integration` | wagmi/viem/Foundry/Hardhat chain setup |
| `wagmi-viem-dapp-workflow` | wallet config, chain switching, native sends |
| `foundry-hardhat-contract-workflow` | `foundry.toml`, scripts, local fork URLs |
| `deployment-and-verification` | deploy script env vars, verification URLs |
| `deployment-for-testnet-and-mainnet` | network choice, mainnet vs testnet checklist |
| `contract-testing-for-testnet-and-mainnet` | fork RPC, chain ID in integration tests |
| `frontend-dapp-integration` | chain ID in UI, explorer links for tx status |
| `wallet-and-transaction-ui` | native token display, PharosScan tx URLs |
| `ci-and-build-troubleshooting` | CI env vars for RPC URLs and chain IDs |
| `bug-finding-and-debugging` | wrong-chain failures, RPC/chain ID mismatches |
