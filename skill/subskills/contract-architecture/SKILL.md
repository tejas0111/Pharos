---
name: pharos-contract-architecture
description: "Design contract modules, storage layout, access control, and upgrade boundaries before code is written. Use when the user says: system design, module boundaries, storage layout, access control, upgradeability, contract architecture, how should I structure, design the architecture. Do NOT use for: writing concrete Solidity (use solidity-authoring), reviewing existing code (use contract-review), or deploying (use deployment-and-verification). See also: solidity-authoring (implementation), interface-abi-design (surface), migration-and-backward-compatibility (upgrade path)."
---

# Contract Architecture

Design contract modules, storage layout, access control, and upgrade boundaries before code is written.

## When to Use

system design, module boundaries, storage layout, access control, upgradeability, contract architecture, how should I structure, design the architecture

## When NOT to Use

writing concrete Solidity (use solidity-authoring), reviewing existing code (use contract-review), or deploying (use deployment-and-verification)

## Workflow

1. Clarify the product goal, trust model, and onchain constraints.
2. Split the system into modules, interfaces, and storage responsibilities.
3. Identify upgrade, ownership, and permission decisions explicitly.
4. Present the architecture and ask for approval before implementation.

## Output

- module map
- storage plan
- access-control plan
- risk notes
- next implementation step

## Examples

- "Design the architecture for a multi-role marketplace contract"
- "Propose the storage and access model for a staking protocol"
- "Plan the upgrade path for a new vault contract"

## Verification

Review the architecture against requirements. No code to compile yet.

## Related

solidity-authoring (implementation), interface-abi-design (surface), migration-and-backward-compatibility (upgrade path)
