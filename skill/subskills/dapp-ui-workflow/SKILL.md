---
name: pharos-dapp-ui-workflow
description: "Design and implement polished Pharos dapp UIs with React, Next.js App Router, Tailwind, and shadcn/ui. Use when building frontend components, page layouts, routing, server/client components, hooks, or UI patterns for Pharos web3 dapps. Keywords: dapp UI, React, Next.js, App Router, Tailwind, shadcn, component, hook, layout, routing, SSR, RSC, client component, server component, Pharos, web3, frontend."
metadata:
  audience: developer
  version: 1.2.0
  category: frontend
slash: true
---

# Pharos Dapp UI Workflow

Build the complete UI layer of a Pharos dapp — React components, page layouts, routing, styling, and hooks — wired to wagmi/viem for on-chain interaction.

## When to Use

Building dapp frontend UI: component design, page layouts, routing, hooks, styling, design system setup, shadcn/ui integration, Tailwind config, Next.js App Router pages and layouts, server/client component boundaries.

## When NOT to Use

Pure contract development (use solidity-authoring), wallet/tx UI patterns (use wallet-and-transaction-ui), wagmi/viem provider setup (use wagmi-viem-dapp-workflow), state management beyond component state (use dapp-quality).

## Core Principles

### Component Architecture for Dapps

- **atomic design**: atoms (Button, Input) → molecules (TxForm, WalletButton) → organisms (StakeDashboard, SwapWidget) → templates/pages
- **compound components**: `WalletStatus` renders connect/disconnect/balance based on account state — single source of truth
- **render-as-you-fetch**: kick off RPC calls (via wagmi queries) at the component level, not in effects
- **error boundary per widget**: wrap each on-chain widget (StakeForm, ClaimPanel) in its own error boundary — a failed RPC call on one widget doesn't crash the whole page

### Next.js App Router for Dapps

| Pattern | Recommendation | Why |
|---------|---------------|-----|
| Wallet provider | Client component at root layout | wagmi creates DOM event listeners, needs `use client` |
| Chain/network pages | Server components fetching from RSC | Static content (docs, explorer links) benefits from SSR |
| Tx submission forms | Client components with `useActionState` (React 19+) or local state with `useReducer` (React 18) | Form state, loading, error handling are interactive |
| Data-heavy views (leaderboard) | Server components + ISR | Cache on-chain data at build time, revalidate periodically |
| Route groups | `(dapp)` for dapp routes, `(marketing)` for landing | Clear separation of client vs server rendering boundaries |

### Tailwind + shadcn/ui for Dapps

- **base theme**: use `next-themes` provider with a `ThemeProvider` wrapper — shadcn components respect CSS variables
- **color tokens**: define on-chain state colors (pending=yellow, confirmed=green, failed=red) as CSS custom properties
- **responsive**: Pharos dapps must work on mobile (wallet apps are mobile-first) — test all layouts at 320px breakpoint
- **loading states**: shadcn `Skeleton` component for every on-chain data fetch — show skeleton immediately, replace with real data
- **transaction forms**: use shadcn `Form` + `react-hook-form` + `zod` validation — validate inputs before sending to wallet

## Common Dapp UI Patterns

### Transaction Flow Component

```
TxButton (disabled=not connected)
  → ConnectWallet (if no account)
  → TxButton (enabled, "Stake PHRS")
    → simulate via wagmi useSimulateContract
    → if simulation fails: show error inline
    → if simulation passes: show gas estimate + "Confirm in Wallet"
      → write via wagmi useWriteContract
        → pending: show spinner + tx hash
        → confirmed: show success + explorer link
        → failed: show error + retry button
```

### Network-Aware Layout

```tsx
// Show different content based on connected network
function NetworkBanner() {
  const { chain } = useAccount();
  if (!chain) return <ConnectPrompt />;
  if (chain.id !== PHAROS_TESTNET.id) return <SwitchNetworkBanner />;
  return <DappContent />;
}
```

## Next.js App Router Patterns

### Route Design for Dapps

