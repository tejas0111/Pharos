---
name: pharos-security-audit
description: "Audit Pharos smart contracts for common vulnerability classes: Oracle manipulation, access control drift, cross-chain message replay, flash loan composability, MEV exposure. Reference Pharos audit partners: ExVul, OpenZeppelin, Zellic. Critical bug density benchmark: 0.4-0.7 per 1k LOC Solidity. Use when. Keywords: security audit, security review, vulnerability assessment, penetration test, audit preparation, audit readiness, smart contract audit, secure coding, threat model, attack surface, oracle manipulation, access control, replay attack, flash loan, MEV, ExVul, OpenZeppelin, Zellic. Do NOT use for: general code review without security focus (use contract-review), bug finding with a specific failure (use bug-finding-and-debugging), or automated analysis setup (use ci-and-build-troubleshooting for CI security tools)."
metadata:
  audience: developer
  version: 1.0.0
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

## Workflow

1. Map the threat model: trust boundaries, asset flows, privileged roles, external dependencies.
2. Check Pharos-specific attack surfaces: cross-chain message replay (nonce verification, chain ID binding), oracle manipulation (use redundant oracles: Supra DORA + Chainlink), access control drift (role admin changes, proxy admin safety).
3. Analyze code for standard vulnerability classes: reentrancy, integer overflow, front-running, flash loan composability, price manipulation.
4. Verify against Pharos audit partner standards (ExVul, OpenZeppelin, Zellic). Target critical bug density below 0.4 per 1k LOC Solidity.
5. Generate findings report with severity (critical, high, medium, low, informational), evidence, and remediation.

## Output

- threat model diagram
- findings report with severity ratings
- code-level remediation recommendations
- automated analysis results (Slither, Mythril, Foundry fuzz)
- audit readiness checklist

## Examples

- **Query:** "Audit this AMM contract for Pharos deployment" → **Action:** Map threat model (trust boundaries, asset flows, privileged roles), run Slither/Mythril/Foundry fuzz, check Pharos-specific surfaces (oracle manipulation via Supra DORA + Chainlink, access control drift), generate findings report with severity ratings.
- **Query:** "Review cross-chain bridge contract for replay vulnerabilities" → **Action:** Verify nonce tracking, chain ID binding in `_msgSender()` derivation, trusted remote configuration, replay protection in message relay functions, evidence with proof-of-concept test.
- **Query:** "Prepare for an ExVul or OpenZeppelin audit" → **Action:** Run automated analyzers, compile audit readiness checklist (documented threat model, test coverage >90%, NatSpec, known issues disclosure), remediate high-severity findings before handoff.
- **Query:** "Threat model the oracle integration for my lending protocol" → **Action:** Identify oracle dependency points (price feeds, liquidation triggers), evaluate redundancy (Supra DORA + Chainlink), model staleness attacks and flash loan price manipulation scenarios.
- **Query:** "Check for MEV exposure in the DEX router" → **Action:** Analyze transaction ordering dependence, front-running vectors in swap/liquidity functions, sandwich attack surface, recommend commit-reveal or minimum output amount protections.

## Verification

Run automated analyzers (Slither, Mythril, Foundry fuzz tests). Manual verification of each finding. Re-test after remediation.

## Related

contract-review (code correctness), bug-finding-and-debugging (specific failures), upgrade-patterns (proxy security)
