---
name: pharos-state-management-integration
description: "Wire Pharos dapp state into query, store, cache, or client-side state tools without creating drift. Use when setting up state management with Zustand, Redux, React Query, Jotai, Recoil, or global store for Pharos web3 dapps. Keywords: state management, Zustand, Redux, query client, cache, store, React Query, Jotai, Recoil, global state, Pharos, dapp, Next.js, React, TypeScript, wagmi, viem."
metadata:
  audience: developer
  version: 1.1.0
  category: frontend
slash: true
---

# State Management Integration

Wire app state into query, store, cache, or client-side state tools without creating drift. Includes Pharos-specific stores for PHRS balance, transaction history via PharosScan API, and connected wallet state.

## Pharos Store Patterns

### Zustand — PHRS Balance Store (Auto-Refresh)

```typescript
import { create } from 'zustand'
import { useEffect } from 'react'
import { createPublicClient, http, formatEther } from 'viem'
import { pharosMainnet } from '@/lib/chains/pharos'

const client = createPublicClient({
  chain: pharosMainnet,
  transport: http('https://rpc.pharos.xyz'),
})

interface PhrsStore {
  balance: string
  isLoading: boolean
  error: string | null
  fetchBalance: (address: `0x${string}`) => Promise<void>
}

export const usePhrsStore = create<PhrsStore>((set) => ({
  balance: '0',
  isLoading: false,
  error: null,
  fetchBalance: async (address) => {
    set({ isLoading: true, error: null })
    try {
      const bal = await client.getBalance({ address })
      set({ balance: formatEther(bal), isLoading: false })
    } catch (e) {
      set({ error: (e as Error).message, isLoading: false })
    }
  },
}))

// Auto-refresh hook
export function useAutoPhrsBalance(address: `0x${string}` | undefined) {
  const { balance, isLoading, error, fetchBalance } = usePhrsStore()
  useEffect(() => {
    if (!address) return
    fetchBalance(address)
    const interval = setInterval(() => fetchBalance(address), 10_000)
    return () => clearInterval(interval)
  }, [address])
  return { balance, isLoading, error }
}
```

### Zustand — Transaction History via PharosScan API

```typescript
import { create } from 'zustand'

interface TxStore {
  txs: any[]
  isLoading: boolean
  fetchTxs: (address: `0x${string}`) => Promise<void>
}

export const useTxStore = create<TxStore>((set) => ({
  txs: [],
  isLoading: false,
  fetchTxs: async (address) => {
    set({ isLoading: true })
    try {
      const res = await fetch(
        `https://api.www.pharosscan.xyz/pharos-mainnet/v1/explorer/command_api/account_tx`,
        { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ address, page: 1, offset: 50 }) }
      )
      const data = await res.json()
      set({ txs: data.data || [], isLoading: false })
    } catch {
      set({ isLoading: false })
    }
  },
}))
```

### Jotai — Network Status (Pharos Chain)

```typescript
import { atom } from 'jotai'
import { createPublicClient, http } from 'viem'
import { pharosMainnet } from '@/lib/chains/pharos'

const client = createPublicClient({
  chain: pharosMainnet,
  transport: http('https://rpc.pharos.xyz'),
})

export const pharosBlockAtom = atom<number | null>(null)
export const pharosGasPriceAtom = atom<bigint | null>(null)

export const pharosNetworkStatusAtom = atom(
  (get) => ({ block: get(pharosBlockAtom), gasPrice: get(pharosGasPriceAtom) }),
  async (get, set) => {
    const block = await client.getBlockNumber()
    const gasPrice = await client.getGasPrice()
    set(pharosBlockAtom, Number(block))
    set(pharosGasPriceAtom, gasPrice)
  }
)
```

### Wagmi + Zustand — Connected Wallet Store

```typescript
import { create } from 'zustand'
import { useEffect } from 'react'
import { useAccount, useDisconnect } from 'wagmi'

interface WalletStore {
  address: `0x${string}` | null
  isConnected: boolean
  chainId: number | null
}

export const useWalletStore = create<WalletStore>(() => ({
  address: null,
  isConnected: false,
  chainId: 1672, // Pharos Mainnet default
}))

// Sync hook — call once in provider
export function useWalletSync() {
  const { address, isConnected, chain } = useAccount()
  useEffect(() => {
    useWalletStore.setState({ address: address ?? null, isConnected, chainId: chain?.id ?? 1672 })
  }, [address, isConnected, chain?.id])
}
```

## When to Use

state management, Zustand, Redux, query client, cache, store, React Query, Jotai, Recoil, global state

## When NOT to Use

component-local state patterns (use react-ui-patterns-and-hooks), or contract state wiring (use frontend-dapp-integration)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Node.js**: >=18. Run `node --version` to verify.
- **pnpm**: installed. Run `pnpm --version` to verify (or npm/yarn if your project uses those).
- **Dependencies**: Run `pnpm install` (or `npm install`) before proceeding.
- **Chain config**: Pharos chain (mainnet 1672 / Atlantic Testnet 688689) must be configured in wagmi or viem. See `packages/shared/src/pharosChain.ts` for the canonical config.
- **RPC endpoint**: Ensure your app's RPC URL points to `https://rpc.pharos.xyz` (mainnet) or `https://atlantic.dplabs-internal.com` (testnet).
- **Wallet**: A browser wallet (MetaMask, WalletConnect, etc.) with the Pharos network added for testing.

## Workflow

0. Detect the user target network — Use `references/pharos-context.md` Network Detection table to determine if the user means testnet (688689, PHRS), mainnet (1672, PROS), or is ambiguous. If the user didn't specify, ask: 'Atlantic Testnet or Mainnet?' Adapt all following steps (RPC URLs, token symbols, deploy commands, chain IDs) to match.
1. Identify the state ownership model and update flow.
2. Check prerequisites: verify Node.js/pnpm are installed, dependencies are installed, and network config is correct. Ask the user for any missing values before proceeding.
3. Choose the minimal state tool or pattern that fits the app.
4. Show the plan and ask for approval before implementation.
5. Wire the state and verify the update path.

## Output

- state flow
- store design
- update plan
- verification notes

## Examples

- "Integrate Zustand into this Pharos dashboard with auto-refreshing PHRS balance"
- "Plan how React Query should handle cached contract reads on Pharos mainnet"
- "Design a Jotai atom for Pharos network status (block number, gas price via rpc.pharos.xyz)"
- "Create a PharosScan transaction history store for address 0x..."

## Verification

State updates correctly in components. npm run build.

## Related

react-ui-patterns-and-hooks (local state), frontend-dapp-integration (contract state)

## Gate


Medium risk. Present query key and fetch-state mapping before changing `QueryClient` defaults or global `staleTime`. Do not alter invalidation tied to transaction success without user approval.
