---
name: pharos-security-audit
description: "Audit Pharos smart contracts for common vulnerability classes: Oracle manipulation, access control drift, cross-chain message replay, flash loan composability, MEV exposure. Reference Pharos audit partners: ExVul, OpenZeppelin, Zellic. Critical bug density benchmark: 0.4-0.7 per 1k LOC Solidity. Use when the user says: security audit, security review, vulnerability assessment, penetration test, audit preparation, audit readiness, smart contract audit, secure coding, threat model, attack surface, oracle manipulation, access control, replay attack, flash loan, MEV, ExVul, OpenZeppelin, Zellic. Do NOT use for: general code review without security focus (use contract-review), bug finding with a specific failure (use bug-finding-and-debugging), or automated analysis setup (use ci-and-build-troubleshooting for CI security tools). See also: contract-review (code correctness), bug-finding-and-debugging (specific failures), upgrade-patterns (proxy security)."
---

# Security Audit

Audit Pharos smart contracts for common vulnerability classes: Oracle manipulation, access control drift, cross-chain message replay, flash loan composability, MEV exposure.

## When to Use

security audit, security review, vulnerability assessment, penetration test, audit preparation, audit readiness, smart contract audit, secure coding, threat model, attack surface, oracle manipulation, access control, replay attack, flash loan, MEV, ExVul, OpenZeppelin, Zellic

## When NOT to Use

general code review without security focus (use contract-review), bug finding with a specific failure (use bug-finding-and-debugging), or automated analysis setup (use ci-and-build-troubleshooting for CI security tools)

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

- "Audit this AMM contract for Pharos deployment"
- "Review cross-chain bridge contract for replay vulnerabilities"
- "Prepare for an ExVul or OpenZeppelin audit"
- "Threat model the oracle integration for my lending protocol"
- "Check for MEV exposure in the DEX router"

## Verification

Run automated analyzers (Slither, Mythril, Foundry fuzz tests). Manual verification of each finding. Re-test after remediation.

## Related

contract-review (code correctness), bug-finding-and-debugging (specific failures), upgrade-patterns (proxy security)
