---
name: pharos-migration-and-backward-compatibility
description: "Plan safe migrations, data moves, and compatibility guardrails for upgrades or rewrites. Use when the user says: migration, backward compatibility, upgrade path, data move, breaking change, version upgrade, migrate data, safe upgrade. Do NOT use for: writing new code without migration concerns (use solidity-authoring), or deploying the migration (use deployment-and-verification). See also: contract-architecture (designing for upgradeability), deployment-and-verification (deploying the migration)."
---

# Migration and Backward Compatibility

Plan safe migrations, data moves, and compatibility guardrails for upgrades or rewrites.

## When to Use

migration, backward compatibility, upgrade path, data move, breaking change, version upgrade, migrate data, safe upgrade

## When NOT to Use

writing new code without migration concerns (use solidity-authoring), or deploying the migration (use deployment-and-verification)

## Workflow

1. Identify the old state, new state, and compatibility boundary.
2. Map the migration path, fallbacks, and rollback assumptions.
3. Present the migration plan and ask for confirmation before changes.
4. Implement the smallest safe migration step after approval.

## Output

- migration plan
- compatibility notes
- rollback plan
- verification checklist

## Examples

- "Plan a contract upgrade migration without breaking existing users"
- "Design the compatibility layer for a protocol rewrite"
- "Map the data migration path for a token contract upgrade"

## Verification

Migration script dry run. Compatibility test with existing data.

## Related

contract-architecture (designing for upgradeability), deployment-and-verification (deploying the migration)
