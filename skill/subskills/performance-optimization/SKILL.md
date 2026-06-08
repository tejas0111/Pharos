---
name: pharos-performance-optimization
description: "Find and reduce runtime, render, bundle, or gas-adjacent inefficiencies in code paths. Use when the user says: performance, optimize, slow, bottleneck, bundle size, latency, gas optimization, too slow, speed up, reduce gas. Do NOT use for: readability or structural improvements (use refactoring-and-code-health), or bug fixes (use bug-finding-and-debugging). See also: refactoring-and-code-health (non-performance structure changes), solidity-authoring (contract gas optimization)."
---

# Performance Optimization

Find and reduce runtime, render, bundle, or gas-adjacent inefficiencies in code paths.

## When to Use

performance, optimize, slow, bottleneck, bundle size, latency, gas optimization, too slow, speed up, reduce gas

## When NOT to Use

readability or structural improvements (use refactoring-and-code-health), or bug fixes (use bug-finding-and-debugging)

## Workflow

1. Locate the performance bottleneck or suspected hot path.
2. Propose a measurable optimization strategy.
3. Show the plan and ask for approval before changes.
4. Implement the smallest change that improves the metric and verify it.

## Output

- bottleneck analysis
- optimization plan
- metric target
- verification result

## Examples

- "Optimize this React rendering path"
- "Reduce the build size and startup cost of this dapp"
- "Find gas optimization opportunities in this Solidity contract's hot loops"

## Verification

Before/after metric comparison (render time, bundle size, gas estimate).

## Related

refactoring-and-code-health (non-performance structure changes), solidity-authoring (contract gas optimization)
