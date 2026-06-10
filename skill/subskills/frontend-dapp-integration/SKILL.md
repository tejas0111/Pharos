---
name: pharos-frontend-dapp-integration
description: "Connect Pharos dapp UI components to contract actions, onchain state, and transaction previews using wagmi/viem/ethers with Pharos network configs. Use when wiring up frontend to Pharos contracts, integrating wallet connect, displaying contract state, or building transaction flows for Pharos dapps. Keywords: frontend, dapp, UI integration, wallet connect, contract read, contract write, transaction preview, wagmi, viem, ethers, Next.js, React, TypeScript, Pharos, PHRS, web3, chain config, RPC."
metadata:
  audience: developer
  version: 1.2.0
  category: frontend
  slash: true
---

# Frontend Dapp Integration

Connect UI components to contract actions, state, and transaction previews.

## When to Use

frontend, dapp, UI integration, wallet connect, view state, transaction preview, wire up the contract, connect UI to contract, dapp frontend

## When NOT to Use

designing pure UI without contract interaction (use react-ui-patterns-and-hooks or tailwind-shadcn-ui-workflow), or planning the integration (use protocol-integration-planning)

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
3. Detect the user target network — Use `references/pharos-context.md` Network Detection table to determine if the user means testnet (688689, PHRS), mainnet (1672, PROS), or is ambiguous. If the user didn't specify, ask: 'Atlantic Testnet or Mainnet?' Adapt all following steps (RPC URLs, token symbols, deploy commands, chain IDs) to match.
4. Map the user journey and the contract state the UI needs.
5. Check prerequisites: verify Node.js/pnpm are installed, dependencies are installed, and network config is correct. Ask the user for any missing values before proceeding.
6. Choose the minimal component tree and data flow.
7. Show the integration plan, including files and props.
8. Implement the UI wiring after the user confirms the direction.
## Output

- component map
- data flow
- state plan
- integration notes

## Examples

- "Integrate a Next.js UI with Pharos contract reads/writes on chain 1672"
- "Build the frontend layer for a PHRS mint flow with transaction preview on Pharos testnet (688689)"
- "Wire a wallet connect button to PROS balance display using wagmi Pharos mainnet config"
- "Connect UI to a Pharos DEX contract with PharosScan tx links"

## Pharos Configuration

### Network Details
- **Pharos Mainnet**: Chain ID 1672, RPC `https://rpc.pharos.xyz`, Explorer https://www.pharosscan.xyz
- **Pharos Atlantic Testnet**: Chain ID 688689, RPC `https://atlantic.dplabs-internal.com`, Explorer https://atlantic.pharosscan.xyz
- **Native currency**: PHRS (mainnet & testnet, 18 decimals)

### Wallet Connect (wagmi + viem)
```typescript
import { defineChain } from 'viem'

export const pharosMainnet = defineChain({
  id: 1672,
  name: 'Pharos Mainnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: { default: { http: ['https://rpc.pharos.xyz'] } },
  blockExplorers: { default: { name: 'PharosScan', url: 'https://pharosscan.xyz' } },
})

export const pharosTestnet = defineChain({
  id: 688689,
  name: 'Pharos Atlantic Testnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: { default: { http: ['https://atlantic.dplabs-internal.com'] } },
  blockExplorers: { default: { name: 'PharosScan', url: 'https://pharosscan.xyz' } },
})
```

Use `createConfig` from wagmi with these chains.

### Contract Interaction Patterns

#### Reading contract state with viem publicClient
```typescript
import { createPublicClient, http } from 'viem'
import { pharosMainnet } from './pharosChain' // from the defineChain config above

const publicClient = createPublicClient({
  chain: pharosMainnet,
  transport: http('https://rpc.pharos.xyz'),
})

// Example: read ERC20 totalSupply
const totalSupply = await publicClient.readContract({
  address: '0x...', // replace with Pharos contract address
  abi: [{ name: 'totalSupply', type: 'function', inputs: [], outputs: [{ type: 'uint256' }], stateMutability: 'view' }],
  functionName: 'totalSupply',
})
// Block time on Pharos is ~2s – reads resolve quickly
```

