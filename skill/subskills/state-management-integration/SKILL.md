---
name: pharos-state-management-integration
description: "Wire app state into query, store, cache, or client-side state tools without creating drift. Use when the user says: state management, Zustand, Redux, query client, cache, store, React Query, Jotai, Recoil, global state. Do NOT use for: component-local state patterns (use react-ui-patterns-and-hooks), or contract state wiring (use frontend-dapp-integration). See also: react-ui-patterns-and-hooks (local state), frontend-dapp-integration (contract state)."
---

# State Management Integration

Wire app state into query, store, cache, or client-side state tools without creating drift.

## When to Use

state management, Zustand, Redux, query client, cache, store, React Query, Jotai, Recoil, global state

## When NOT to Use

component-local state patterns (use react-ui-patterns-and-hooks), or contract state wiring (use frontend-dapp-integration)

## Workflow

1. Identify the state ownership model and update flow.
2. Choose the minimal state tool or pattern that fits the app.
3. Show the plan and ask for approval before implementation.
4. Wire the state and verify the update path.

## Output

- state flow
- store design
- update plan
- verification notes

## Examples

- "Integrate Zustand into this dashboard"
- "Plan how React Query should handle cached contract reads in the UI"
- "Design the Redux store structure for a multi-step dapp flow"

## Verification

State updates correctly in components. npm run build.

## Related

react-ui-patterns-and-hooks (local state), frontend-dapp-integration (contract state)
