# Testnet Deployment

## Overview

Deploy and verify contracts on Pharos Atlantic Testnet (chain ID 688689). Every deployment must follow the security gate → simulate → broadcast → verify workflow.

## Network Details

| Parameter | Value |
|-----------|-------|
| Network | Pharos Atlantic Testnet |
| Chain ID | 688689 |
| Currency | PHRS |
| RPC | `https://atlantic.dplabs-internal.com` |
| Explorer | https://atlantic.pharosscan.xyz |
| Faucet | https://testnet.pharosnetwork.xyz |
| EntryPoint (v0.7) | `0x0000000071727De22E5E9d8BAf0edAc6f37da032` |

## Deploy Scripts

All deploy scripts are in `script/` and follow the Foundry `Script` pattern:

```solidity
// script/DeployPharosLendingPool.s.sol
contract DeployPharosLendingPool is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        PharosLendingPool pool = new PharosLendingPool(
            1_000_000e18,  // maxCapacity
            1000,           // reserveFactor
            15000,          // collateralRatio
            7500,           // maxLTV
            1000            // liquidationBonus
        );
        vm.stopBroadcast();
        console.log("LendingPool deployed at:", address(pool));
    }
}
```

### Deployable Contracts

| Contract | Script | Atlantic Address |
|----------|--------|-----------------|
| Counter | `Deploy.s.sol` | `0x55ec...8e4e` |
| Storage | `DeployStorage.s.sol` | `0x2527...34f0` |
| PharosERC20 | `DeployERC20.s.sol` | `0x3636...4CD` |
| PharosLendingPool | `DeployLendingPool.s.sol` | — |
| DEXPool | `DeployDEXPool.s.sol` | — |
| StakingPool | `DeployStakingPool.s.sol` | — |
| PharosRWAToken | `DeployRWAToken.s.sol` | — |
| CrossChainMessage | `DeployCrossChain.s.sol` | — |
| PharosSPNPaymaster | `DeploySPNPaymaster.s.sol` | — |
| PharosZkLogin | `DeployZkLogin.s.sol` | — |

> **To deploy:** `forge script script/<SCRIPT> --rpc-url https://atlantic.dplabs-internal.com --broadcast -vvvv`

## Deployment Workflow

### 1. Pre-flight
```bash
export PRIVATE_KEY=0x...
# Verify env is set (never print it!)
test -n "$PRIVATE_KEY" || { echo "PRIVATE_KEY not set"; exit 1; }

# Check balance
cast balance --rpc-url https://atlantic.dplabs-internal.com $(cast wallet address --private-key $PRIVATE_KEY)
```

### 2. Simulate
```bash
forge script script/DeployLendingPool.s.sol \
    --rpc-url https://atlantic.dplabs-internal.com \
    -vvvv
```

### 3. Broadcast
```bash
forge script script/DeployLendingPool.s.sol \
    --rpc-url https://atlantic.dplabs-internal.com \
    --broadcast \
    --slow \
    -vvvv
```

### 4. Verify
```bash
forge verify-contract <CONTRACT_ADDRESS> \
    contracts/PharosLendingPool.sol:PharosLendingPool \
    --chain 688689 \
    --verifier-url https://atlantic.pharosscan.xyz/api/ \
    --verifier blockscout
```

## Security Gates

1. **Slither check** (optional): `pip install slither-analyzer` then `slither contracts/PharosLendingPool.sol --json -`
2. **Gas spike check**: Monitor network gas >200 Gwei, avoid broadcasting during spikes
3. **.env security**: Never commit `.env`, never print `$PRIVATE_KEY`
4. **Simulation first**: Always simulate before broadcast

## Post-Deployment

```bash
# Verify on PharosScan
open https://atlantic.pharosscan.xyz/address/<CONTRACT_ADDRESS>

# Fund contract (if needed)
cast send --private-key $PRIVATE_KEY <CONTRACT_ADDRESS> --value 1ether

# Register in DEPLOYMENTS.md
echo "| ContractName | $(date +%Y-%m-%d) | <ADDRESS> | Atlantic |" >> DEPLOYMENTS.md
```

## MCP Tools

- `pharos_deploy_contract` — Deploy via MCP
- `pharos_verify_contract` — Auto-verify
- `pharos_check_balance` — Check deployer balance
- `pharos_contract_info` — Get contract details
- `pharos_run_security_check` — Run Slither gate

## References

- `script/` — All deploy scripts
- `DEPLOYMENTS.md` — Deployment records
- `contracts/` — All deployable contracts
- MCP tool: `pharos_deploy_contract`
