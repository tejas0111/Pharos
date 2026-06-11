---
name: pharos-wagmi-viem-dapp-workflow
description: "Handle wallet connection, contract reads, writes, and dapp integration patterns using Wagmi and Viem. Use when the user says: Wagmi, Viem, wallet connect, contract read, contract write, dapp workflow, useContractRead, useContractWrite, useAccount, useWalletClient. Do NOT use for: general React patterns (use react-ui-patterns-and-hooks), or full frontend layout (use tailwind-shadcn-ui-workflow). See also: frontend-dapp-integration (UI wiring), nextjs-app-router-and-server-actions (routing)."
---

# Wagmi and Viem Dapp Workflow

Handle wallet connection, contract reads, writes, and dapp integration patterns using Wagmi and Viem.

## When to Use

Wagmi, Viem, wallet connect, contract read, contract write, dapp workflow, useContractRead, useContractWrite, useAccount, useWalletClient

## When NOT to Use

general React patterns (use react-ui-patterns-and-hooks), or full frontend layout (use tailwind-shadcn-ui-workflow)

## Workflow

1. Map the contract and wallet interactions the UI needs.
2. Choose the minimal Wagmi and Viem integration pattern.
3. Show the plan and proceed once it looks right.
4. Verify the configuration and flow with a small smoke check.

## Output

- integration plan
- hook notes
- config notes
- smoke-check suggestion

## Examples

- "Wire Wagmi and Viem into this dapp flow"
- "Plan the contract read and write helpers for a wallet-connected UI"
- "Set up Wagmi config with Pharos chain and wallet connectors"

## Verification

Config validation in dev tools, component renders without errors.

## Related

frontend-dapp-integration (UI wiring), nextjs-app-router-and-server-actions (routing)
