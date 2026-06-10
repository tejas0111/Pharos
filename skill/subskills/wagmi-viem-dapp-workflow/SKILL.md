---
name: pharos-wagmi-viem-dapp-workflow
description: "Handle Pharos wallet connection, contract reads, writes, and dapp integration patterns using Wagmi and Viem. Use when implementing wallet connect, contract read/write, useContractRead, useContractWrite, useAccount, useWalletClient, or dapp workflows for Pharos web3 frontends. Keywords: Wagmi, Viem, wallet connect, contract read, contract write, dapp workflow, useContractRead, useContractWrite, useAccount, useWalletClient, Pharos, 688689, 1672, Atlantic, Pacific, Next.js, React, TypeScript."
metadata:
  audience: developer
  version: 1.2.0
  category: frontend
slash: true
---

# Wagmi and Viem Dapp Workflow

Handle wallet connection, contract reads, writes, and dapp integration patterns using Wagmi and Viem.

## When to Use

Wagmi, Viem, wallet connect, contract read, contract write, dapp workflow, useContractRead, useContractWrite, useAccount, useWalletClient

## When NOT to Use

general React patterns (use react-ui-patterns-and-hooks), or full frontend layout (use tailwind-shadcn-ui-workflow)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: Private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Node.js**: >=18. Run `node --version` to verify.
- **pnpm**: installed. Run `pnpm --version` to verify (or npm/yarn if your project uses those).
- **Dependencies**: Run `pnpm install` (or `npm install`) before proceeding.
- **Chain config**: Pharos chain (mainnet 1672 / Atlantic Testnet 688689) must be configured in wagmi or viem. See `packages/shared/src/pharosChain.ts` for the canonical config.
- **RPC endpoint**: Ensure your app's RPC URL points to `https://rpc.pharos.xyz` (mainnet) or `https://atlantic.dplabs-internal.com` (testnet).
- **Wallet**: A browser wallet (MetaMask, WalletConnect, etc.) with the Pharos network added for testing.
## Workflow

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Map the contract and wallet interactions the UI needs.
4. Check prerequisites: verify Node.js/pnpm are installed, dependencies are installed, and network config is correct. Ask the user for any missing values before proceeding.
5. Choose the minimal Wagmi and Viem integration pattern.
6. Present the plan and ask for approval before implementation.
7. Verify the configuration and flow with a small smoke check.
## Output

- integration plan
- hook notes
- config notes
- smoke-check suggestion

## Examples

- "Wire Wagmi and Viem into this dapp flow"
- "Plan the contract read and write helpers for a wallet-connected UI"
- "Set up Wagmi config with Pharos chain and wallet connectors"

## Pharos Chain Configuration

Define both Pharos networks using viem's `defineChain`:

```typescript
import { defineChain } from 'viem'

export const pharosMainnet = defineChain({
  id: 1672,
  name: 'Pharos Mainnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: {
    default: { http: ['https://rpc.pharos.xyz'] },
  },
  blockExplorers: {
    default: { name: 'PharosScan', url: 'https://pharosscan.xyz' },
  },
})

export const pharosTestnet = defineChain({
  id: 688689,
  name: 'Pharos Testnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: {
    default: { http: ['https://atlantic.dplabs-internal.com'] },
  },
  blockExplorers: {
    default: { name: 'PharosScan', url: 'https://pharosscan.xyz' },
  },
})
```

## Wagmi Config

```typescript
import { createConfig, http } from 'wagmi'
import { metaMask } from 'wagmi/connectors'
import { pharosMainnet, pharosTestnet } from './pharosChain'

export const config = createConfig({
  chains: [pharosMainnet, pharosTestnet],
  connectors: [metaMask()],
  transports: {
    [pharosMainnet.id]: http('https://rpc.pharos.xyz'),
    [pharosTestnet.id]: http('https://atlantic.dplabs-internal.com'),
  },
})
```

For WalletConnect support, install `@wagmi/connectors` and add:

```typescript
import { walletConnect } from 'wagmi/connectors'

// in createConfig connectors array:
connectors: [
  metaMask(),
  walletConnect({ projectId: 'YOUR_PROJECT_ID' }),
]
```

## Contract Read Example

```typescript
import { useContractRead } from 'wagmi'

const { data: balance, isError, isLoading } = useContractRead({
  address: '0xYourPharosContractAddress',
  abi: [...], // contract ABI
  functionName: 'balanceOf',
  args: ['0xUserAddress'],
  chainId: 1672, // Pharos Mainnet
})
```

## Contract Write Example

```typescript
import { useContractWrite, usePrepareContractWrite } from 'wagmi'

const { config: writeConfig } = usePrepareContractWrite({
  address: '0xYourPharosContractAddress',
  abi: [...],
  functionName: 'transfer',
  args: ['0xRecipient', parseEther('1')],
  chainId: 1672,
})

const { data: writeData, write } = useContractWrite(writeConfig)
```

## Viem Public Client

```typescript
import { createPublicClient, http } from 'viem'
import { pharosMainnet } from './pharosChain'

const publicClient = createPublicClient({
  chain: pharosMainnet,
  transport: http('https://rpc.pharos.xyz'),
})

const blockNumber = await publicClient.getBlockNumber()
```

## Viem Wallet Client

```typescript
import { createWalletClient, custom, http } from 'viem'
import { pharosMainnet } from './pharosChain'

const walletClient = createWalletClient({
  chain: pharosMainnet,
  transport: custom(window.ethereum!),
})

const [address] = await walletClient.requestAddresses()
```

## Pharos-Specific Error Handling

Pharos RPC may return these error codes:

| Code | Description |
|------|-------------|
| -32700 | Parse error — malformed request |
| -32000 | Pharos execution reverted — check gas or contract logic |
| -32001 | Pharos transaction underpriced — increase gas price |
| -32002 | Pharos nonce too low — increment and retry |
| -32003 | Pharos insufficient balance for gas |

```typescript
try {
  const tx = await walletClient.sendTransaction({ ... })
} catch (err) {
  if (err.code === -32003) {
    console.error('Insufficient PHRS balance for gas on Pharos')
  }
}
```

## Verification

Config validation in dev tools, component renders without errors.

## Related

frontend-dapp-integration (UI wiring), nextjs-app-router-and-server-actions (routing)

## Gate


Low risk. Present the plan and proceed once the user agrees. Do not skip the plan step.

### Anti-Generic Rules (wagmi-viem-dapp-workflow)
- Every hook example MUST name the contract ABI path and chain ID (688689 or 1672).
- Every read/write example MUST include a specific `address` and `abi` import path.
- Verification MUST name an exact command (e.g., `pnpm vitest run test/hooks/useStake.test.ts`), not "run tests."
- If the repo path is unknown, the first plan step MUST be to locate `package.json` and wagmi config.
- Do NOT use `useReadContract` without pinning `chainId` in the hook.
- Do NOT suggest generic error handling — name the specific error component path (e.g., `components/TxErrorBanner.tsx`).
