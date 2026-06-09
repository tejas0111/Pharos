---
name: pharos-nextjs-app-router-and-server-actions
description: "Handle Next.js App Router, route handlers, server actions, and RSC patterns for Pharos dapps. Use when building Next.js App Router layouts, loading/error/not-found states, server actions, route handlers, or RSC patterns for Pharos web3 frontends. Keywords: Next.js App Router, server actions, route handlers, RSC, layout, loading, error, not-found, Next.js, Pharos, dapp, React, TypeScript, wagmi, viem."
metadata:
  audience: developer
  version: 1.0.0
  category: frontend
slash: true
---

# Next.js App Router and Server Actions

Handle Next.js App Router, route handlers, server actions, and RSC patterns.

## When to Use

Next.js App Router, server actions, route handlers, RSC, Next.js, layout, loading.tsx, error.tsx, not-found.tsx, Next.js 14

## When NOT to Use

Pages Router projects (this subskill is App Router only), or general React patterns (use react-ui-patterns-and-hooks)

## Workflow

1. Map the route, server, and client boundaries.
2. Choose the minimal App Router pattern that fits the feature.
3. Show the plan and proceed once it looks right.
4. Verify the app structure or runtime behavior after the change.

## Output

- route plan
- component boundary notes
- server action notes
- verification result

## Examples

- "Add a Next.js App Router pattern for this dapp flow"
- "Design a server action flow for a contract helper UI"
- "Set up parallel routes and intercepting routes for a multi-step dapp wizard"

## Verification

npm run build and manual route navigation.

## Related

react-ui-patterns-and-hooks (client components), wagmi-viem-dapp-workflow (contract integration)
