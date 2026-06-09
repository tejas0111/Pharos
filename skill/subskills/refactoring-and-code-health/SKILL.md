---
name: pharos-refactoring-and-code-health
description: "Improve Pharos code structure, readability, naming, and separation of concerns without changing behavior. Use when refactoring, cleaning up, simplifying, removing duplication, paying down technical debt, or restructuring Pharos Solidity contracts and TypeScript dapps. Keywords: refactor, code health, cleanup, simplify, remove duplication, technical debt, restructure, readability, Pharos, Solidity, TypeScript, Next.js, React, Foundry, Hardhat."
metadata:
  audience: developer
  version: 1.0.0
  category: contract
slash: true
---

# Refactoring and Code Health

Improve structure, readability, naming, and separation of concerns without changing behavior.

## When to Use

refactor, code health, cleanup, simplify, remove duplication, technical debt, restructure, improve structure, readability

## When NOT to Use

adding new features (use the relevant authoring subskill), or fixing bugs (use bug-finding-and-debugging)

## Workflow

1. Identify the code smells or maintenance costs.
2. Propose the refactor scope and behavior guarantees.
3. Show the plan and ask if the direction is correct.
4. Refactor with tests or checks that preserve behavior.

## Output

- refactor plan
- behavior guarantees
- cleanup notes
- verification result

## Examples

- "Refactor this hook to separate data fetching from UI state"
- "Improve the code health of this contract module without changing behavior"
- "Clean up the duplicated address validation logic across the codebase"

## Verification

No change in test results. npm test still passes. Diff shows no behavior change.

## Related

performance-optimization (performance-driven changes), solidity-authoring (contract refactors)
