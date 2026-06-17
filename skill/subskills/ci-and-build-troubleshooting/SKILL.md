---
name: pharos-ci-and-build-troubleshooting
description: "Diagnose failing builds, type errors, lint jobs, and CI regressions in Pharos projects with a narrow fix path. Use when fixing CI pipeline failures, compilation errors, type errors, lint issues, or broken test jobs in Pharos Solidity or TypeScript projects. Keywords: CI, build failure, lint failure, type error, pipeline, broken build, compilation error, CI red, Foundry, Hardhat, forge test, hardhat test, TypeScript, Next.js, Pharos, GitHub Actions, workflow, troubleshooting."
metadata:
  audience: developer
  version: 1.2.0
  category: tooling
slash: true
---

# CI and Build Troubleshooting

Diagnose failing builds, type errors, lint jobs, and CI regressions with a narrow fix path.

## Common Pharos CI Issues

### 1. "Failed to resolve network: pharos_mainnet" in foundry.toml

Add `[rpc_endpoints]` to your `foundry.toml` so CI can resolve them:

```toml
[rpc_endpoints]
pharos_mainnet = "$PHAROS_MAINNET_RPC_URL"
pharos_testnet = "$PHAROS_TESTNET_RPC_URL"
```

CI does not have `.env` loaded by default — either set `FOUNDRY_ETH_RPC_URL` or reference inline:
```bash
forge test --fork-url $PHAROS_MAINNET_RPC_URL
```

### 2. Missing forge-std in CI

```bash
# Add to CI workflow before forge test
forge install foundry-rs/forge-std --no-commit
# Or use --locked to skip install
forge build --via-ir --locked
```

### 3. Hardhat HardhatEtherscan verification fails in CI

Ensure CI has `PHAROSSCAN_API_KEY` set. The Pharos PharosScan API key is required for both mainnet (1672) and testnet (688689).

## GitHub Actions Workflows

### Foundry CI for Pharos

```yaml
# .github/workflows/foundry.yml
name: Foundry CI (Pharos)
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: foundry-rs/foundry-toolchain@v1
      - run: forge install foundry-rs/forge-std --no-commit || true
      - run: forge build --via-ir --locked
      - run: forge test --fork-url $PHAROS_MAINNET_RPC_URL -vvv
        env:
          FOUNDRY_ETH_RPC_URL: $PHAROS_MAINNET_RPC_URL
```

### Hardhat CI for Pharos

```yaml
# .github/workflows/hardhat.yml
name: Hardhat CI (Pharos)
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npx hardhat compile
      - run: npx hardhat test
        env:
          PHAROSSCAN_API_KEY: ${{ secrets.PHAROSSCAN_API_KEY }}
```

### TypeScript + Next.js CI for Pharos dapp

```yaml
# .github/workflows/nextjs.yml
name: Next.js CI (Pharos)
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npx tsc --noEmit
      - run: npm run lint
      - run: npm run build
        env:
          NEXT_PUBLIC_PHAROS_RPC: $PHAROS_MAINNET_RPC_URL
          NEXT_PUBLIC_PHAROS_CHAIN_ID: "1672"
```

## When to Use

CI, build failure, lint failure, type error, pipeline, broken test job, build is failing, CI is red, compilation error

## When NOT to Use

runtime bugs (use bug-finding-and-debugging), or performance improvements (use performance-optimization)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST verify `.env` exists and variables are set using `grep -q` (NEVER `cat`, `head`, `tail` — those expose secrets) before any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- **Git repository**: `git status` must succeed (run from repo root).
- **CI platform**: GitHub Actions configured (check `.github/workflows/` exists).
- **Foundry** (if workflows include forge commands): `forge build` must succeed.
## Workflow
- **Strict .env Check**: Confirm `.env` exists with `test -f .env` and check variables via `grep -q` (without printing values). NEVER print `.env` contents. Do NOT proceed if missing or if the user suggests `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Read the failure output and isolate the failing stage.
4. Check prerequisites: verify required tools are installed, env vars are set, and any required context is available. Ask the user for any missing values before proceeding.
5. Narrow the fix to the smallest change that restores the pipeline.
6. Show the plan and ask before editing files that affect build behavior.
7. Verify the pipeline or local equivalent after the fix.
## Output

- failure analysis
- fix plan
- pipeline notes
- verification command

## Examples

- "Fix this failing TypeScript build in the Pharos dapp repo"
- "Diagnose why CI is failing with 'Failed to resolve network: pharos_mainnet'"
- "Resolve the Solidity compiler version mismatch in the Pharos CI pipeline"
- "Set up Foundry CI for Pharos contracts with forge test --fork-url $PHAROS_MAINNET_RPC_URL"
- "Add Hardhat CI with PHAROSSCAN_API_KEY for contract verification on PharosScan"

## Verification

The exact failing command passes. Re-run the pipeline step or equivalent local command.

## Related

bug-finding-and-debugging (runtime bugs, not build failures)

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the `PLAN.md` with the full implementation strategy, environment-aware safeguards, and verification steps.
- Present the full failure analysis with error logs, root cause, and fix plan — show the complete diagnosis
- Wait for explicit 'Approve' or 'Proceed' from the user.

**Phase 2 — Execute (wait for approval):**
- Execute the approved plan from `PLAN.md`.
- Do NOT Change build config, CI workflows, lockfiles, or modify build scripts
- Perform a final "Ready to Broadcast?" check for any high-risk on-chain actions.
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions.
### Pharos-Specific CI Patterns

When the CI failure involves Pharos-specific configs, add these checks:

| CI Signal | Pharos-Specific Check |
|---|---|
| `foundry.toml` rpc_endpoints | Verify Atlantic Testnet (688689) and mainnet (1672) use correct RPCs from pharos-context.md |
| wagmi/viem typecheck errors | Check chain ID constants (1672/688689) match pharos-context.md; check `defineChain` blocks |
| Contract test fails on forked testnet | Confirm `PHAROS_TESTNET_V2_RPC_URL` env var is set in CI secrets, not hardcoded |
| Deploy script simulation | Check `--chain-id` flag matches target network; verify `PRIVATE_KEY` is CI-only |
| ABI/type drift between Foundry and TS | Check turbo `dependsOn` ordering: Foundry build → typechain → tsc |
| Missing `CI=true` env impact | wallet mocks or fork URLs may behave differently; add `CI` flag checks to test setup |

### Commands to Run First

```bash
# View failing PR checks
git fetch origin && gh pr checks

# View CI logs for failed run
git fetch origin && gh run view <run-id> --log-failed

# Local reproduction with frozen lockfile
pnpm install --frozen-lockfile && pnpm exec tsc --noEmit

# Check chain IDs against canonical values
cast chain-id --rpc-url $PHAROS_TESTNET_V2_RPC_URL
```
