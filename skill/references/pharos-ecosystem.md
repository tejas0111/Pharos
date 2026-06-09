# Pharos Ecosystem Reference

Comprehensive reference for the Pharos blockchain ecosystem: networks, RPC providers, explorers, contract addresses, common RPC methods, tokenomics, and governance.

## Network Table

| Network | Chain ID | RPC URL | Explorer | Symbol | Status |
|---|---|---|---|---|---|
| Pacific Mainnet | 1672 | `https://rpc.pharos.xyz` | https://www.pharosscan.xyz | PROS | Live |
| Atlantic Testnet v2 | 688689 | `https://atlantic.dplabs-internal.com` | https://atlantic.pharosscan.xyz | PHRS | Testnet |
| Atlantic Testnet v1 | 688688 | Deprecated | N/A | PHRS | Sunset |
| Devnet | Variable | Ask team | N/A | PHRS | Internal |

### Chain ID Quick Reference

```bash
# Verify chain ID
cast chain-id --rpc-url $RPC_URL

# Expected values
# Mainnet: 1672 (0x688)
# Testnet v2: 688689 (0xa8231)
```

## RPC Providers

| Provider | Type | URL | Notes |
|---|---|---|---|
| Default | Public | `https://rpc.pharos.xyz` (mainnet) / `https://atlantic.dplabs-internal.com` (testnet) | Rate-limited |
| ZAN | Partner | Ask team for endpoint | Higher rate limits |
| Alchemy | Partner | Ask team for endpoint | WebSocket support |
| Nirvana | Partner | Ask team for endpoint | Dedicated access |

## Explorer URLs

| Network | Explorer | Verification API |
|---|---|---|
| Mainnet | https://www.pharosscan.xyz | `https://www.pharosscan.xyz/api/contract/verify` |
| Testnet | https://atlantic.pharosscan.xyz | `https://atlantic.pharosscan.xyz/api/contract/verify` |

## Verification API Endpoints

### Foundry Verification
```bash
forge script script/Deploy.s.sol --rpc-url pharos-testnet --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

### Hardhat Verification
```bash
npx hardhat verify --network pharosTestnet <contract-address> <constructor-args>
```

### Manual Verification
Contracts can also be verified through the explorer UI at the Verification API endpoint above.

## Key Contract Addresses

| Contract | Address | Notes |
|---|---|---|
| Pharos Safe Master Copy | `0x41675C099F32341bf84BFc5382aF534df5C7461a` | Multi-sig wallet factory |
| Pharos Safe Proxy Factory | `0xa6B71E26C5cCB7B5A8cEa1E73cF9B7c8D0bC1a2b` | Creates new Safe instances |
| Pharlias (PROS) | Check docs.pharos.xyz | Native token contract |
| Pharos Bridge | Check docs.pharos.xyz | Native bridge contract |
| SPN Manager | Check docs.pharos.xyz | Manages SPN instances |
| SPN Mailbox | Check docs.pharos.xyz | Cross-SPN messaging |
| SPN Adapter | Check docs.pharos.xyz | Bridges main chain to SPN |

## Common RPC Methods

### eth_getAccount (Pharos-specific)
```
POST /rpc
{
  "jsonrpc": "2.0",
  "method": "eth_getAccount",
  "params": ["0x...", "latest"],
  "id": 1
}
```
Returns account balance, nonce, code hash, and storage root in a single call.

### Debug Methods
| Method | Description | Availability |
|---|---|---|
| `debug_traceTransaction` | Full transaction trace | Enabled |
| `debug_traceBlockByNumber` | Block trace | Enabled |
| `trace_filter` | Filtered trace (500 block limit) | Enabled |

### Standard Methods
| Method | Notes |
|---|---|
| `eth_getLogs` | Max 100 block range per request |
| `eth_getBlockByNumber` | Standard |
| `eth_call` | Standard |
| `eth_estimateGas` | Standard |
| `eth_gasPrice` | Returns EIP-1559 base fee + priority fee |
| `eth_maxPriorityFeePerGas` | Returns suggested priority fee |
| `eth_feeHistory` | Standard EIP-1559 fee history |
| `eth_subscribe` | WebSocket subscriptions available |

## RPC Rate Limits & Limitations

| Limit | Value | Notes |
|---|---|---|
| eth_getLogs block range | 100 blocks | Use pagination for larger ranges |
| trace_filter block range | 500 blocks | Combine with pagination |
| Rate limit (default RPC) | Burst: ~100 req/s, Sustained: ~30 req/s | Use ZAN/Alchemy for production |
| Maximum block range (eth_getLogs) | 100 blocks | Error returned if exceeded |

### Working with Rate Limits

```typescript
// Paginate eth_getLogs calls
const PAGE_SIZE = 100; // max blocks per request
const fromBlock = 1000n;
const toBlock = 2000n;

