import { type Chain } from 'viem';

export const pharosTestnet: Chain = {
  id: 688_689,
  name: 'Pharos Atlantic Testnet',
  nativeCurrency: { name: 'Pharos Testnet', symbol: 'PHRS', decimals: 18 },
  rpcUrls: {
    default: { http: ['https://atlantic.dplabs-internal.com'] },
  },
  blockExplorers: {
    default: { name: 'PharosScan', url: 'https://atlantic.pharosscan.xyz' },
  },
  testnet: true,
};

export const pharosMainnet: Chain = {
  id: 1_672,
  name: 'Pharos Pacific',
  nativeCurrency: { name: 'Pharos', symbol: 'PROS', decimals: 18 },
  rpcUrls: {
    default: { http: ['https://rpc.pharos.xyz'] },
  },
  blockExplorers: {
    default: { name: 'PharosScan', url: 'https://www.pharosscan.xyz' },
  },
  testnet: false,
};
