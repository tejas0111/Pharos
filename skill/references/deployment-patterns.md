# Pharos Deployment Patterns Reference

Comprehensive deployment workflow reference for Pharos: Foundry, Hardhat, Hardhat Ignition, multi-sig, upgrades, cross-chain, and CI/CD.

## Foundry Deployment Workflow

### Prerequisites
```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Set environment variables
export PHAROS_TESTNET_RPC_URL=https://atlantic.dplabs-internal.com
export PHAROS_MAINNET_RPC_URL=https://rpc.pharos.xyz
export PRIVATE_KEY=0x...
export ETHERSCAN_API_KEY=...
```

### Deploy Script Template
```solidity
// script/DeployToken.s.sol
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "../contracts/Token.sol";

contract DeployTokenScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        vm.startBroadcast(deployerPrivateKey);
        
        Token token = new Token(
            vm.envString("TOKEN_NAME"),
            vm.envString("TOKEN_SYMBOL"),
            vm.envUint("INITIAL_SUPPLY")
        );
        
        vm.stopBroadcast();
        
        console.log("Token deployed at:", address(token));
        console.log("Deployer:", deployer);
    }
}
```

### Deploy Commands
```bash
# Simulate (dry run)
forge script script/DeployToken.s.sol --rpc-url pharos-testnet

# Deploy to testnet
forge script script/DeployToken.s.sol --rpc-url pharos-testnet --broadcast

# Deploy + verify on testnet
forge script script/DeployToken.s.sol --rpc-url pharos-testnet --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY

# Deploy to mainnet (use --slow to wait for confirmations)
forge script script/DeployToken.s.sol --rpc-url pharos-mainnet --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY --slow
```

### Deployment Manager Script
For more complex deployments, use a manager script pattern:

```solidity
// script/DeployManager.s.sol
pragma solidity ^0.8.26;

import "forge-std/Script.sol";

contract DeployManagerScript is Script {
    struct DeployedContracts {
        address token;
        address vault;
        address staking;
    }
    
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);
        
        DeployedContracts memory contracts;
        contracts.token = address(new Token("Pharos Token", "PHT", 1_000_000_000e18));
        contracts.vault = address(new Vault(contracts.token));
        contracts.staking = address(new Staking(contracts.token));
        
        vm.stopBroadcast();
        
        // Save deployment artifacts
        string memory json = _serialize(contracts);
        vm.writeJson(json, "./deployments/latest.json");
    }
    
    function _serialize(DeployedContracts memory c) internal pure returns (string memory) {
        return string.concat(
            '{"token":"', vm.toString(c.token),
            '","vault":"', vm.toString(c.vault),
            '","staking":"', vm.toString(c.staking), '"}'
        );
    }
}
```

## Hardhat Deployment Workflow

### Prerequisites
```bash
# Install Hardhat
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox

# Set environment variables (same as Foundry)
```

### Deploy Script Template
```typescript
// scripts/deploy-token.ts
import { ethers } from 'hardhat';

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log('Deploying with:', deployer.address);

  const name = process.env.TOKEN_NAME || 'Pharos Token';
  const symbol = process.env.TOKEN_SYMBOL || 'PHT';
  const initialSupply = ethers.parseEther(process.env.INITIAL_SUPPLY || '1000000');

  const Token = await ethers.getContractFactory('Token');
  const token = await Token.deploy(name, symbol, initialSupply);
  await token.waitForDeployment();

  const address = await token.getAddress();
  console.log('Token deployed to:', address);

  // Verify after deploy
  if (process.env.VERIFY === '1') {
    await hre.run('verify:verify', {
      address,
      constructorArguments: [name, symbol, initialSupply],
    });
  }
}

main().catch(console.error);
```

### Deploy Commands
```bash
# Deploy to testnet
npx hardhat run scripts/deploy-token.ts --network pharosTestnet

# Deploy to mainnet
npx hardhat run scripts/deploy-token.ts --network pharosMainnet

# Verify on explorer
npx hardhat verify --network pharosTestnet <contract-address> <constructor-args>
```

## Hardhat Ignition Deployment

Hardhat Ignition is a declarative deployment system for Hardhat.

### Ignition Module Template
```typescript
// ignition/modules/Token.ts
import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';

const TokenModule = buildModule('TokenModule', (m) => {
  const name = m.getParameter('name', 'Pharos Token');
  const symbol = m.getParameter('symbol', 'PHT');
  const initialSupply = m.getParameter('initialSupply', 1_000_000_000_000_000_000_000_000n);

  const token = m.contract('Token', [name, symbol, initialSupply]);

  return { token };
});

export default TokenModule;
```

### Ignition Commands
```bash
# Deploy
npx hardhat ignition deploy ignition/modules/Token.ts --network pharosTestnet

# Deploy with parameters
npx hardhat ignition deploy ignition/modules/Token.ts --network pharosTestnet --parameters '{"TokenModule":{"name":"MyToken","symbol":"MYT","initialSupply":1000000000000000000000000}}'

# Verify
npx hardhat ignition deploy ignition/modules/Token.ts --network pharosTestnet --verify
```

## Multi-Sig Deployment Flow

### Step 1: Create Safe (if not exists)
```bash
# Using Safe CLI
safe create --network pharosTestnet --owners <addr1>,<addr2>,<addr3> --threshold 2
```

