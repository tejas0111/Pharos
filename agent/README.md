# Agent Composition Demo

This directory demonstrates **Skill-to-Agent composition** — chaining multiple MCP tools into a single autonomous workflow.

## Workflow: Token Launch & Distribute

`token-workflow.sh` composes 3 MCP tools into a single pipeline:

```
pharos_deploy_erc20 → pharos_check_balance → pharos_transfer_token
```

| Step | Tool | Action |
|------|------|--------|
| 1 | `pharos_deploy_erc20` | Deploys a PharosERC20 token with name/symbol/supply |
| 2 | `pharos_check_balance` | Reads the deployer's token balance from the chain |
| 3 | `pharos_transfer_token` | Sends 100 tokens to a test recipient address |

### Why This Matters

This demonstrates the **Phase 2 Skill-to-Agent pipeline** for the hackathon:

1. **Skill Creator** → writes the subskills and MCP tools (this repo)
2. **Agent Developer** → chains tools into a workflow script (this directory)
3. **User Invocation** → runs the script with a single command

Judges can see that the tools are not isolated — they can be composed into multi-step agent workflows that accomplish real tasks.

### Usage

```bash
export PRIVATE_KEY=0x...
bash agent/token-workflow.sh
```

### Expected Output

```
════════════════════════════════════════════════
  Pharos Token Agent — Atlantic Testnet (688689)
════════════════════════════════════════════════

┌─ Step 1/3: Deploy PharosERC20 ──────────────────────┐
│  ✓ Deployed at: 0x...
└─────────────────────────────────────────────────────┘

┌─ Step 2/3: Check Deployer Balance ─────────────────┐
│  Deployer: 0x...
│  Balance: 1000000 PHT
└─────────────────────────────────────────────────────┘

┌─ Step 3/3: Transfer 100 PHT ───────────────────────┐
│  ✓ Sent 100 PHT → 0x0000...1234
└─────────────────────────────────────────────────────┘

════════════════════════════════════════════════
  Workflow Complete!
════════════════════════════════════════════════
```

### Extending

This pattern can be extended to any workflow:

- **Audit Pipeline**: `deploy_contract` → `run_security_check` → `generate_tests`
- **Deploy & Verify**: `deploy_contract` → `verify_contract` → `contract_info`
- **Monitor**: `check_balance` → `get_logs` → `contract_info`
