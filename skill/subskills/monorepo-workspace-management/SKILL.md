---
name: pharos-monorepo-workspace-management
description: Handle monorepo workspace boundaries, shared packages, Turborepo, pnpm workspaces, and package scripts. Use when the user says: monorepo, workspace, Turborepo, pnpm workspace, shared package.
---

# Monorepo and Workspace Management

Use when the user needs workspace or monorepo changes.

## Workflow

1. Map the workspace structure and package boundaries.
2. Identify the minimum workspace changes required.
3. Present the plan and ask for confirmation.
4. Apply the workspace changes and verify the affected packages.

## Output

- workspace map
- package boundary notes
- script changes
- verification result

## Gate

Medium risk. Show the workspace plan before changing boundaries.
