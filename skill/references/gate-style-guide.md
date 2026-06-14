# Gate Style Guide

Reference for writing and maintaining Gate sections in Pharos subskills.
All subskills should follow this guide for consistent, unambiguous risk gating.

## Quick Reference

| Risk | Template | Phase 1 (Plan) | Phase 2 (Execute) | Approval required |
|---|---|---|---|---|
| **High** | Two-phase | Present code/plans freely — do NOT wait for approval to draft | Blocked until explicit approval | Yes — "I approve" / "proceed" |
| **Medium** | Two-phase (light) | Present plan with file paths — do NOT wait for approval to draft | Blocked until user agrees | Yes — "looks good" / "proceed" |
| **Low** | Plan-first | Present plan, then ask user to agree | Proceed once user agrees | No — user agreement suffices |

---

## 1. Anatomy of a Gate Section

Every Gate section should answer three questions for the agent:

1. **What should I do right now?** → Phase 1: present plans, draft code, show everything
2. **What must I NOT do yet?** → Phase 2: wait for approval before executing
3. **How do I know when to proceed?** → Approval signal: specific user phrases

```
## Gate

[Risk level] — [execution model summary]:

**[Phase label] — [instruction type]:**  ← tells the agent WHAT TO DO
- [Actionable directive with domain specifics]
- [Concrete deliverables to present]
- [Key behavior instruction: "Do NOT wait for approval..."]

**[Phase label] — [instruction type]:**  ← tells the agent WHAT NOT TO DO YET
- [Blocked actions, domain-specific]
- [Approval requirement and signal phrases]
- [Safety guardrails]
```

---

## 2. High-Risk Gate Template (Two-Phase)

Use for subskills where incorrect execution can cause financial loss, security vulnerabilities, or irreversible state changes.

Contract work, upgrades, deployments, security audits, RWA compliance, cross-chain integration.

### Template

```markdown
## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- [Draft the full plan with domain-specific artifacts: code, storage layouts, scripts, test matrices, etc.]
- [List concrete deliverables to show the user]
- Do NOT wait for approval to draft — show everything in your response before asking for confirmation

**Phase 2 — Execute (wait for approval):**
- Do NOT [blocked-action-1], [blocked-action-2], or [blocked-action-3]
- Do NOT send any onchain transactions or modify files
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any Phase 2 actions
```

### Example (contract architecture)

```markdown
## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the module map, storage layout, access-control plan, and upgrade path — show the full architecture diagram and storage schemas
- Do NOT wait for approval to draft — show everything in your response before asking for confirmation

**Phase 2 — Execute (wait for approval):**
- Do NOT write contract code, modify files, or generate implementation
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before writing any code
```

### Example (upgrade patterns)

```markdown
## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the upgrade plan with storage layout diff, V2 contract code, access control design, and multi-sig config
- Show the exact forge script commands (with placeholder addresses), expected implementation address pattern, and upgradeTo calldata structure
- Present the complete upgrade transaction data for user review
- Do NOT wait for approval to draft code — show everything in your response

**Phase 2 — Execute (wait for approval):**
- Do NOT deploy new implementations, change storage layout, call upgradeTo, or modify _authorizeUpgrade
- Do NOT send any onchain transactions (deploy, verify, proxy upgrade, Safe submission)
- Wait for explicit user confirmation ("I approve", "proceed", "execute") before running any deployment or upgrade commands
```

---

## 3. Medium-Risk Gate Template (Two-Phase Light)

Use for subskills where incorrect execution could cause bugs, regressions, or wasted time, but not direct financial loss.

Testing strategy, refactoring, performance optimization, state management, accessibility, gas optimization, interface design.

### Template

```markdown
## Gate

Medium risk — plan-first with approval:

**Phase 1 — Plan (present freely):**
- [Present plan with file paths, scope, and specific changes]
- Do NOT wait for approval to draft — show the complete plan in your response

**Phase 2 — Execute (wait for approval):**
- Do NOT [modify files / change behavior / apply changes] until the user agrees to the plan
- Wait for user confirmation ("looks good", "proceed", "yes") before implementing
```

### Example (refactoring)

```markdown
## Gate

Medium risk — plan-first with approval:

**Phase 1 — Plan (present freely):**
- Present refactor plan with file paths, extracted interfaces, and behavior-preserving guarantees
- Do NOT wait for approval to draft — show the complete refactor plan in your response

**Phase 2 — Execute (wait for approval):**
- Do NOT modify files until the user agrees to the refactor scope
- Wait for user confirmation ("looks good", "proceed") before writing any refactored code
```

