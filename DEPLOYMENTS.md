# Pharos Deployments

## Atlantic Testnet (Chain ID: 688689)

| Contract | Address | Tx Hash | Explorer |
|----------|---------|---------|----------|
| **Counter** | `0x55ec4b1e32537b6f72aa20153735709837488e4e` | `0x0f1891dee4bd6fa7901ef287e0bef044f10bff1d445a5645ea15da723085e411` | [View](https://atlantic.pharosscan.xyz/address/0x55ec4b1e32537b6f72aa20153735709837488e4e) |
| **Storage** | `0x2527FDc8C6FdF7C5239f005D94Cc7dC6173d34f0` | `0xed4bd34a99282782e9e6b9670ac8703148560c34fc695896aeb6b36458b94001` | [View](https://atlantic.pharosscan.xyz/address/0x2527FDc8C6FdF7C5239f005D94Cc7dC6173d34f0) |
| **PharosERC20** | `0x3636F1BBcc56D1b5a22F8B778494D1553d95B4CD` | `0xcdf144d1f2ca398ece1a8b718c690347d673e5121479318fcc0d23d3523844ec` | [View](https://atlantic.pharosscan.xyz/address/0x3636F1BBcc56D1b5a22F8B778494D1553d95B4CD) |

### Deployer

`0x735367687d6a701466840321eD8e34E4DafE84aC`

### Verification

| Contract | Status |
|----------|--------|
| **Counter** | 🔍 Pending — requires `PHAROSSCAN_API_KEY` or manual submission via explorer UI |
| **Storage** | 🔍 Pending — requires `PHAROSSCAN_API_KEY` or manual submission via explorer UI |
| **PharosERC20** | 🔍 Pending — requires `PHAROSSCAN_API_KEY` or manual submission via explorer UI |

To verify via CLI:
```bash
export PHAROSSCAN_API_KEY=your_key_here
forge verify-contract --chain-id 688689 --verifier-url https://atlantic.pharosscan.xyz/api --etherscan-api-key $PHAROSSCAN_API_KEY <ADDRESS> <CONTRACT_PATH> --num-of-optimizations 200
```

### Explorer Links

- **Counter**: https://atlantic.pharosscan.xyz/address/0x55ec4b1e32537b6f72aa20153735709837488e4e
  - Tx: https://atlantic.pharosscan.xyz/tx/0x0f1891dee4bd6fa7901ef287e0bef044f10bff1d445a5645ea15da723085e411
- **Storage**: https://atlantic.pharosscan.xyz/address/0x2527FDc8C6FdF7C5239f005D94Cc7dC6173d34f0
  - Tx: https://atlantic.pharosscan.xyz/tx/0xed4bd34a99282782e9e6b9670ac8703148560c34fc695896aeb6b36458b94001
- **PharosERC20**: https://atlantic.pharosscan.xyz/address/0x3636F1BBcc56D1b5a22F8B778494D1553d95B4CD
  - Tx: https://atlantic.pharosscan.xyz/tx/0xcdf144d1f2ca398ece1a8b718c690347d673e5121479318fcc0d23d3523844ec

---

## Pacific Mainnet (Chain ID: 1672)

*No deployments yet.*
