import { defineChain } from "viem";

export const pharosMainnet = defineChain({
  id: 1672,
  name: "Pharos Mainnet",
  nativeCurrency: { name: "PROS", symbol: "PROS", decimals: 18 },
  rpcUrls: {
    default: {
      http: [
        "https://rpc.pharos.xyz",
        "https://infra.orginstake.com/pharos/evm",
      ],
    },
  },
  blockExplorers: {
    default: {
      name: "PharosScan",
      url: "https://www.pharosscan.xyz",
    },
  },
});

export const pharosTestnet = defineChain({
  id: 688689,
  name: "Pharos Atlantic Testnet",
  nativeCurrency: { name: "PHRS", symbol: "PHRS", decimals: 18 },
  rpcUrls: {
    default: {
      http: ["https://atlantic.dplabs-internal.com"],
    },
  },
  blockExplorers: {
    default: {
      name: "PharosScan",
      url: "https://atlantic.pharosscan.xyz",
    },
  },
  testnet: true,
});
