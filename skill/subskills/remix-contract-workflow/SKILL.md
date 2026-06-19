# Remix Contract Workflow

## Overview

Use the Remix IDE (browser-based Solidity IDE) to quickly prototype, deploy, and test Pharos smart contracts. This subskill covers the end-to-end workflow from writing a contract in the browser to verifying it on PharosScan.

**When to use:** Rapid prototyping, quick iteration, educational demos
**When NOT to use:** Production deployments (use `deployment-and-verification` with Foundry/Hardhat)

## Prerequisites

1. MetaMask configured for Pharos networks (see below)
2. Browser open to [remix.ethereum.org](https://remix.ethereum.org)
3. `.env` file with `PRIVATE_KEY` and `PHAROSSCAN_API_KEY` (for verification)

## 7-Step Remix Workflow

### Step 1: Write or Paste Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PharosCounter {
    uint256 public count;
    address public owner;

    event CountIncremented(uint256 newCount);

    constructor() {
        owner = msg.sender;
    }

    function increment() external {
        count++;
        emit CountIncremented(count);
    }

    function reset() external {
        require(msg.sender == owner, "Not owner");
        count = 0;
    }
}
```

### Step 2: Compile

- Select Solidity compiler version `0.8.20+` in Remix's Solidity tab
- Enable "Auto compile" and "Optimization" (200 runs for deployment cost savings)
- Check for compiler warnings — fix all before deploying

### Step 3: Configure MetaMask for Pharos

```json
{
  "Pharos Atlantic Testnet": {
    "rpcUrl": "https://atlantic.dplabs-internal.com",
    "chainId": "0xa81d1",
    "chainIdDecimal": 688689,
    "currency": "PHRS",
    "explorer": "https://atlantic.pharosscan.xyz"
  },
  "Pharos Pacific Mainnet": {
    "rpcUrl": "https://pacific.dplabs-internal.com",
    "chainId": "0x688",
    "chainIdDecimal": 1672,
    "currency": "PHRS",
    "explorer": "https://pharosscan.xyz"
  }
}
```

**MetaMask setup:** Settings → Networks → Add Network → Input the above parameters manually or via chainlist.

### Step 4: Deploy

1. In Remix's Deploy tab, select "Injected Provider — MetaMask"
2. Ensure MetaMask is on the correct Pharos network
3. Set gas if needed (Pharos typically uses lower gas than Ethereum, start with 1-2 gwei)
4. Click "Deploy" and confirm the MetaMask transaction
5. Copy the deployed contract address from Remix's output panel

### Step 5: Deploy via Script (Advanced)

```javascript
// Copy this into Remix's "Deploy & Run" tab script area
(async () => {
  const abi = [
    "function count() view returns (uint256)",
    "function increment()",
    "function reset()"
  ];
  const counter = new web3.eth.Contract(abi, "YOUR_DEPLOYED_ADDRESS");
  
  // Read
  const count = await counter.methods.count().call();
  console.log("Current count:", count);
  
  // Write
  await counter.methods.increment().send({ from: accounts[0] });
  console.log("Incremented!");
})();
```

### Step 6: Verify on PharosScan

```bash
# Using Foundry cast (preferred)
cast verify-contract \
  --rpc-url https://atlantic.dplabs-internal.com \
  --chain 688689 \
  --etherscan-api-key $PHAROSSCAN_API_KEY \
  --verifier-url https://atlantic.pharosscan.xyz/api \
  CONTRACT_ADDRESS \
  contracts/PharosCounter.sol:PharosCounter

# For constructors with arguments, add --constructor-args
# $(cast abi-encode "constructor(uint256)" 42)
```

### Step 7: Interact

Use Remix's built-in contract interaction panel to:
- Call read functions (no gas cost)
- Send write transactions (MetaMask will prompt)
- View event logs in Remix's console

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| "Gas estimation failed" | Wrong chain ID or insufficient gas | Check MetaMask network, set gas manually |
| "nonce too low" | Pending transaction stuck | Clear MetaMask activity, reset nonce |
| "chainId mismatch" | MetaMask on wrong network | Switch to Atlantic (688689) or Pacific (1672) |
| "execution reverted" | Contract logic error | Debug with Remix's debugger or Hardhat console |
| "insufficient funds" | Wallet has < 0.1 PHRS | Fund wallet from faucet or bridge |

## Network Details

| Network | RPC URL | Chain ID | Explorer |
|---------|---------|----------|----------|
| Atlantic Testnet | `https://atlantic.dplabs-internal.com` | 688689 | `https://atlantic.pharosscan.xyz` |
| Pacific Mainnet | `https://pacific.dplabs-internal.com` | 1672 | `https://pharosscan.xyz` |

## Security Rules

- NEVER expose `PRIVATE_KEY` in Remix's JavaScript environment
- Use `.env` for local scripts; `grep -q` to verify, never `cat` or `echo`
- Always verify contracts on PharosScan after deployment
- Test on Atlantic first — mainnet deployments require explicit user approval
- Use `test -f .env && grep -q "PRIVATE_KEY" .env` before any deployment script

## Related Subskills

- `foundry-hardhat-contract-workflow` — For local development and CI
- `deployment-and-verification` — For production-grade deployments
- `contract-testing-for-testnet-and-mainnet` — Testing contracts before deploying