### Step 2: Prepare Deployment Transaction
```bash
# Forge: generate deploy data without broadcasting
forge script script/DeployToken.s.sol --rpc-url pharos-mainnet --sig "run()" --json > deploy-data.json

# Extract the raw transaction data
cast calldata --offline $(cat deploy-data.json | jq -r '.transactions[0].data')
```

### Step 3: Submit to Safe
```bash
# Using Safe API or Safe CLI
safe propose --network pharosMainnet --safe <safe-address> \
  --to <deployer-address> --data <calldata> --value 0
```

### Step 4: Collect Signatures
Threshold signers approve via Safe UI or CLI.

### Step 5: Execute
```bash
safe execute --network pharosMainnet --safe <safe-address> <tx-hash>
```

## Upgrade Deployment Flow

### UUPS Upgrade (Foundry)
```bash
# Deploy proxy + implementation v1
forge script script/DeployUpgradeable.s.sol --rpc-url pharos-testnet --broadcast

# Deploy implementation v2
forge script script/DeployV2.s.sol --rpc-url pharos-testnet --broadcast

# Upgrade proxy to v2 (requires owner)
cast send --rpc-url $RPC_URL --private-key $PK <proxy-address> \
  "upgradeTo(address)" <v2-address>
```

### UUPS Upgrade (Hardhat)
```typescript
// scripts/upgrade-v2.ts
import { ethers, upgrades } from 'hardhat';

async function main() {
  const V2 = await ethers.getContractFactory('TokenV2');
  const proxy = process.env.PROXY_ADDRESS!;
  
  const upgraded = await upgrades.upgradeProxy(proxy, V2);
  await upgraded.waitForDeployment();
  
  console.log('Upgraded to v2 at:', proxy);
}
```

### Transparent Proxy (Hardhat)
```typescript
// scripts/deploy-proxy.ts
import { ethers, upgrades } from 'hardhat';

async function main() {
  const Token = await ethers.getContractFactory('Token');
  const token = await upgrades.deployProxy(Token, [name, symbol, supply], {
    kind: 'transparent',
  });
  await token.waitForDeployment();
  console.log('Proxy deployed at:', await token.getAddress());
}
```

### Beacon Proxy (Hardhat)
```typescript
// scripts/deploy-beacon.ts
import { ethers, upgrades } from 'hardhat';

async function main() {
  const Token = await ethers.getContractFactory('Token');
  const beacon = await upgrades.deployBeacon(Token);
  await beacon.waitForDeployment();

  const token = await upgrades.deployBeaconProxy(beacon, Token, [name, symbol, supply]);
  await token.waitForDeployment();
  
  console.log('Beacon proxy deployed at:', await token.getAddress());
}
```

## Cross-Chain Deployment Flow

### LayerZero OFT
```bash
# Deploy OFT on source chain (Pharos)
forge script script/DeployOFT.s.sol --rpc-url pharos-testnet --broadcast

# Set trusted remote on source
cast send --rpc-url $RPC_URL --private-key $PK <oft-address> \
  "setTrustedRemoteAddress(uint16,bytes)" <dst-chain-id> <dst-oft-address>

# Deploy OFT on destination chain (e.g., Sepolia)
forge script script/DeployOFT.s.sol --rpc-url sepolia --broadcast

# Set trusted remote on destination
cast send --rpc-url sepolia-rpc --private-key $PK <oft-address> \
  "setTrustedRemoteAddress(uint16,bytes)" <src-chain-id> <src-oft-address>
```

### CCTP (Circle)
```bash
# Deploy token messenger on Pharos
forge script script/DeployCCTP.s.sol --rpc-url pharos-testnet --broadcast

# Register Pharos domain with Circle
# Use Circle's CCTP API to register the domain

# Deposit and mint flow
# 1. Burn USDC on source
# 2. Relay message to destination
# 3. Mint USDC on destination via attestation
```

## CI/CD Pipeline Template

See `.github/workflows/deploy.yml` for the GitHub Actions pipeline template.

### Environment Variables Required
```bash
# Copy from .env.example
PHAROS_TESTNET_RPC_URL=https://atlantic.dplabs-internal.com
PHAROS_MAINNET_RPC_URL=https://rpc.pharos.xyz
PRIVATE_KEY=0x...  # CI secret
ETHERSCAN_API_KEY=...  # CI secret
```

### Pipeline Stages
1. **Lint**: Run solhint, prettier, TypeScript checks
2. **Test**: Run forge tests (unit + integration) and Hardhat tests
3. **Deploy to Testnet**: Simulate only (no broadcast in CI unless manually triggered)
4. **Deploy to Mainnet**: Manual approval required, simulate first, then broadcast
5. **Post-Deploy**: Verify, capture artifacts, notify team

### Artifacts
Deployment receipts are saved as build artifacts:
```json
{
  "network": "pharos-testnet",
  "contract": "Token",
  "address": "0x...",
  "txHash": "0x...",
  "blockNumber": 1234567,
  "timestamp": "2026-01-01T00:00:00Z",
  "verificationStatus": "verified"
}
```

## Related References

- `pharos-ecosystem.md` — network table, RPC providers, explorer URLs
- `skill/subskills/cross-chain-bridge/SKILL.md` — LayerZero, CCTP, SPN Mailbox
- `skill/subskills/upgrade-patterns/SKILL.md` — UUPS, Transparent, Beacon proxy
- `skill/subskills/deployment-and-verification/SKILL.md` — deploy prep in dev suite
- `skill/subskills/post-deploy/SKILL.md` — post-deployment operations
