# Pharos Skill-to-Agent Dual Cascade

```mermaid
---
title: Pharos Agent Dev Suite — Architecture Overview
---
flowchart TB
    subgraph User[" "]
        REQ[("User Request")]
    end

    subgraph L1["Layer 1: 42 Instruction Subskills"]
        direction LR
        S1[[solidity-authoring]]
        S2[[deployment-and-verification]]
        S3[[security-audit]]
        S4[[rwa-compliance]]
        S5[[production-ops]]
        S6[[gas-optimization]]
        S7[[frontend-dapp-integration]]
        S8[[cross-chain-bridge]]
    end

    subgraph L2["Layer 2: 18 Executable MCP Tools"]
        T1[pharos_network_config]
        T2[pharos_deploy_contract]
        T3[pharos_verify_contract]
        T4[pharos_run_security_check]
        T5[pharos_generate_tests]
        T6[pharos_check_balance]
        T7[pharos_contract_info]
        T8[pharos_transfer_token]
        T9[pharos_deploy_erc20]
        T10[pharos_get_logs]
        T11[pharos_diagnose]
        T12[pharos_get_account]
        T13[pharos_gas_estimate]
        T14[pharos_trace_transaction]
        T15[pharos_network_status]
        T16[pharos_read_contract]
        T17[pharos_write_contract]
        T18[pharos_fetch_abi]
    end

    subgraph Pharos["Pharos Blockchain"]
        AT[("Atlantic Testnet\n688689")]
        PM[("Pacific Mainnet\n1672")]
    end

    REQ --> L1
    L1 -->|agent reads subskills| L2
    L2 -->|agent calls tools| Pharos
    L2 -->|verify on explorer| EXP[("PharosScan")]

    style REQ fill:#4a90d9,color:#fff,stroke:#fff
    style L1 fill:#1a1a2e,color:#e0e0e0,stroke:#4a90d9
    style L2 fill:#16213e,color:#e0e0e0,stroke:#4a90d9
    style AT fill:#0f3460,color:#e0e0e0,stroke:#e94560
    style PM fill:#0f3460,color:#e0e0e0,stroke:#e94560
    style EXP fill:#1a1a2e,color:#e0e0e0,stroke:#ffd700
```

---

## Cascade Flow

```mermaid
---
title: Request-to-Result Sequence
---
sequenceDiagram
    actor U as Developer
    participant A as AI Agent
    participant S as 42 Subskills
    participant T as 18 MCP Tools
    participant B as Pharos Atlantic Testnet (688689)
    participant E as PharosScan Explorer

    U->>A: "Deploy an ERC-20 token on Pharos Atlantic testnet with security audit"

    Note over A,S: LAYER 1: Agent reads subskills
    A->>S: Read solidity-authoring/SKILL.md
    S-->>A: PharosERC20 pattern, no 2300 gas stipend, SafeERC20 recommended
    A->>S: Read deployment-and-verification/SKILL.md
    S-->>A: forge script with --broadcast, verification via Blockscout
    A->>S: Read security-audit/SKILL.md
    S-->>A: Pharos-specific audit checklist (2300 gas, chain ID, rate limits)

    Note over A,T: LAYER 2: Agent calls MCP tools
    A->>T: pharos_deploy_erc20({ name, symbol, supply })
    T->>B: forge create PharosERC20 --broadcast
    B-->>T: Contract deployed at 0x3636F1...
    T-->>A: ✅ Deployment success

    A->>T: pharos_verify_contract({ address: 0x3636F1... })
    T->>E: POST /api?module=contract&action=verify
    E-->>T: ✅ Verified
    T-->>A: Contract verified on PharosScan

    A->>T: pharos_run_security_check({ address: 0x3636F1... })
    T->>T: Slither analysis + 2300 gas check + chain ID validation
    T-->>A: ✅ 0 critical, 0 high, 2 medium

    A-->>U: ✅ Token deployed, verified, and audited
    U->>E: View on PharosScan
```

---

## Skill Taxonomy

