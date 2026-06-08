---
name: pharos-testing-strategy
description: Choose test scope, fixtures, coverage focus, and regression approach before writing tests. Use when the user says: test strategy, coverage, fixtures, edge cases, test plan.
---

# Testing Strategy

Use when the user needs a test plan before implementation.

## Workflow

1. Identify the contract, UI, or integration risks that matter most.
2. Choose unit, integration, and regression coverage appropriately.
3. Present the testing plan with explicit assumptions.
4. Wait for confirmation before generating tests or fixtures.

## Output

- test matrix
- fixture plan
- coverage goals
- regression checklist

## Gate

High risk. Do not generate tests until the strategy is approved.
