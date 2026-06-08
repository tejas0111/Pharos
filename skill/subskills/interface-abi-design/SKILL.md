---
name: pharos-interface-abi-design
description: "Define interfaces, events, errors, and typed bindings so downstream tooling can integrate cleanly. Use when the user says: ABI, interface, events, errors, typed bindings, contract surface, define the interface, what events should I emit, method signatures. Do NOT use for: writing the full contract implementation (use solidity-authoring), or integrating the ABI into frontend (use frontend-dapp-integration). See also: solidity-authoring (full implementation), frontend-dapp-integration (consuming the ABI)."
---

# Interface and ABI Design

Define interfaces, events, errors, and typed bindings so downstream tooling can integrate cleanly.

## When to Use

ABI, interface, events, errors, typed bindings, contract surface, define the interface, what events should I emit, method signatures

## When NOT to Use

writing the full contract implementation (use solidity-authoring), or integrating the ABI into frontend (use frontend-dapp-integration)

## Workflow

1. List the methods, events, and revert paths that must be exposed.
2. Normalize naming so frontend and backend tooling can use the same surface.
3. Show the ABI/interface plan and ask if the shape is correct.
4. Generate the interface or binding skeleton after confirmation.

## Output

- interface spec
- event list
- error list
- typed binding notes

## Examples

- "Design the ABI for a vault with deposit and withdraw flows"
- "Create a typed interface for the contract methods this dapp needs"
- "Define the events and errors for a new NFT contract"

## Verification

Compile check of interface file. Type generation if using TypeChain or abitype.

## Related

solidity-authoring (full implementation), frontend-dapp-integration (consuming the ABI)