---

## 4. Low-Risk Gate Template (Plan-First)

Use for subskills where mistakes are easily reversible, or the primary deliverable is information rather than code changes.

Repo onboarding, release notes, scaffolding, docs generation, localization, workflow orchestration, framework setup.

### Template

```markdown
## Gate

Low risk — present plan before proceeding:

- [Present the plan/outline with concrete deliverables and paths]
- Proceed once the user agrees to the approach

[Optional] Anti-generic rules:
- [Specificity rule 1: name exact paths, chain IDs, commands]
- [Specificity rule 2: prohibited generic patterns]
```

### Example (release notes)

```markdown
## Gate

Low risk — present plan before proceeding:

- Show the changelog outline and commit sample first
- Edit CHANGELOG.md only after the user confirms the structure
```

### Example (code scaffolding)

```markdown
## Gate

Low risk — present plan before proceeding:

- Show the file tree and .env.example keys before writing any scaffold files
- Proceed once the user confirms the scaffold type and target path
```

---

## 5. Anti-Generic Rules

Anti-generic rules prevent agents from producing vague, placeholder-filled, or non-specific output. They are most important for medium and low-risk subskills where the gate is lighter and the agent has more latitude.

### Rule Categories

| Category | Purpose | Example |
|---|---|---|
| **Path specificity** | Force exact file paths | "Component steps MUST name the specific component path (e.g., `src/components/TxHistory.tsx`)" |
| **Chain/network specificity** | Force exact chain IDs, RPC URLs | "Hook examples MUST name the chain ID (688689 or 1672)" |
| **Command specificity** | Force exact commands with paths | "Verification MUST name an exact command (e.g., `pnpm vitest run test/hooks/useStake.test.ts`)" |
| **Token/asset specificity** | Force correct native token names | "Native token labels MUST use PROS (mainnet) or PHRS (testnet), never ETH or generic 'native'" |
| **Security specificity** | Block dangerous patterns | "Do NOT hardcode private keys — use `$PRIVATE_KEY` env var with explicit warning" |
| **Error handling specificity** | Force named components | "Do NOT suggest generic error handling — name the specific error component path" |
| **Config specificity** | Force naming config sections | "`foundry.toml` changes MUST name the specific section and fields added" |

### Canonical Examples

```markdown
Anti-generic rules:
- Hook examples MUST name the contract ABI path and chain ID (688689 or 1672)
- Do NOT use `useReadContract` without pinning `chainId` in the hook
- Do NOT suggest generic error handling — name the specific component path (e.g., `components/TxErrorBanner.tsx`)
```

```markdown
Anti-generic rules:
- shadcn/ui `add` commands MUST include the component name (e.g., `npx shadcn@latest add dialog`)
- Verification MUST include both `pnpm exec tsc --noEmit` AND manual chain ID checks (688689/1672)
- Do NOT suggest generic Tailwind classes — name the specific utility or component pattern
```

```markdown
Anti-generic rules:
- Deploy script steps MUST name the script path (e.g., `script/Deploy.s.sol:Deploy`)
- `forge` commands MUST include the specific test or script name
- Before broadcast, MUST confirm `cast chain-id --rpc-url <name>` matches the target
- Do NOT hardcode private keys — use `$PRIVATE_KEY` env var with explicit warning
```

### Anti-Generic Rule Writing Checklist

When adding anti-generic rules to a Gate section:

- [ ] Does each rule start with "MUST", "Do NOT", or "Prohibited"? (enforceable language)
- [ ] Does each rule include a concrete example? (e.g., full file path, chain ID, command)
- [ ] Are the rules specific to the subskill's domain? (not copy-pasted generic rules)
- [ ] Are "Do NOT" rules accompanied by what TO do instead? (e.g., "Do NOT hardcode private keys — use `$PRIVATE_KEY`")
- [ ] Are verification commands fully specified? (not "run tests" but "run `pnpm vitest run test/hooks/useStake.test.ts`")

---

## 6. Gate Section Checklist

Use this checklist when writing or reviewing any Gate section:

### Structure

- [ ] Risk level is declared first (High / Medium / Low)
- [ ] Phase 1 tells the agent what TO do (present, draft, show)
- [ ] Phase 2 tells the agent what NOT to do until approved
- [ ] Phase 1 explicitly says "Do NOT wait for approval to draft — show everything" (for high/medium)
- [ ] Approval signal phrases are specified ("I approve", "proceed", "looks good")
- [ ] Domain-specific blocked actions are listed (not just generic "do not execute")
- [ ] Anti-generic rules are present for medium/low-risk subskills (optional for high-risk)

