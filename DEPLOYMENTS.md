# Deployments — Pharos Agent Dev Suite

## Atlantic Testnet (Chain ID: 688689)

### Deployed Contracts

| Contract | Address | Explorer |
|----------|---------|----------|
| Counter | `0x55ec4b1e32537b6f72aa20153735709837488e4e` | [View](https://testnet.pharosscan.com/address/0x55ec4b1e32537b6f72aa20153735709837488e4e) |
| Storage | `0x2527FDc8C6FdF7C5239f005D94Cc7dC6173d34f0` | [View](https://testnet.pharosscan.com/address/0x2527FDc8C6FdF7C5239f005D94Cc7dC6173d34f0) |
| PharosERC20 | `0x20c27Cc36eD5a610dFe10AAcA0000C86d7A1DDd4` | [View](https://testnet.pharosscan.com/address/0x20c27Cc36eD5a610dFe10AAcA0000C86d7A1DDd4) |
| PharosSPNPaymaster | `0x21bf4bc635b277e630cb40db95b88a28a27d7ff9` | [View](https://testnet.pharosscan.com/address/0x21bf4bc635b277e630cb40db95b88a28a27d7ff9) |
| PharosZkLogin | `0x004dc049a2457a07bc8f325e1379aef6e0282b16` | [View](https://testnet.pharosscan.com/address/0x004dc049a2457a07bc8f325e1379aef6e0282b16) |
| PharosLendingPool | `0xb3a85264cff0e1f7346fda8b73d924af4dd5b912` | [View](https://testnet.pharosscan.com/address/0xb3a85264cff0e1f7346fda8b73d924af4dd5b912) |

### Ready to Deploy (need env vars)

| Contract | Required Env Vars | Deploy Script |
|----------|------------------|---------------|
| DEXPool | `TOKEN_A`, `TOKEN_B` | `DeployDEXPool.s.sol` |
| StakingPool | `STAKING_TOKEN`, `REWARD_TOKEN` | `DeployStakingPool.s.sol` |
| CrossChainMessage | `TRUSTED_PEER` | `DeployCrossChain.s.sol` |
| RWAToken | — | `DeployRWAToken.s.sol` |

## Pacific Mainnet (Chain ID: 1672)

No deployments yet. All contracts are tested on Atlantic Testnet and ready for mainnet deployment with the deploy scripts in `script/`.

## Deployer Address

All contracts deployed by: `0x735367687d6a701466840321eD8e34E4DafE84aC`
