---
name: pharos-monorepo-workspace-management
description: "Handle workspace boundaries, package scripts, and shared tooling in monorepos. Use when the user says: monorepo, workspace, Turborepo, pnpm workspace, shared package, workspace boundaries, package scripts, multi-package. Do NOT use for: working within a single package (use the relevant feature subskill), or adding a single dependency (use dependency-upgrade-management). See also: dependency-upgrade-management (package version changes), repo-automation-and-tooling (workspace scripts)."
---

# Monorepo and Workspace Management

Handle workspace boundaries, package scripts, and shared tooling in monorepos.

## When to Use

monorepo, workspace, Turborepo, pnpm workspace, shared package, workspace boundaries, package scripts, multi-package

## When NOT to Use

working within a single package (use the relevant feature subskill), or adding a single dependency (use dependency-upgrade-management)

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

## Examples

- "Organize this repo as a monorepo with shared packages"
- "Fix the workspace scripts so the app and contracts build together"
- "Set up Turborepo caching for this monorepo's build and test pipeline"

## Verification

npm run build across all packages or turbo run build.

## Related

dependency-upgrade-management (package version changes), repo-automation-and-tooling (workspace scripts)
