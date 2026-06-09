---
name: pharos-bug-finding-and-debugging
description: "Trace failures in Pharos contract compile, runtime, test, or dapp UI behavior and propose focused fixes. Use when debugging failing builds, failing tests, runtime errors, transaction reverts, or broken UI behavior in Pharos Solidity dapps. Keywords: bug, debug, error, failing build, failing test, runtime issue, broken, not working, trace failure, root cause, Solidity, Pharos, Foundry, Hardhat, revert, gas, transaction, wagmi, viem, forge, anvil, cast."
metadata:
  audience: developer
  version: 1.0.0
  category: testing
slash: true
---

# Bug Finding and Debugging

Trace failures in compile, runtime, test, or UI behavior and propose focused fixes.

## When to Use

bug, debug, error, failing build, failing test, runtime issue, something is broken, not working, trace failure, root cause

## When NOT to Use

reviewing code without a specific failure (use contract-review), or fixing CI pipelines (use ci-and-build-troubleshooting)

## Workflow

1. Reproduce or reason about the failure from the error output.
2. Isolate the root cause and the smallest safe fix.
3. Show the fix plan and ask for approval before editing.
4. Patch the issue and verify the failure is gone.

## Output

- root cause
- fix plan
- patch notes
- verification result

## Examples

- "Debug this failing contract test and explain the root cause"
- "Find why the frontend transaction state never updates"
- "Investigate why forge script is reverting with out-of-gas"

## Verification

The specific failing test/command passes. Re-run the original failing command.

## Related

contract-review (review before fixing), ci-and-build-troubleshooting (pipeline failures)
