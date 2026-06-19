---
name: pharos-security-audit
description: "Audit Pharos smart contracts for common vulnerability classes: Oracle manipulation, access control drift, cross-chain message replay, flash loan composability, MEV exposure, bridge reentrancy, PHRS flash loan attacks, and chain ID validation (1672/688689). Reference Pharos audit partners: ExVul, OpenZeppelin, Zellic. Critical bug density benchmark: 0.4-0.7 per 1k LOC Solidity. Use when performing security audit or vulnerability assessment of Pharos contracts. Keywords: security audit, security review, vulnerability assessment, penetration test, audit preparation, audit readiness, smart contract audit, secure coding, threat model, attack surface, oracle manipulation, access control, replay attack, flash loan, MEV, ExVul, OpenZeppelin, Zellic, bridge audit, PHRS security."
metadata:
  audience: developer
  version: 1.2.0
  category: security
slash: true
---

# Security Audit

Audit Pharos smart contracts for common vulnerability classes: Oracle manipulation, access control drift, cross-chain message replay, flash loan composability, MEV exposure.

## When to Use

security audit, security review, vulnerability assessment, penetration test, audit preparation, audit readiness, smart contract audit, secure coding, threat model, attack surface, oracle manipulation, access control, replay attack, flash loan, MEV, ExVul, OpenZeppelin, Zellic

## When NOT to Use

- **Code review without security focus** — If the user wants correctness checks, style nits, or logic verification without threat modeling, use `contract-review`.
- **Bug finding with a specific failure** — If the user reports a concrete bug (e.g., "this function reverts when X"), use `bug-finding-and-debugging`.
- **Automated analysis setup** — If the user needs CI integration for Slither/Mythril, use `ci-and-build-troubleshooting`.
- **Greenfield contract design** — If the user is still designing the contract (no code written yet), route to `contract-architecture` for design review before security audit.
- **MEV strategy design** — If the user wants to build an MEV bot or arbitrage strategy (not audit for MEV exposure), use `contract-architecture` or a dedicated MEV subskill.

## Prerequisites
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST verify `.env` exists and variables are set using `grep -q` (NEVER `cat`, `head`, `tail` — those expose secrets) before any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=$PHAROS_TESTNET_RPC_URL` or `PHAROS_MAINNET_RPC=$PHAROS_MAINNET_RPC_URL` in your environment or `.env`.
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification (https://www.pharosscan.xyz).
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Foundry config**: `foundry.toml` should have `[rpc_endpoints]` section with `pharos_testnet` and `pharos_mainnet` entries.
## Pharos-Specific Audit Reference

| Parameter | Value |
|-----------|-------|
| Native currency | PHRS (18 decimals, `msg.value` = PHRS) |
| EVM compatibility | Shanghai-equivalent (Solc ≤0.8.24, OZ contracts 4.x+ work) |
| Block time | ~2 seconds |
| Base fee range | 1-10 gwei typical |
| Flash loan protocols | Pharos native: no protocol-level flash loans (use Uniswap V3-style pair flash loans if deployed) |
| Oracle feeds | Supra DORA (`0xSupra...`), Chainlink (`0xChainlink...`) — verify current addresses on PharosScan |
| Bridge contracts | Native Pharos bridge — verify latest address from docs.pharos.xyz or PharosScan |
| Block explorer | PharosScan — `https://atlantic.pharosscan.xyz` (both mainnet and testnet) |
| Verifier API | `$PHAROSSCAN_MAINNET_API_URL` — usage: `forge verify-contract <ADDRESS> <CONTRACT> --chain-id 1672 --verifier-url $PHAROSSCAN_MAINNET_API_URL --etherscan-api-key <KEY>` |

## Workflow
- **Strict .env Check**: Confirm `.env` exists with `test -f .env` and check variables via `grep -q` (without printing values). NEVER print `.env` contents. Do NOT proceed if missing or if the user suggests `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Map the threat model: trust boundaries, asset flows (PHRS deposits/withdrawals), privileged roles, external dependencies (Pharos bridge endpoints, oracles).
4. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
5. Check Pharos-specific attack surfaces: cross-chain bridge reentrancy (reentrancy in message relay functions), PHRS flash loan attacks (price manipulation via PHRS flash loans), chain ID validation (verify chain ID 1672 for mainnet, 688689 for Atlantic testnet), oracle manipulation (use redundant oracles: Supra DORA + Chainlink), access control drift (role admin changes, proxy admin safety).
6. Analyze code for standard vulnerability classes: reentrancy (especially in PHRS withdrawal functions — "unprotected" means no reentrancy guard, no CEI pattern, or no pull-over-push in withdraw/claim), integer overflow (reward calculations), front-running (unstake/claim operations), flash loan composability, price manipulation — plus Pharos-specific findings: incorrect chain ID checks (must validate 1672/688689/688689 in bridge functions), bridge message validation issues, PHRS `.call{value:}` has no 2300 gas stipend (full gas forwarded — protect with gas limits or reentrancy guards).
7. Verify against Pharos audit partner standards (ExVul, OpenZeppelin, Zellic). Configure PharosScan source verification: `https://api.atlantic.pharosscan.xyz/pharos-testnet/v1/explorer/command_api/contract`. Target critical bug density below 0.4 per 1k LOC Solidity.
8. Present the threat model and findings with severity ratings, then ask for confirmation before finalizing the audit report.
9. Use Pharos-specific tooling: run Slither with Pharos RPC (`slither . --rpc-url $PHAROS_MAINNET_RPC_URL`), Echidna fuzzing with Pharos fork (`echidna-test . --fork-url $PHAROS_MAINNET_RPC_URL`), Foundry fuzz tests. Generate findings report with severity (critical, high, medium, low, informational), evidence, and remediation.
## Output

