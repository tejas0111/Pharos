---
name: pharos-dependency-upgrade-management
description: "Upgrade Pharos project packages or toolchains with version-aware compatibility checks and rollback planning. Use when upgrading dependencies, bumping package versions, updating toolchains (Foundry, Hardhat, Node), or managing npm/forge dependency updates for Pharos dapps. Keywords: dependency upgrade, package update, toolchain update, version bump, upgrade dependencies, npm update, Foundry, Hardhat, Pharos, Solidity, monorepo, compatiblity, rollback."
metadata:
  audience: developer
  version: 1.0.0
  category: tooling
slash: true
---

# Dependency Upgrade Management

Upgrade packages or toolchains with version-aware compatibility checks and rollback planning.

## When to Use

dependency upgrade, package update, toolchain update, version bump, upgrade dependencies, update packages, npm update, upgrade contract

## When NOT to Use

adding a new dependency (use framework-integration), or refactoring code to work with a new version (use refactoring-and-code-health)

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

## Examples

- "Upgrade the dependencies in this repo and keep the change minimal"
- "Plan the toolchain bump from one TypeScript version to another"
- "Safely upgrade Solidity pragma from 0.8.20 to 0.8.25 across all contracts"

## Verification

npm install/yarn, then npm run build/npm test.

## Related

monorepo-workspace-management (workspace-wide upgrades), framework-integration (adding new dependencies)
