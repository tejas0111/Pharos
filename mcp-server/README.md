# Pharos MCP Server

[![tests](https://img.shields.io/badge/tests-21%20passing-brightgreen)]()
[![tools](https://img.shields.io/badge/MCP%20tools-18-purple)]()
[![license](https://img.shields.io/badge/license-MIT-green)]()

MCP server for AI agents to interact with the Pharos blockchain. Exposes **18 executable tools** for deployment, verification, transfers, security checks, gas estimation, transaction tracing, contract reads/writes, and more.

## Tools

| # | Tool | Description | Executes? |
|---|------|-------------|-----------|
| 1 | `pharos_network_config` | Get network configuration (RPC, chain ID, explorer) | Static |
| 2 | `pharos_deploy_contract` | Deploy a compiled contract via `forge script` | ✅ Yes |
| 3 | `pharos_verify_contract` | Verify contract on PharosScan via explorer API | ✅ Yes |
| 4 | `pharos_run_security_check` | Run `slither` + structured security review | ✅ Yes |
| 5 | `pharos_generate_tests` | Write Foundry test file to disk | ✅ Yes |
| 6 | `pharos_check_balance` | Check PHRS/PROS balance via RPC | ✅ Yes |
| 7 | `pharos_contract_info` | Fetch contract metadata from explorer API | ✅ Yes |
| 8 | `pharos_transfer_token` | Send PHRS/PROS using viem walletClient | ✅ Yes |
| 9 | `pharos_deploy_erc20` | Deploy ERC-20 token via `forge create` | ✅ Yes |
| 10 | `pharos_get_logs` | Fetch event logs with block range | ✅ Yes |
| 11 | `pharos_diagnose` | Check environment: deps, RPC, env vars | ✅ Yes |
| 12 | `pharos_get_account` | Get account state via Pharos-specific `eth_getAccount` RPC | ✅ Yes |
| 13 | `pharos_gas_estimate` | Estimate gas prices with EIP-1559 breakdown | ✅ Yes |
| 14 | `pharos_trace_transaction` | Trace a tx with `debug_traceTransaction` (Pharos enables this) | ✅ Yes |
| 15 | `pharos_network_status` | Check safe/finalized block numbers and gas prices | ✅ Yes |
| 16 | `pharos_read_contract` | Call any view/pure function on a deployed contract via its ABI | ✅ Yes |
| 17 | `pharos_write_contract` | Call any state-changing function via ABI (simulate then broadcast) | ✅ Yes |
| 18 | `pharos_fetch_abi` | Download verified ABI JSON from PharosScan explorer | ✅ Yes |

## Security

- **Private keys are NEVER exposed in tool output**
- `PRIVATE_KEY` is read from environment variable only
- Transfers require explicit `toAddress` and `amount` parameters
- All deploy tools default to simulation (no broadcast) unless `simulate=false`

## Usage

### Prerequisites

```bash
export PRIVATE_KEY=0x...
export PHAROS_TESTNET_RPC_URL=https://atlantic.dplabs-internal.com
```

### With Claude Desktop

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "pharos": {
      "command": "node",
      "args": ["/path/to/mcp-server/index.js"],
      "env": {
        "PRIVATE_KEY": "0x...",
        "PHAROS_TESTNET_RPC_URL": "https://atlantic.dplabs-internal.com",
        "PHAROS_MAINNET_RPC_URL": "https://rpc.pharos.xyz"
      }
    }
  }
}
```

### Standalone

```bash
cd mcp-server
npm install
node index.js
```

## Dependencies

- `@modelcontextprotocol/sdk` — MCP protocol implementation
- `viem` — Ethereum interaction library (RPC calls, wallet operations)

## Deployed Contracts on Atlantic Testnet

| Contract | Address |
|----------|---------|
| Counter | `0x55ec4b1e32537b6f72aa20153735709837488e4e` |
| Storage | `0x2527FDc8C6FdF7C5239f005D94Cc7dC6173d34f0` |
| PharosERC20 | `0x3636F1BBcc56D1b5a22F8B778494D1553d95B4CD` |