- threat model diagram
- findings report with severity ratings
- code-level remediation recommendations
- automated analysis results (Slither, Mythril, Foundry fuzz)
- audit readiness checklist

## Examples

- **Query:** "Audit this AMM contract for Pharos deployment" → **Action:** Map threat model (trust boundaries, PHRS asset flows, privileged roles), run Slither with Pharos RPC (`slither . --rpc-url $PHAROS_MAINNET_RPC_URL`), Echidna fuzzing with Pharos fork, check Pharos-specific surfaces (oracle manipulation via Supra DORA + Chainlink, access control drift, chain ID validation), generate findings report with severity ratings.
- **Query:** "Review cross-chain bridge contract for replay vulnerabilities" → **Action:** Verify nonce tracking, chain ID binding in `_msgSender()` derivation (validate chain ID 1672/688689), trusted remote configuration, replay protection in message relay functions, check for unprotected PHRS withdrawals in bridge exit functions, provide evidence with proof-of-concept test.
- **Query:** "Prepare for an ExVul or OpenZeppelin audit" → **Action:** Run automated analyzers, compile audit readiness checklist (documented threat model, test coverage >90%, NatSpec, known issues disclosure), remediate high-severity findings before handoff.
- **Query:** "Threat model the oracle integration for my lending protocol" → **Action:** Identify oracle dependency points (price feeds, liquidation triggers), evaluate redundancy (Supra DORA + Chainlink), model staleness attacks and flash loan price manipulation scenarios.
- **Query:** "Check for MEV exposure in the DEX router" → **Action:** Analyze transaction ordering dependence, front-running vectors in swap/liquidity functions, sandwich attack surface, recommend commit-reveal or minimum output amount protections.

## Verification

Run automated analyzers targeting Pharos: Slither with Pharos RPC (`slither . --rpc-url $PHAROS_MAINNET_RPC_URL`), Mythril, Echidna fuzzing with Pharos fork (`echidna-test . --fork-url $PHAROS_MAINNET_RPC_URL`), Foundry fuzz tests. Manual verification of each finding. Re-test after remediation with Pharos RPC.

## Related

contract-review (code correctness), bug-finding-and-debugging (specific failures), upgrade-patterns (proxy security)


## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the `PLAN.md` with the full implementation strategy, environment-aware safeguards, and verification steps.
- Present the complete findings report with severity breakdown, automated tool output (Slither/Mythril), and threat model — show everything
- Wait for explicit 'Approve' or 'Proceed' from the user.

**Phase 2 — Execute (wait for approval):**
- Execute the approved plan from `PLAN.md`.
- Do NOT Patch vulnerabilities, modify contract code, or recommend fixes without user approval of the remediation plan
- Perform a final "Ready to Broadcast?" check for any high-risk on-chain actions.
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions.
## Pharos Contract Audit Checklist

### SPN Paymaster (`contracts/PharosSPNPaymaster.sol`)
```
[ ] onlyEntryPoint modifier prevents spoofing
[ ] Budget checks happen in validatePaymasterUserOp (not just postOp)
[ ] s_sponsorSpent updated correctly
[ ] No reentrancy in postOp (called by EntryPoint, not user)
[ ] Pause stops new validations but doesn't block in-flight ops
```

### Lending Pool (`contracts/PharosLendingPool.sol`)
```
[ ] Interest rate model doesn't overflow (kinked rates use SafeMath in 0.8+)
[ ] Liquidation bonus doesn't require contract to hold extra tokens
[ ] Collateral ratio checks prevent under-collateralized borrows
[ ] Reserve factor correctly routed to protocol treasury
```

### DEX Pool (`contracts/DEXPool.sol`)
```
[ ] Constant product invariant holds (x*y >= k after swap)
[ ] Slippage protection via _minAmountOut
[ ] LP token mint/burn math correct (geometric mean)
[ ] No front-running vulnerability in addLiquidity
```

### Automated Tools
- **Slither**: `slither contracts/PharosSPNPaymaster.sol --json -`
- **Forge inspect**: `forge inspect PharosSPNPaymaster methods`
- **Gas report**: `forge test --gas-report`

## Vulnerability Classes

| Class | Pharos-Specific Risk | Example Contract |
|-------|---------------------|-----------------|
| Reentrancy | No 2300 gas stipend on `.call{value:}` | Any contract using `send`/`transfer` |
| Cross-chain replay | Chain ID 1672/688689 difference | `CrossChainMessage.sol` |
| Flash loan composability | SPN paymaster budget drain | `PharosSPNPaymaster.sol` |
| Oracle manipulation | No native oracle on Pharos | `PharosLendingPool.sol` (if using oracle) |
| Access control drift | Ownership change via upgrades | `PharosTimelockController.sol` |

## References

- `contracts/PharosSPNPaymaster.sol` — Paymaster security patterns
- `contracts/DEXPool.sol` — AMM security patterns
- `contracts/PharosLendingPool.sol` — Lending security patterns
- Slither docs: https://github.com/crytic/slither
