---
name: pharos-migration-and-backward-compatibility
description: Plan safe contract upgrades, data migrations, compatibility layers, and rollback paths. Use when the user says: migration, backward compatibility, upgrade path, data move, breaking change.
---

# Migration and Backward Compatibility

Use when the user needs a safe upgrade or rewrite path.

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

## Gate

High risk. Do not change compatibility-sensitive code before approval.
