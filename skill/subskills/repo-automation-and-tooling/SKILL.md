---
name: pharos-repo-automation-and-tooling
description: "Design scripts, automation flows, task runners, and local developer tooling for Pharos projects. Use when setting up automation, scripts, Makefiles, precommit hooks, Husky, linting config, or dev tooling for Pharos Solidity and TypeScript repos. Keywords: automation, scripts, task runner, Makefile, precommit, tooling, linting, Husky, CI script, dev tooling, Pharos, Solidity, TypeScript, Foundry, Hardhat, monorepo."
metadata:
  audience: developer
  version: 1.0.0
  category: tooling
slash: true
---

# Repo Automation and Tooling

Design scripts, automation flows, task runners, and local developer tooling.

## When to Use

automation, scripts, task runner, Makefile, precommit, tooling, set up linting, Husky, CI script, dev tooling

## When NOT to Use

modifying application code (use the relevant subskill), or setting up CI pipelines (use ci-and-build-troubleshooting)

## Workflow

1. Identify the repetitive task or workflow that should be automated.
2. Choose the lightest useful automation surface.
3. Show the script or tooling plan and proceed once it looks right.
4. Keep the automation easy to understand and easy to undo.

## Output

- automation plan
- script notes
- tooling checklist
- maintenance notes

## Examples

- "Set up scripts to run lint, test, and build in one command"
- "Design the local tooling workflow for this repo"
- "Create a Makefile with common dev commands for this Solidity project"

## Verification

Run the automated script/check and confirm it works.

## Related

code-review-templates-and-checklists (process automation), ci-and-build-troubleshooting (CI pipelines)