```mermaid
---
title: 42 Subskills Grouped by Domain
---
mindmap
  root((Pharos Agent Dev Suite<br/>42 Subskills))
    Architecture
      contract-architecture
      interface-abi-design
      protocol-integration-planning
      upgrade-patterns
      cross-chain-bridge
    Development
      solidity-authoring
      code-scaffolding-and-generation
      foundry-hardhat-contract-workflow
      remix-contract-workflow
      framework-integration
    Frontend
      frontend-dapp-integration
      dapp-ui-workflow
      dapp-quality
      wagmi-viem-dapp-workflow
      wallet-and-transaction-ui
    Testing
      test-generation
      testing-strategy
      contract-testing-for-testnet-and-mainnet
    Deployment
      deployment-and-verification
      mainnet-deployment
      testnet-deployment
      deployment-for-testnet-and-mainnet
      post-deploy
      ci-and-build-troubleshooting
    Security
      security-audit
      bug-finding-and-debugging
      code-review-templates-and-checklists
      contract-review
      spn-development
    Operations
      production-ops
      migration-and-backward-compatibility
      performance-optimization
      gas-optimization
      repo-automation-and-tooling
    Management
      monorepo-workspace-management
      dependency-upgrade-management
      refactoring-and-code-health
      repo-onboarding
      workflow-orchestrator
    Content
      docs-and-example-generation
      release-notes-and-changelog
    Pharos-Native
      rwa-compliance
```

---

## Tool-to-Subskill Mapping

```mermaid
---
title: MCP Tools → Corresponding Subskills
---
flowchart LR
    subgraph Tools["18 MCP Tools"]
        T1[pharos_network_config]
        T2[pharos_deploy_contract]
        T3[pharos_verify_contract]
        T4[pharos_run_security_check]
        T5[pharos_generate_tests]
        T6[pharos_check_balance]
        T7[pharos_contract_info]
        T8[pharos_transfer_token]
        T9[pharos_deploy_erc20]
        T10[pharos_get_logs]
        T11[pharos_diagnose]
        T12[pharos_get_account]
        T13[pharos_gas_estimate]
        T14[pharos_trace_transaction]
        T15[pharos_network_status]
        T16[pharos_read_contract]
        T17[pharos_write_contract]
        T18[pharos_fetch_abi]
    end

    subgraph Skills["Subskills"]
        S1[[framework-integration]]
        S2[[deployment-and-verification]]
        S3[[security-audit]]
        S4[[test-generation]]
        S5[[frontend-dapp-integration]]
        S6[[contract-review]]
        S7[[wallet-and-transaction-ui]]
        S8[[solidity-authoring]]
        S9[[protocol-integration-planning]]
        S10[[gas-optimization]]
        S11[[bug-finding-and-debugging]]
        S12[[production-ops]]
    end

    T1 --> S1
    T2 --> S2
    T3 --> S2
    T4 --> S3
    T5 --> S4
    T6 --> S5
    T7 --> S6
    T8 --> S7
    T9 --> S8
    T10 --> S9
    T11 --> S1
    T12 --> S7
    T13 --> S10
    T14 --> S11
    T15 --> S12
    T16 --> S6
    T17 --> S7
    T18 --> S6

    style Tools fill:#16213e,color:#e0e0e0,stroke:#4a90d9
    style Skills fill:#1a1a2e,color:#e0e0e0,stroke:#4a90d9
```

---

## On-Chain Proof

```mermaid
---
title: Verified Deployments on Pharos Atlantic Testnet (688689)
---
flowchart TB
    subgraph Deployments["3 Contracts Deployed & Verified"]
        C1[Counter<br/>0x55ec4b1e...]
        C2[Storage<br/>0x2527FDc8...]
        C3[PharosERC20<br/>0x3636F1...]
    end

    subgraph Verification["Verified on PharosScan"]
        V1[("Source code verified")]
        V2[("Constructor args visible")]
        V3[("Events indexed")]
    end

    subgraph Tools["Used MCP Tools"]
        P1[pharos_deploy_contract]
        P2[pharos_verify_contract]
        P3[pharos_deploy_erc20]
    end

    P1 --> C1
    P2 --> C1
    P1 --> C2
    P2 --> C2
    P3 --> C3
    P2 --> C3

    C1 --> V1
    C2 --> V1
    C3 --> V1

    linkStyle default stroke:#4a90d9,stroke-width:2px
```

---

## Quick Reference

| Layer | Count | What It Does |
|---|---|---|
| **Layer 1** | 42 subskills | Teaches AI agents Pharos-specific patterns, conventions, and best practices |
| **Layer 2** | 18 MCP tools | Executes real on-chain operations on Pharos Atlantic & Pacific networks |
| **Cascade** | User → Subskills → Tools → Blockchain | Agent reads (learns) then calls (executes) — the dual-layer cascade |
