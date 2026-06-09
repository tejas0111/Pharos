import { type HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';

const PHAROS_TESTNET_RPC = process.env.PHAROS_TESTNET_RPC_URL || 'https://atlantic.dplabs-internal.com';
const PHAROS_MAINNET_RPC = process.env.PHAROS_MAINNET_RPC_URL || 'https://rpc.pharos.xyz';
const PRIVATE_KEY = process.env.PRIVATE_KEY || '';
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || '';

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.26',
    settings: {
      optimizer: { enabled: true, runs: 200 },
      evmVersion: 'cancun',
    },
  },
  networks: {
    pharosTestnet: {
      url: PHAROS_TESTNET_RPC,
      chainId: 688_689,
      accounts: [PRIVATE_KEY],
    },
    pharosMainnet: {
      url: PHAROS_MAINNET_RPC,
      chainId: 1_672,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      pharosTestnet: ETHERSCAN_API_KEY,
      pharosMainnet: ETHERSCAN_API_KEY,
    },
    customChains: [
      {
        network: 'pharosTestnet',
        chainId: 688_689,
        urls: {
          apiURL: 'https://atlantic.pharosscan.xyz/api',
          browserURL: 'https://atlantic.pharosscan.xyz',
        },
      },
      {
        network: 'pharosMainnet',
        chainId: 1_672,
        urls: {
          apiURL: 'https://www.pharosscan.xyz/api',
          browserURL: 'https://www.pharosscan.xyz',
        },
      },
    ],
  },
};

export default config;