| Route | Pattern | Rendering |
|-------|---------|-----------|
| `/` | Landing / marketing page | Server component, ISR |
| `/app` | Dapp layout with wallet provider | Client component wrapper |
| `/app/stake` | Staking interface | Client component |
| `/app/portfolio` | User portfolio with balances | Client component + suspense |
| `/tx/[hash]` | Transaction status page | Server component fetching from RSC |
| `/explorer` | Public data explorer | Server component, ISR every 60s |

### Data Fetching

- use wagmi's built-in hooks (`useReadContract`, `useBalance`) for client-side RPC — they cache and deduplicate
- for server components, use viem directly in RSC: `createPublicClient` → `readContract` → render
- avoid `useEffect` for on-chain reads — wagmi hooks handle this natively

## Hooks You'll Build

| Hook | Purpose | Wagmi Integration |
|------|---------|-------------------|
| `usePharosBalance` | Fetch PHRS/PROS balance | `useBalance` |
| `usePharosRead` | Call any view function | `useReadContract` |
| `usePharosWrite` | Submit any tx with simulation | `useSimulateContract` + `useWriteContract` |
| `useTxStatus` | Track tx lifecycle | `useWaitForTransactionReceipt` |
| `usePharosNetwork` | Current network + switch | `useAccount` + `useSwitchChain` |

## Examples

```tsx
// pages/app/stake/page.tsx — Client component for staking
export default function StakePage() {
  return (
    <ErrorBoundary fallback={<StakeError />}>
      <StakeForm />
    </ErrorBoundary>
  );
}
```

```tsx
// components/PharosStatusBar.tsx — Network-aware status bar
export function PharosStatusBar() {
  const { address, chain } = useAccount();
  const { data: balance } = useBalance({ address });
  return (
    <div className="flex items-center gap-2 text-sm">
      <Badge variant={chain?.id === 688689 ? "default" : "secondary"}>
        {chain?.name || "Not Connected"}
      </Badge>
      <span>{balance?.formatted.slice(0, 6)} PHRS</span>
    </div>
  );
}
```

## References

- `skill/subskills/wallet-and-transaction-ui/SKILL.md` — tx lifecycle UX patterns
- `skill/subskills/wagmi-viem-dapp-workflow/SKILL.md` — wagmi/viem provider setup
- `skill/subskills/frontend-dapp-integration/SKILL.md` — full dapp integration patterns

## Pharos dApp UI Patterns

### Connect Wallet

```typescript
import { createWalletClient, custom } from 'viem';
import { pharosAtlantic } from './chains';

const walletClient = createWalletClient({
  chain: pharosAtlantic,  // Chain ID 688689
  transport: custom(window.ethereum!)
});

const [address] = await walletClient.requestAddresses();
```

### Read Contract State

```typescript
import { createPublicClient, http } from 'viem';

const client = createPublicClient({
  chain: pharosAtlantic,
  transport: http('https://atlantic.dplabs-internal.com')
});

const balance = await client.readContract({
  address: '0x...',
  abi: erc20Abi,
  functionName: 'balanceOf',
  args: [userAddress]
});
```

### Write Contract (with SPN sponsorship)

```typescript
// 1. Build UserOperation
const userOp = await walletClient.prepareUserOperation({
  calls: [{ to: contractAddress, data: encodedCall }]
});

// 2. Send via bundler (or directly to EntryPoint)
const hash = await bundlerClient.sendUserOperation({
  userOp,
  entryPoint: '0x0000000071727De22E5E9d8BAf0edAc6f37da032'
});
```

## Interactive Demo

The project includes an interactive web demo at `web/index.html` showcasing:
- 6 contract cards: SPN Paymaster, zkLogin, LendingPool, DEXPool, StakingPool, RWAToken
- Working button simulators for each contract
- Real-time log viewers with colored tags
- Utilization bars and budget tracking
- Dark theme with animated backgrounds

Run: `cd web && bash serve-demo.sh`

## References

- `web/index.html` — Interactive demo
- `contracts/PharosSPNPaymaster.sol` — Contract integration examples
- Viem docs: https://viem.sh
- Wagmi docs: https://wagmi.sh
