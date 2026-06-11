---
name: pharos-interface-abi-design
description: Define contract interfaces, ABI, events, custom errors, and typed bindings for downstream tooling. Use when the user says: ABI, interface, events, errors, typed bindings, contract surface.
---

# Interface and ABI Design

Use when the user needs a clean interface surface for downstream tooling.

## Workflow

1. List the methods, events, and revert paths that must be exposed.
2. Normalize naming so frontend and backend tooling can use the same surface.
3. Show the interface plan and ask if the shape is correct.
4. Generate the interface or binding skeleton after confirmation.

## Output

- interface spec
- event list
- error list
- typed binding notes

## Gate

High risk. Do not change the ABI surface before approval.
