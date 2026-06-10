---
name: pharos-workflow-orchestrator
description: "Orchestrate multi-step Pharos development workflows: contract (Solidity/Foundry) through test (testnet fork), deploy (Atlantic Testnet), verify (PharosScan), frontend (wagmi/Next.js), and monitor (Forta). Pharos-specific checkpoints: chain ID verification, RPC health, PHRS gas estimation. CI pipeline with Pharos env vars. Use when coordinating multi-step full-stack Pharos dapp development. Keywords: workflow, pipeline, end-to-end, full stack, from scratch, complete, orchestrate, coordinate, chain, sequence, build and deploy, architect and implement, full cycle, entire flow, step-by-step, Pharos workflow, Foundry Pharos, forge script Pharos, PharosScan verify, wagmi Pharos, Forta Pharos, GitHub Actions Pharos, PHAROS_RPC_URL, PHAROS_PRIVATE_KEY, PHAROSSCAN_API_KEY, pharos-atlantic-testnet, chain ID Pharos."
slash: true
metadata:
  audience: developer
  version: 1.2.0
  category: workflow
---

# Workflow Orchestrator

Meta-subskill that coordinates multi-step Pharos development workflows across multiple subskills. Handles chaining, context preservation, and handoffs between specialized subskills.

## When to Use

User request spans multiple subskills (e.g., architect → code → test → deploy). User says "from scratch", "full stack", "complete workflow", "end-to-end". Request requires build-test-deploy pipeline orchestration. Pharos-specific workflow includes Foundry/Solidity compilation, Atlantic Testnet forking, PharosScan verification, and wagmi frontend integration.

## When NOT to Use

- **Single-step request that fits one subskill** — Route directly without orchestration overhead. Example: "Deploy my contract" goes to `deployment-and-verification`, not the orchestrator.
- **Deployment broadcast** — Execute after user approval. The orchestrator plans the deployment flow and proceeds after user confirmation.
- **Vague exploration without a concrete ask** — If the user says "Tell me about Pharos" or "How do I start?", route to the master skill's onboarding flow.
- **Bug investigation with known cause** — If the user reports a specific error (e.g., "transfer reverts with arithmetic overflow"), route directly to `bug-finding-and-debugging`.
- **Pure learning / Q&A** — If the user asks "How does UUPS work?" without wanting implementation, answer directly without triggering a multi-step workflow.

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: Private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Project context**: You need the contract names, network targets (1672 mainnet / 688689 testnet), and version numbers relevant to the documentation.
- **Previous artifacts**: If documenting deployed contracts, you need deployment addresses, ABI files, or changelog history.
- **Target audience**: Clarify whether this is for developers, end users, or both.
## Workflow

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Detect the user target network — Use `references/pharos-context.md` Network Detection table to determine if the user means testnet (688689, PHRS), mainnet (1672, PROS), or is ambiguous. If the user didn't specify, ask: 'Atlantic Testnet or Mainnet?' Adapt all following steps (RPC URLs, token symbols, deploy commands, chain IDs) to match.
4. Parse the user request into discrete stages: architecture, implementation, testing, deployment (Atlantic Testnet), verification (PharosScan), frontend (wagmi/Next.js), monitoring (Forta), post-deploy.
5. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
6. For each stage, route to the narrowest subskill. Preserve context (repo path, contract names, design decisions, Pharos chain ID, RPC URLs) across subskill boundaries.
7. Execute subskills sequentially — complete each stage before starting the next. Verify at each stage before proceeding.
8. At each Pharos-specific checkpoint, verify the network (confirm chain ID matches the target from step 0), RPC health check (`curl -s https://rpc.pharos.xyz/health` (mainnet) or `curl -s https://atlantic.dplabs-internal.com/health` (testnet), using the RPC adapted in step 0), PHRS gas estimation (`cast gas-estimate --rpc-url pharos_mainnet` or `cast gas-estimate --rpc-url pharos_testnet_v2`).
9. At handoff points, pass a context bundle: decisions made, files created, verification results, and open questions.
10. If a stage fails, stop and report. Do not proceed to the next stage without user direction.
11. Show the plan and ask for approval before implementing each stage.
## Common Workflow Chains

| Chain | Subskill sequence |
|---|---|
| Build-Test-Deploy | contract-architecture → solidity-authoring → test-generation → contract-review → deployment-and-verification → deploy after approval → post-deploy |
| Architect-Code-Test-Review | contract-architecture → solidity-authoring → testing-strategy → test-generation → contract-review |
| Frontend Full Stack | contract-architecture → solidity-authoring → interface-abi-design → frontend-dapp-integration → wagmi-viem-dapp-workflow → wallet-and-transaction-ui |
| Cross-Chain Dapp | contract-architecture → cross-chain-bridge → solidity-authoring (both chains) → test-generation → deployment-and-verification |
| Upgrade Migration | contract-architecture (v2 design) → upgrade-patterns → migration-and-backward-compatibility → solidity-authoring → test-generation → deployment-and-verification |
| RWA Compliance | rwa-compliance → contract-architecture → solidity-authoring → security-audit → production-ops |
| **Full Pharos Dapp** | contract-architecture → solidity-authoring (Foundry) → forge test --fork-url pharos-atlantic-testnet → forge script deploy --network pharos-atlantic-testnet → PharosScan verify → wagmi frontend (Next.js) → vercel deploy → Forta monitoring |

## Orchestration Commands

