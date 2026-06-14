---
name: pharos-wallet-and-transaction-ui
description: "Design Pharos dapp wallet connection, transaction preview, status, and history screens that feel reliable. Use when building wallet connect UI, transaction modals, tx status screens, transaction history, or connection flows for Pharos web3 dapps (mainnet 1672 / testnet 688689). Keywords: wallet UI, transaction UI, preview, status screen, history, wallet connect, tx modal, transaction status, wagmi, viem, ethers, Next.js, React, TypeScript, Pharos, web3, dapp, pharosscan."
metadata:
  audience: developer
  version: 1.2.0
  category: frontend
slash: true
---

# Wallet and Transaction UI

Design wallet connection, transaction preview, status, and history screens that feel reliable.

## When to Use

wallet UI, transaction UI, preview, status screen, history, connection flow, wallet connect button, tx modal, transaction status

## When NOT to Use

wiring contract reads/writes (use frontend-dapp-integration), or designing general UI patterns (use react-ui-patterns-and-hooks)

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
4. Identify the wallet states, transaction states, and error states.
5. Check prerequisites: verify Node.js/pnpm are installed, dependencies are installed, and network config is correct. Ask the user for any missing values before proceeding.
6. Define the screen sequence and what each state shows.
7. Present the UI plan and ask for changes before implementation.
8. Build the smallest working state machine and verify the transitions.
## Output

- screen flow
- state machine
- copy plan
- error-state checklist

## Examples

- "Design a PHRS transfer preview modal with gas estimation and PharosScan link"
- "Create wallet status and PHRS balance history for a Pharos dapp"
- "Build a wallet connection flow for Pharos Pacific mainnet (1672) and testnet (688689)"
- "Show transaction confirmation screen linking to https://atlantic.pharosscan.xyz/tx/{hash} on mainnet or testnet"
- "Implement wallet connect button using wagmi useConnect with Pharos chain config"
- "Build a transaction history view linking tx hashes to PharosScan explorer"

## Verification

Component renders all states (loading, success, error, empty) in browser or storybook. Verify network switching between Pharos mainnet (1672) and testnet (688689). Confirm tx hash links resolve on PharosScan (https://atlantic.pharosscan.xyz/tx/{hash}).

## Pharos Configuration

### Network Details
- **Pacific Mainnet**: Chain ID 1672, RPC `https://rpc.pharos.xyz`, Explorer https://www.pharosscan.xyz
- **Atlantic Testnet**: Chain ID 688689, RPC `https://atlantic.dplabs-internal.com`, Explorer https://atlantic.pharosscan.xyz
- **Native currency**: PHRS (mainnet & testnet, 18 decimals)

### Wallet Connect (wagmi + RainbowKit + viem)

#### RainbowKit Provider (app/providers.tsx)
```tsx
'use client'

import { WagmiProvider, http } from 'wagmi'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { RainbowKitProvider, getDefaultConfig } from '@rainbow-me/rainbowkit'
import { defineChain } from 'viem'
import '@rainbow-me/rainbowkit/styles.css'

const pharosMainnet = defineChain({
  id: 1672,
  name: 'Pharos Mainnet',
  nativeCurrency: { name: 'PHRS', symbol: 'PHRS', decimals: 18 },
  rpcUrls: { default: { http: ['https://rpc.pharos.xyz'] } },
  blockExplorers: { default: { name: 'PharosScan', url: 'https://pharosscan.xyz' } },
})

const config = getDefaultConfig({
  appName: 'Pharos Dapp',
  projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID!,
  chains: [pharosMainnet],
  transports: { [pharosMainnet.id]: http('https://rpc.pharos.xyz') },
  ssr: true,
})

const queryClient = new QueryClient()

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>{children}</RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  )
}
```

#### PHRS Balance + Send PHRS Form
```tsx
'use client'

import { useAccount, useBalance, useSendTransaction, useWaitForTransactionReceipt } from 'wagmi'
import { parseEther } from 'viem'
import { useState } from 'react'
import { pharosMainnet } from './pharosChains'

export function SendPhrsForm() {
  const { address, isConnected } = useAccount()
  const { data: balance } = useBalance({ address, chainId: pharosMainnet.id })
  const { data: hash, sendTransaction, isPending } = useSendTransaction()
  const { isLoading: isConfirming } = useWaitForTransactionReceipt({ hash })
  const [to, setTo] = useState('')
  const [amount, setAmount] = useState('')

  if (!isConnected) return <p>Connect wallet</p>

  return (
    <div>
      <p>PHRS: {balance?.formatted ?? '0'}</p>
      <input placeholder="0x..." value={to} onChange={e => setTo(e.target.value)} />
      <input type="number" placeholder="Amount" value={amount} onChange={e => setAmount(e.target.value)} />
      <button disabled={isPending || isConfirming} onClick={() => sendTransaction({ to: to as `0x${string}`, value: parseEther(amount || '0') })}>
        {isConfirming ? 'Sending...' : 'Send PHRS'}
      </button>
      {hash && <a href={`https://pharosscan.xyz/tx/${hash}`} target="_blank">View on PharosScan</a>}
    </div>
  )
}
```

#### Transaction Status Tracker
```tsx
'use client'

import { useWaitForTransactionReceipt } from 'wagmi'

export function TxStatus({ hash }: { hash: `0x${string}` }) {
  const { isLoading, isSuccess, isError, data } = useWaitForTransactionReceipt({ hash })

  if (isLoading) return <p>⏳ Confirming on Pharos...</p>
  if (isError) return <p>❌ Transaction failed</p>
  if (isSuccess) return <p>✅ Confirmed in block {data.blockNumber.toString()}</p>

  return null
}
```

### Transaction Status Link
Append tx hash to explorer URL: `https://atlantic.pharosscan.xyz/tx/{txHash}` (same URL for both mainnet and testnet).

### Transaction History Pattern
Use PharosScan API to fetch transaction history for a wallet:
```typescript
const TX_HISTORY_API = 'https://api.www.pharosscan.xyz/pharos-mainnet/v1/explorer/command_api/account_tx'

async function fetchTxHistory(address: string, page = 1) {
  const res = await fetch(
    `${TX_HISTORY_API}?address=${address}&page=${page}&limit=20`
  )
  return res.json()
}
```

Use `https://api.atlantic.pharosscan.xyz/pharos-testnet/v1/explorer/command_api/account_tx` for testnet.

## Verification

Component renders all states (loading, success, error, empty) in browser or storybook. Verify network switching between Pharos mainnet (1672) and testnet (688689). Confirm tx hash links resolve on PharosScan (https://atlantic.pharosscan.xyz/tx/{hash}). SSR: add `serverExternalPackages: ['viem']` to next.config.js.

## Related

frontend-dapp-integration (data wiring), react-ui-patterns-and-hooks (component patterns, wagmi config example), wagmi-viem-dapp-workflow (integration helpers)

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the `PLAN.md` with the full implementation strategy, environment-aware safeguards, and verification steps.
- Wait for explicit 'Approve' or 'Proceed' from the user.

**Phase 2 — Execute (wait for approval):**
- Execute the approved plan from `PLAN.md`.
- Do NOT Change transaction behavior, gas display logic, chain-gating rules, or deploy UI changes
- Perform a final "Ready to Broadcast?" check for any high-risk on-chain actions.
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions.