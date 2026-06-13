---
name: pharos-react-ui-patterns-and-hooks
description: "Improve React hooks, component boundaries, and client-side UI patterns for Pharos dapps. Use when designing React hooks, component patterns, context, custom hooks, component composition, or UI patterns for Pharos web3 frontends. Keywords: React hooks, component pattern, context, state hook, UI patterns, custom hook, component design, composition, Pharos, dapp, Next.js, TypeScript, wagmi, viem, tailwind, shadcn."
metadata:
  audience: developer
  version: 1.0.0
  category: frontend
slash: true
---

# React UI Patterns and Hooks

Improve React hooks, component boundaries, and client-side UI patterns.

## When to Use

React hooks, component pattern, context, state hook, UI patterns, custom hook, component design, React component, composition

## When NOT to Use

dapp-specific integration patterns (use wagmi-viem-dapp-workflow), or state management (use state-management-integration)

## Workflow

1. Identify the state and rendering pattern that needs support.
2. Suggest the smallest React pattern that fits the feature.
3. Show the plan and proceed once it looks right.
4. Keep the component shape simple enough to maintain.

## Output

- hook plan
- component notes
- rendering notes
- follow-up suggestions

## Examples

- "Refine this React hook and component boundary"
- "Design a cleaner state pattern for this wallet flow UI"
- "Create a reusable data-fetching hook pattern for this dapp"

## Verification

npm run build and component rendering check.

## Related

state-management-integration (global state), frontend-dapp-integration (dapp-specific)