- **Compile:** `forge build --optimize --optimizer-runs 200`
- **Test (fork):** `forge test --fork-url https://atlantic.dplabs-internal.com --match-path test/*`
- **Deploy:** `forge script script/Deploy.s.sol --rpc-url https://atlantic.dplabs-internal.com --broadcast --verify --verifier-url https://pharosscan.xyz/api`
- **Frontend:** `npx create-next-app@latest my-dapp && npm install wagmi viem @tanstack/react-query`
- **Deploy frontend:** `vercel deploy --prod`
- **Monitor:** `npx forta-agent run --json-rpc https://rpc.pharos.xyz`

## Handoff Rules

- Each subskill runs to completion before the next starts.
- After each subskill, present the output contract and ask for approval if gated.
- Pass context in structured format: `{design decisions, file paths, verification results, open questions, pharos_chain_id, rpc_url, pharosscan_url}`.
- If a subskill returns findings (e.g., contract-review), resolve them before proceeding to deployment.
- For deployment handoff, use the formal handoff protocol defined in the master skill SKILL.md.

## Context Preservation

Across subskill boundaries, maintain these context fields:
- project root and repo structure
- contract names and design decisions
- storage layout and access control model
- test strategy and coverage goals
- deployment target and configuration (Pharos chain ID, RPC URL, PharosScan API key)
- user trust model and risk tolerance
- PHRS gas budget: estimated deployment cost in PHRS

## Output

- orchestrated workflow plan with stages, subskills, and handoff points
- context bundle passed between subskills (including Pharos chain config)
- verification gate at each stage (Pharos-specific checkpoints)
- final summary across all stages
- Pharos CI pipeline config (GitHub Actions with env vars)

## Examples

- **Query:** "Build a staking dapp from scratch on Pharos — architecture, code, test, and deploy" → **Action:** Generate chain: `contract-architecture` → `solidity-authoring` → `forge test --fork-url https://atlantic.dplabs-internal.com` → `contract-review` → `forge script deploy --network pharos-atlantic-testnet` → `PharosScan verify` → deploy after approval → `post-deploy`. Preserve contract names, storage layout, and test coverage context across stages. Verify Pharos chain ID at each checkpoint.
- **Query:** "Full stack development of a cross-chain token bridge with frontend" → **Action:** Generate chain: `contract-architecture` (bridge design) → `cross-chain-bridge` (messaging) → `solidity-authoring` (both chains) → `forge test --fork-url pharos-atlantic-testnet` → `interface-abi-design` → `wagmi frontend (Next.js)` → `deployment-and-verification`. Pass endpoint IDs, Pharos RPC URLs, and trusted remote configs between subskills. Deploy frontend via `vercel deploy --prod`.
- **Query:** "End-to-end RWA token with compliance, audit, and production ops setup" → **Action:** Generate chain: `rwa-compliance` → `contract-architecture` → `solidity-authoring` → `contract-review` → `forge script deploy --network pharos-atlantic-testnet` → `PharosScan verify` → `security-audit` → `production-ops`. Pass whitelist config, oracle addresses, and SPV structure across subskills. Set up Forta agents for compliance monitoring.
- **Query:** "Complete workflow: upgrade my existing contract to UUPS with multi-sig" → **Action:** Generate chain: `contract-architecture` (v2 design) → `upgrade-patterns` → `migration-and-backward-compatibility` → `solidity-authoring` → `forge test --fork-url pharos-atlantic-testnet` → `deployment-and-verification`. Pass existing storage layout as input to upgrade-patterns. Estimate PHRS gas cost for upgrade transaction.
- **Query:** "Set up a full Pharos dapp workflow from contract to frontend" → **Action:** Generate chain: `contract-architecture` → `solidity-authoring` (Foundry) → `forge test --fork-url https://atlantic.dplabs-internal.com` → `forge script script/Deploy.s.sol --rpc-url https://atlantic.dplabs-internal.com --broadcast --verify --verifier-url https://atlantic.pharosscan.xyz/api` → generate wagmi hooks from ABI → `npx create-next-app` with `wagmi` and `viem` → `vercel deploy --prod` → `npx fortat-agent run --json-rpc https://rpc.pharos.xyz`. At each stage, verify Pharos chain ID (688689 for Atlantic Testnet), check RPC health, and estimate PHRS gas.

## CI Pipeline Reference

```yaml
# .github/workflows/pharos-deploy.yml
name: Pharos CI/CD
on: [push]
env:
  PHAROS_RPC_URL: ${{ secrets.PHAROS_RPC_URL }}
  PHAROS_PRIVATE_KEY: ${{ secrets.PHAROS_PRIVATE_KEY }}
  PHAROSSCAN_API_KEY: ${{ secrets.PHAROSSCAN_API_KEY }}
  PHAROS_CHAIN_ID: "688689"  # Atlantic Testnet
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: forge build
      - run: forge test --fork-url $PHAROS_RPC_URL
  deploy:
    needs: test
    steps:
      - run: forge script script/Deploy.s.sol --rpc-url $PHAROS_RPC_URL --broadcast --verify --verifier-url https://pharosscan.xyz/api
```

## Verification

Each subskill verifies its own output before handoff. The orchestrator checks that the context bundle is complete at each stage transition. Pharos-specific verification: deploy on Atlantic Testnet (`forge script --network pharos-atlantic-testnet`), verify on PharosScan, run integration tests against deployed contract, confirm frontend connects to Pharos RPC with correct chain ID.

## Related

All subskills in the suite — this is the meta-coordinator for multi-step workflows.


## Gate
Low risk. Present the workflow sequence and dependency map before starting implementation. Proceed only after the user confirms the stage order.