for (let i = fromBlock; i < toBlock; i += PAGE_SIZE) {
  const end = i + PAGE_SIZE > toBlock ? toBlock : i + PAGE_SIZE;
  const logs = await publicClient.getLogs({
    address: contractAddress,
    fromBlock: i,
    toBlock: end,
  });
  // process logs
}
```

## WebSocket Subscriptions

```typescript
import { createPublicClient, webSocket } from 'viem';

const client = createPublicClient({
  transport: webSocket('wss://rpc.pharos.xyz/ws'),
});

const unwatch = client.watchContractEvent({
  address: contractAddress,
  abi: contractABI,
  onLogs: (logs) => console.log(logs),
});
```

WebSocket endpoint: `wss://rpc.pharos.xyz/ws`

## Block Tags

| Tag | Behavior |
|---|---|
| `latest` | Most recent block |
| `earliest` | Genesis block |
| `pending` | Pending block (transactions not yet mined) |
| `safe` | Block confirmed by Pharos consensus |
| `finalized` | Irreversible block |

## Tokenomics Summary

| Parameter | Value |
|---|---|
| Token symbol | PROS (mainnet) / PHRS (testnet) |
| Decimals | 18 |
| Total supply | 1,000,000,000 PROS |
| Staking rewards | Distributed to validators and SPN operators |
| Staking lock period | Configurable per validator |
| Inflation rate | See Pharos docs for current rate |
| Gas fee burn | Base fee burned (EIP-1559), priority fee to validators |
| Vesting | Team (3-year linear), Investors (2-year cliff + 2-year linear), Ecosystem (5-year) |

### PROS Supply Distribution

| Category | Allocation | Vesting |
|---|---|---|
| Ecosystem Fund | 40% | 5-year linear |
| Team & Advisors | 15% | 3-year linear |
| Investors | 20% | 2-year cliff + 2-year linear |
| Community & Airdrops | 15% | 2-year linear |
| Foundation Reserve | 10% | Strategic use |

## Governance Model

Pharos uses a two-tier governance model:

### Tier 1: On-Chain Governance (Protocol Parameters)
- Validator set management
- Protocol fee parameters
- SPN registration and parameters
- Voting power proportional to PROS staked
- Quorum: 10% of total stake
- Pass threshold: 60% of votes cast
- Voting period: 7 days

### Tier 2: Community Governance (Ecosystem Decisions)
- Ecosystem fund allocation
- Technical roadmap priorities
- Community grants
- Off-chain signaling via Commonwealth/Snapshot
- Voting power: PROS staked or delegated

### Key Governance Contracts

| Contract | Address | Purpose |
|---|---|---|
| Governance | Check docs.pharos.xyz | Proposal creation and voting |
| Timelock | Check docs.pharos.xyz | Delays execution of passed proposals |
| Treasury | Check docs.pharos.xyz | Ecosystem fund management |

## FAQ

**Q: What are the RPC rate limits?**
A: Default RPC: ~30 req/s sustained, ~100 req/s burst. eth_getLogs limited to 100 block range. trace_filter limited to 500 blocks. Use ZAN/Alchemy for production workloads.

**Q: Does Pharos support WebSocket subscriptions?**
A: Yes. WebSocket endpoint: `wss://rpc.pharos.xyz/ws`. Supports eth_subscribe for newHeads, logs, and newPendingTransactions.

**Q: What block tags are available?**
A: latest, earliest, pending, safe, finalized. safe and finalized are recommended for production reads that need finality.

**Q: What is the PROS total supply and distribution?**
A: 1 billion PROS. 40% ecosystem, 20% investors, 15% team, 15% community, 10% foundation reserve.

**Q: How does Pharos governance work?**
A: Two-tier: on-chain governance for protocol parameters (PROS staked voting, 7-day voting period), community governance for ecosystem decisions (off-chain signaling).

**Q: Where are the latest Pharos docs?**
A: Official docs at https://docs.pharos.xyz. GitHub at https://github.com/PharosNetwork. Discord at https://discord.com/invite/pharos.

## References

- Official Docs: https://docs.pharos.xyz
- PharosScan (Mainnet): https://www.pharosscan.xyz
- PharosScan (Testnet): https://atlantic.pharosscan.xyz
- Testnet Faucet: https://testnet.pharosnetwork.xyz
- GitHub: https://github.com/PharosNetwork
- Discord: https://discord.com/invite/pharos
- RPC Providers: https://docs.pharos.xyz/tooling-and-infrastructure/rpc
