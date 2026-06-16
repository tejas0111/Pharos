---
name: pharos-dapp-quality
description: "Make Pharos dapps production-ready: accessibility, internationalization, state management, and UX quality. Use when auditing dapp accessibility, adding i18n/localization, managing dapp-wide state, or improving overall frontend quality. Keywords: accessibility, a11y, i18n, localization, state management, Zustand, Redux, context, UX, quality, dapp, Pharos, web3, frontend."
metadata:
  audience: developer
  version: 1.2.0
  category: frontend
slash: true
---

# Pharos Dapp Quality

Make Pharos dapps production-ready across three dimensions: accessibility, internationalization, and state management.

## When to Use

Auditing dapp accessibility (keyboard nav, screen reader, contrast), adding i18n for multi-language support, setting up dapp-wide state management (wallet state, tx history, user preferences), or any frontend quality polish.

## When NOT to Use

Component UI patterns (use dapp-ui-workflow), wallet/tx-specific UX (use wallet-and-transaction-ui), wagmi provider setup (use wagmi-viem-dapp-workflow).

---

## 1. Accessibility for Pharos Dapps

### Transaction Lifecycle A11y

| State | A11y Requirement |
|-------|-----------------|
| `idle` | Submit button enabled, clear label e.g. "Stake PHRS" |
| `connecting` | `aria-busy="true"` on wallet button, announcement: "Connecting wallet…" |
| `prompt` | Focus moves to wallet modal, focus trap inside modal |
| `pending` | `role="status"` area announces tx hash, spinner with `aria-label="Transaction pending"` |
| `confirmed` | Success announcement: "Transaction confirmed" via `aria-live="polite"` |
| `failed` | Error message with `role="alert"`, focus moves to error + retry button |

### Web3-Specific A11y Checklist

- wallet connect modal has focus trap (user can't tab outside modal)
- tx confirm button is keyboard-reachable and labeled (not just an icon)
- gas estimate and balance are announced when they update (`aria-live="polite"`)
- network switch prompts are announced
- error messages use `role="alert"` and are linked to the triggering input
- all interactive elements have visible focus indicators (not just `outline: none`)

### Severity Rubric for Dapp A11y

| Severity | Example |
|----------|---------|
| Critical | Submit button unreachable by keyboard — user cannot stake |
| High | No focus indicator on wallet connect — keyboard user can't tell where they are |
| Medium | Missing `aria-label` on icon buttons — screen reader says "button" |
| Low | Semantic heading order off by one level |

---

## 2. Internationalization (i18n) for Dapps

### Why i18n Matters for Pharos

Pharos targets real-world asset (RWA) tokenization — a global market. Dapps must support multiple languages for regulatory disclosures, staking interfaces, and transaction confirmations.

### Setup Pattern

- use `next-intl` or `react-i18next` as the i18n library
- namespace translations by feature: `common`, `staking`, `governance`, `errors`
- store locale in user preferences (localStorage), not in wagmi state
- use TypeScript for type-safe translation keys:

```ts
const messages = {
  en: { stake: { title: "Stake PHRS", button: "Confirm Stake" } },
  zh: { stake: { title: "质押 PHRS", button: "确认质押" } },
} as const;
```

### Pharos-Specific Strings to Translate

- network names: "Atlantic Testnet", "Pacific Mainnet"
- currency symbols: PHRS, PROS
- transaction states: "Pending", "Confirmed", "Failed"
- error messages: "Insufficient balance", "Network switch required", "Transaction rejected"

---

## 3. State Management for Dapps

### What Needs Dapp-Wide State

| State | Source of Truth | Recommended Approach |
|-------|----------------|---------------------|
| Wallet connection | wagmi `useAccount` | Use wagmi's built-in store |
| Current network | wagmi `useChain` | Use wagmi's built-in store |
| Transaction history | Local persistence | Zustand + localStorage |
| User preferences | Local persistence | Zustand + localStorage |
| Cached on-chain data | wagmi query cache | wagmi's built-in cache + `refetchInterval` |
| Form state | React state / hook form | Local component state |

### When to Use External State Management

- tx history across pages → Zustand store persisted to localStorage
- user preferences (locale, theme, slippage) → Zustand store
- multi-step flows (swap, bridge) → Zustand store with undo support
- real-time data (order book, leaderboard) → wagmi query cache + refetch

Avoid Redux for dapps — Zustand is simpler, TypeScript-native, and works better with wagmi's hook-based model.

```ts
// Example: tx history store with Zustand
import { create } from "zustand";
import { persist } from "zustand/middleware";

interface TxHistoryEntry {
  hash: `0x${string}`;
  chainId: number;
  type: "stake" | "unstake" | "claim" | "transfer";
  timestamp: number;
  status: "pending" | "confirmed" | "failed";
}

interface TxHistoryStore {
  txs: TxHistoryEntry[];
  addTx: (tx: TxHistoryEntry) => void;
  updateTx: (hash: `0x${string}`, status: TxHistoryEntry["status"]) => void;
}

export const useTxHistory = create<TxHistoryStore>()(
  persist(
    (set) => ({
      txs: [],
      addTx: (tx) => set((s) => ({ txs: [tx, ...s.txs] })),
      updateTx: (hash, status) =>
        set((s) => ({
          txs: s.txs.map((t) => (t.hash === hash ? { ...t, status } : t)),
        })),
    }),
    { name: "pharos-tx-history" },
  ),
);
```

### What NOT to Store

- private keys (use wagmi `connector` + wallet)
- RPC URLs (use environment variables)
- contract ABIs (fetch from explorer or import from artifacts)
- gas prices (fetch fresh each time)

---

## References

- `skill/subskills/wallet-and-transaction-ui/SKILL.md` — tx UX patterns
- `skill/subskills/frontend-dapp-integration/SKILL.md` — full dapp integration
- `skill/subskills/dapp-ui-workflow/SKILL.md` — component and UI patterns
