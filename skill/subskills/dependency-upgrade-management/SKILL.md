---
name: pharos-dependency-upgrade-management
description: Upgrade npm packages, toolchains, and Solidity dependencies with compatibility checks and rollback planning. Use when the user says: dependency upgrade, package update, toolchain update, version bump.
---

# Dependency Upgrade Management

Use when the user wants packages or toolchains upgraded safely.

## Workflow

1. List the packages or toolchain components that need changing.
2. Check compatibility risk and any required code changes.
3. Present the upgrade plan and ask for confirmation.
4. Apply the upgrade and verify the build or tests.

## Output

- upgrade plan
- compatibility notes
- version list
- verification result

## Gate

Medium risk. Show the plan before making version changes.