#### Reading with wagmi useReadContract
```typescript
import { useReadContract } from 'wagmi'
import { pharosMainnet } from './pharosChain'

function PharosBalance({ contractAddress }: { contractAddress: `0x${string}` }) {
  const { data: balance } = useReadContract({
    address: contractAddress,
    abi: [{ name: 'balanceOf', type: 'function', inputs: [{ name: 'account', type: 'address' }], outputs: [{ type: 'uint256' }], stateMutability: 'view' }],
    functionName: 'balanceOf',
    args: ['0x...'], // user address
    chainId: 1672, // Pharos mainnet
  })
  return <div>Balance: {balance?.toString()}</div>
}
```

#### Reading PHRS (native) balance without a contract call
```typescript
import { useBalance } from 'wagmi'
import { pharosMainnet } from './pharosChain'

const { data: phrsBalance } = useBalance({
  address: '0x...', // user address
  chainId: 1672,
  unit: 'ether', // PHRS has 18 decimals
})
```

#### PharosScan API for contract state reads
```typescript
// Read contract state via PharosScan explorer API
const API_URL = 'https://pharosscan.xyz/api/v1/contract/query'
const response = await fetch(API_URL, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    chainId: 1672,
    address: '0x...', // Pharos contract address
    functionName: 'balanceOf',
    args: ['0x...'],
  }),
})
```

- Use `useReadContract` with Pharos chain ID (1672 or 688689) for reads
- Use `useWriteContract` / `useSendTransaction` for writes; ensure wallet is on correct Pharos chain
- Transaction preview: estimate gas via `estimateGas` on Pharos RPC, show PHRS fee
- Pharos transaction receipts: block time ≈ 2s — use `waitForTransactionReceipt` with shorter polling
- Link tx hashes to PharosScan: `https://pharosscan.xyz/tx/{txHash}`

#### Writing with useWriteContract + TX Confirmation

```tsx
'use client'

import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi'
import { parseEther } from 'viem'
import { useState } from 'react'

const ABI = [{ name: 'stake', type: 'function', inputs: [], outputs: [], stateMutability: 'payable' }] as const

export function StakeForm({ contractAddress }: { contractAddress: `0x${string}` }) {
  const [amount, setAmount] = useState('')
  const { data: hash, writeContract, isPending } = useWriteContract()
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash })

  return (
    <div>
      <input type="number" value={amount} onChange={e => setAmount(e.target.value)} placeholder="PHRS amount" />
      <button disabled={isPending || isConfirming} onClick={() => writeContract({
        address: contractAddress, abi: ABI, functionName: 'stake',
        value: parseEther(amount || '0'), chainId: 1672,
      })}>
        {isConfirming ? 'Confirming...' : 'Stake'}
      </button>
      {isPending && <p>Check MetaMask...</p>}
      {isConfirming && <p>⏳ Waiting for Pharos confirmation (~2s block time)</p>}
      {isSuccess && hash && <p>✅ <a href={`https://pharosscan.xyz/tx/${hash}`}>View on PharosScan</a></p>}
    </div>
  )
}
```

#### useQuery for PHRS Balance

```tsx
import { useQuery } from '@tanstack/react-query'
import { createPublicClient, http } from 'viem'
import { pharosMainnet } from './pharosChain'

const client = createPublicClient({ chain: pharosMainnet, transport: http('https://rpc.pharos.xyz') })

export function usePhrsBalanceQuery(address: `0x${string}` | undefined) {
  return useQuery({
    queryKey: ['phrs-balance', address],
    queryFn: async () => {
      if (!address) return null
      const balance = await client.getBalance({ address })
      return balance
    },
    refetchInterval: 10_000, // auto-refresh every 10s
    enabled: !!address,
  })
}
```

## Verification

npm run build, manual flow check in browser or storybook. Verify network switching to Pharos mainnet (1672) and testnet (688689). Confirm tx links resolve on PharosScan.

## Related

wagmi-viem-dapp-workflow (integration helpers), wallet-and-transaction-ui (wallet states), interface-abi-design (consuming ABI)


## Gate
Medium risk. Present the component map and data flow before implementing UI wiring. Do not wire production contract interactions without user confirmation of the integration plan.
