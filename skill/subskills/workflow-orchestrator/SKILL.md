---
name: workflow-orchestrator
description: "Orchestrate multi-step Pharos development workflows. Use when the user request spans multiple subskills, requires a build-test-deploy pipeline, or needs cross-skill coordination. Keywords: workflow, pipeline, end-to-end, full stack, from scratch, complete, orchestrate, coordinate, chain, sequence, build and deploy, architect and implement, full cycle, entire flow, step-by-step. Do NOT use for: single-step requests that fit a single subskill (route directly), or deployment broadcasting (use pharos-agent-deploy-suite). See also: all subskills in the suite."
slash: true
metadata:
  audience: developer
  version: 1.0.0
  category: workflow
---

# Workflow Orchestrator

Meta-subskill that coordinates multi-step Pharos development workflows across multiple subskills. Handles chaining, context preservation, and handoffs between specialized subskills.

## When to Use

User request spans multiple subskills (e.g., architect → code → test → deploy). User says "from scratch", "full stack", "complete workflow", "end-to-end". Request requires build-test-deploy pipeline orchestration.

## When NOT to Use

Single-step request that fits one subskill — route directly. Deployment broadcast — hand off to pharos-agent-deploy-suite.

## Workflow

1. Parse the user request into discrete stages: architecture, implementation, testing, review, deployment, post-deploy.
2. For each stage, route to the narrowest subskill. Preserve context (repo path, contract names, design decisions) across subskill boundaries.
3. Execute subskills sequentially — complete each stage before starting the next. Verify at each stage before proceeding.
4. At handoff points, pass a context bundle: decisions made, files created, verification results, and open questions.
5. If a stage fails, stop and report. Do not proceed to the next stage without user direction.

## Common Workflow Chains

| Chain | Subskill sequence |
|---|---|
| Build-Test-Deploy | contract-architecture → solidity-authoring → test-generation → contract-review → deployment-and-verification → handoff to pharos-agent-deploy-suite → post-deploy |
| Architect-Code-Test-Review | contract-architecture → solidity-authoring → testing-strategy → test-generation → contract-review |
| Frontend Full Stack | contract-architecture → solidity-authoring → interface-abi-design → frontend-dapp-integration → wagmi-viem-dapp-workflow → wallet-and-transaction-ui |
| Cross-Chain Dapp | contract-architecture → cross-chain-bridge → solidity-authoring (both chains) → test-generation → deployment-and-verification |
| Upgrade Migration | contract-architecture (v2 design) → upgrade-patterns → migration-and-backward-compatibility → solidity-authoring → test-generation → deployment-and-verification |
| RWA Compliance | rwa-compliance → contract-architecture → solidity-authoring → security-audit → production-ops |

## Handoff Rules

- Each subskill runs to completion before the next starts.
- After each subskill, present the output contract and ask for approval if gated.
- Pass context in structured format: `{design decisions, file paths, verification results, open questions}`.
- If a subskill returns findings (e.g., contract-review), resolve them before proceeding to deployment.
- For deployment handoff, use the formal handoff protocol defined in the master skill SKILL.md.

## Context Preservation

Across subskill boundaries, maintain these context fields:
- project root and repo structure
- contract names and design decisions
- storage layout and access control model
- test strategy and coverage goals
- deployment target and configuration
- user trust model and risk tolerance

## Output

- orchestrated workflow plan with stages, subskills, and handoff points
- context bundle passed between subskills
- verification gate at each stage
- final summary across all stages

## Examples

- "Build a staking dapp from scratch on Pharos — architecture, code, test, and deploy"
- "Full stack development of a cross-chain token bridge with frontend"
- "End-to-end RWA token with compliance, audit, and production ops setup"
- "Complete workflow: upgrade my existing contract to UUPS with multi-sig"

## Verification

Each subskill verifies its own output before handoff. The orchestrator checks that the context bundle is complete at each stage transition. Final end-to-end verification: deploy, verify on explorer, run integration tests.

## Related

All subskills in the suite — this is the meta-coordinator for multi-step workflows.
