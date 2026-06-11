---
name: pharos-frontend-dapp-integration
description: "Connect UI components to contract actions, state, and transaction previews. Use when the user says: frontend, dapp, UI integration, wallet connect, view state, transaction preview, wire up the contract, connect UI to contract, dapp frontend. Do NOT use for: designing pure UI without contract interaction (use react-ui-patterns-and-hooks or tailwind-shadcn-ui-workflow), or planning the integration (use protocol-integration-planning). See also: wagmi-viem-dapp-workflow (integration helpers), wallet-and-transaction-ui (wallet states), interface-abi-design (consuming ABI)."
---

# Frontend Dapp Integration

Connect UI components to contract actions, state, and transaction previews.

## When to Use

frontend, dapp, UI integration, wallet connect, view state, transaction preview, wire up the contract, connect UI to contract, dapp frontend

## When NOT to Use

designing pure UI without contract interaction (use react-ui-patterns-and-hooks or tailwind-shadcn-ui-workflow), or planning the integration (use protocol-integration-planning)

## Workflow

1. Map the user journey and the contract state the UI needs.
2. Choose the minimal component tree and data flow.
3. Show the integration plan, including files and props.
4. Implement the UI wiring after the user confirms the direction.

## Output

- component map
- data flow
- state plan
- integration notes

## Examples

- "Integrate a Next.js UI with contract reads and writes"
- "Build the frontend layer for a mint flow with transaction preview"
- "Wire a wallet connect button to a token balance display"

## Verification

npm run build, manual flow check in browser or storybook.

## Related

wagmi-viem-dapp-workflow (integration helpers), wallet-and-transaction-ui (wallet states), interface-abi-design (consuming ABI)