### Ambiguity Check

- [ ] Would a literal-minded agent default to just summarizing the documentation instead of producing code? If yes, the Gate needs a stronger Phase 1 directive.
- [ ] Is there any action that could be interpreted as Phase 1 OR Phase 2? If ambiguous, add a phase label.
- [ ] Does the Gate tell the agent what TO do, not just what NOT to do?

### Risk-Level Appropriateness

- [ ] High risk: Two-phase format with explicit "Do NOT wait for approval to draft" in Phase 1
- [ ] Medium risk: Two-phase (light) format, or plan-first with explicit approval gate
- [ ] Low risk: Plan-first with user agreement — no strict approval required

---

## 7. Before and After Examples

### Before (ambiguous — purely negative)

```markdown
## Gate

High risk. Do not implement proxy upgrades, change storage layout, or modify _authorizeUpgrade before the user approves the upgrade plan and storage compatibility check.
```

**Problem:** Only tells the agent what NOT to do. The agent defaults to summarizing the documentation instead of presenting the upgrade plan with code.

### After (clear two-phase)

```markdown
## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Draft the upgrade plan with storage layout diff, V2 contract code, access control design, and multi-sig config
- Present the complete upgrade transaction data for user review
- Do NOT wait for approval to draft code — show everything in your response

**Phase 2 — Execute (wait for approval):**
- Do NOT deploy new implementations, change storage layout, call upgradeTo, or modify _authorizeUpgrade
- Wait for explicit user confirmation ("I approve", "proceed") before running any deployment or upgrade commands
```

### Before (vague plan-first)

```markdown
## Gate

Low risk. Present the plan before proceeding.
```

**Problem:** Too vague — doesn't specify *what kind* of plan to present, or include anti-generic rules.

### After (specific plan-first with anti-generic rules)

```markdown
## Gate

Low risk — present plan before proceeding:

- Show the file tree, scaffold structure, and .env.example keys before writing any files
- Proceed once the user confirms the scaffold type and target path

Anti-generic rules:
- File paths MUST be project-relative (e.g., `contracts/MyToken.sol`, not `src/contracts/`)
- Scaffold commands MUST use exact package names with versions
- Do NOT generate placeholder `.env` files with empty or example secrets
```

---

## 8. Quick Decision Matrix

When writing a Gate section for a new subskill:

```
┌────────────────────────────────────────────────────────────┐
│  What's the worst outcome of a mistake?                    │
│                                                            │
│  Financial loss / security vuln / irreversible state?      │
│  └── HIGH RISK → Two-phase template                        │
│                                                            │
│  Bug / regression / wasted time / broken build?            │
│  └── MEDIUM RISK → Two-phase (light) template              │
│                                                            │
│  Cosmetic / informational / easily reversible?             │
│  └── LOW RISK → Plan-first template + anti-generic rules   │
└────────────────────────────────────────────────────────────┘
```

---

## 9. Common Anti-Patterns

| Anti-pattern | Why it's bad | Fix |
|---|---|---|
| Purely negative gate ("Do not X before Y") | Agent doesn't know what TO do — defaults to summarizing | Add Phase 1 with "present/draft/show" directives |
| No approval signal phrases | Agent waits forever or proceeds without confirmation | Add explicit phrases: "I approve", "proceed", "looks good" |
| Generic plan-first ("Present the plan") | Agent doesn't know what kind of plan | Be specific: "Show the file tree, deploy script, and .env.example" |
| Missing anti-generic rules | Agent produces generic output with placeholders | Add 3-5 specificity rules for paths, chain IDs, commands |
| Copy-pasted Phase 2 from another subskill | Blocked actions don't match the domain | List domain-specific blocked actions (deploy, write files, change state, etc.) |
| "Wait for approval to draft" (Phase 1) | Agent won't produce any code until approved — defeats the plan-first model | Use "Do NOT wait for approval to draft — show everything in your response" |
| No risk level prefix | Agent doesn't know how strict the gate is | Start with "High risk —", "Medium risk —", or "Low risk —" |

---

## 10. Binding Reference

This guide is **binding**. All subskill Gate sections must follow:

1. The risk-appropriate template from sections 2-4
2. Anti-generic rules from section 5 for medium/low risk
3. The structure checklist from section 6

If a Gate section contradicts this guide, the agent should follow this guide.
