---
name: pharos-bug-finding-and-debugging
description: "Trace failures in Pharos contract compile, runtime, test, or dapp UI behavior and propose focused fixes. Use when debugging failing builds, failing tests, runtime errors, transaction reverts, or broken UI behavior in Pharos Solidity dapps. Keywords: bug, debug, error, failing build, failing test, runtime issue, broken, not working, trace failure, root cause, Solidity, Pharos, Foundry, Hardhat, revert, gas, transaction, wagmi, viem, forge, anvil, cast."
metadata:
  audience: developer
  version: 1.1.0
  category: testing
slash: true
---

# Bug Finding and Debugging

Trace failures in compile, runtime, test, or UI behavior and propose focused fixes on Pharos mainnet (chain 1672) or testnet (688689).

## Pharos Debugging Commands

### Reproduce with Anvil Fork

```bash
# Fork Pharos mainnet locally
anvil --fork-url https://rpc.pharos.xyz --chain-id 1672 --fork-block-number 123456

# Fork Pharos testnet
anvil --fork-url https://atlantic.dplabs-internal.com --chain-id 688689
```

### Inspect a Failed Transaction

```bash
# Get raw tx
cast tx --rpc-url https://rpc.pharos.xyz 0xFailedTxHash

# Get receipt with gas usage
cast receipt --rpc-url https://rpc.pharos.xyz 0xFailedTxHash

# Debug trace (if debug namespace enabled)
cast run --rpc-url https://rpc.pharos.xyz 0xFailedTxHash --debug

# callTracer via debug_traceTransaction (returns call stack)
curl -X POST https://rpc.pharos.xyz \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"debug_traceTransaction","params":["0xFailedTxHash",{"tracer":"callTracer"}],"id":1}'
```

### Decode Revert Reason

```bash
# If you have the ABI
cast call --rpc-url https://rpc.pharos.xyz $CONTRACT "stakes(address)" $USER_ADDRESS

# Decode a raw revert hex
cast 4byte 0x08c379a0 # Error(string)
cast abi-decode --input "Error(string)" 0x08c379a0...
```

### Event Logs via PharosScan API

```bash
curl -X POST "https://api.www.pharosscan.xyz/pharos-mainnet/v1/explorer/command_api/account_tx" \
  -H "Content-Type: application/json" \
  -d '{"address": "0xContractAddress", "page": 1, "offset": 50}'
```

## Common Pharos Bug Patterns

| Bug | Symptom | Root Cause | Fix |
|-----|---------|------------|-----|
| Silent PHRS transfer failure | unstake() returns success but user gets no PHRS | `.call{value:}` forwards all gas (no 2300 stipend) → reentrancy or OOG | Cap gas: `.call{value: amount, gas: 10000}("")` |
| Wrong chain ID | forge script reverts at broadcast | Hardcoded 688689 (old Atlantic) instead of 1672 | Use `block.chainid` check in deploy script |
| RPC rate limit | `eth_getLogs` returns partial data | Exceed 100 block range limit | Paginate: query 100 blocks at a time |
| Trace filter timeout | `trace_filter` returns error | Exceed 500 block range limit | Narrow range to <500 blocks |

### Anvil Fork Reproduction — PHRS Gas Stipend Bug

```solidity
// test/DebugReproduction.t.sol
function test_UnstakeSilentFailure() public {
    vm.createSelectFork("pharos_mainnet");
    // Deploy staking contract
    // Stake PHRS
    // Attempt unstake with .call{value: amount}("") — no gas limit
    // Verify balance did NOT decrease (silent failure)
}
```

## When NOT to Use

- **Code review** — For proactive security review without a known bug, use `contract-review` or `security-audit`.
- **Performance investigation** — For slowness/gas optimization without a bug, use `performance-optimization` or `gas-optimization`.
- **Build failures** — For CI/build issues, use `ci-and-build-troubleshooting`.

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**: private keys must be stored in `.env` and accessed via `${PRIVATE_KEY}`.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=https://atlantic.dplabs-internal.com` or `PHAROS_MAINNET_RPC=https://rpc.pharos.xyz` in your environment or `.env`.
- **Private key**: Set `PRIVATE_KEY` environment variable (keep this secret, never commit).
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification (https://pharosscan.xyz).
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Foundry config**: `foundry.toml` should have `[rpc_endpoints]` section with `pharos_testnet` and `pharos_mainnet` entries.

## Workflow

1. Reproduce or reason about the failure from the error output.
2. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
3. Isolate the root cause and the smallest safe fix.
4. Show the fix plan and ask for approval before editing.
5. Patch the issue and verify the failure is gone.

## Output

- root cause
- fix plan
- patch notes
- verification result

## Examples

- "Debug this failing Pharos staking test — unstake sends 0 PHRS silently"
- "Find why the frontend transaction state never updates after PharosScan confirms"
- "Investigate why forge script reverts with 'WrongChain' — hardcoded old Atlantic ID"
- "Trace why eth_getLogs returns only 100 events for a Pharos contract"
- "Reproduce a PHRS transfer failure locally with anvil --fork-url https://rpc.pharos.xyz"

## Verification

The specific failing test/command passes. Re-run the original failing command.

## Related

contract-review (review before fixing), ci-and-build-troubleshooting (pipeline failures)

## Gate

High risk — two-phase execution required:

**Phase 1 — Plan (present freely):**
- Present the root-cause analysis with debug trace, reproduction steps, and fix options — show the complete analysis
- Do NOT wait for approval to draft — show everything in your response before asking for confirmation

**Phase 2 — Execute (wait for approval):**
- Do NOT Edit files, modify code, or apply fixes
- Wait for explicit user confirmation ("I approve", "proceed", "looks good") before taking any of the Phase 2 actions