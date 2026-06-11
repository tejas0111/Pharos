---
name: pharos-deployment-and-verification
description: Prepare deploy scripts, env variables, explorer verification, and post-deploy release checks. Use when the user says: deploy, verification, explorer, release, publish contract.
---

# Deployment and Verification

Use when the user needs release or deploy preparation.

## Workflow

1. Confirm the deployment target, network, and required config.
2. Draft the deploy and verification steps explicitly.
3. Present the plan and wait for approval before any deploy-side change.
4. Verify the deployed artifact and capture the outcome.

## Output

- deployment steps
- verification checklist
- env var list
- post-deploy checks

## Gate

High risk. Do not touch deployment behavior before approval.
