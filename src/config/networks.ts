import type { NetworkConfig, SkillLane, SupportedNetwork } from "../types";

const NETWORKS: Record<SupportedNetwork, NetworkConfig> = {
  "pharos-mainnet": {
    key: "pharos-mainnet",
    chainId: 688688,
    rpcUrlEnvVar: "PHAROS_MAINNET_RPC_URL",
    explorerBaseUrl: "https://pharosscan.xyz",
  },
  "pharos-testnet": {
    key: "pharos-testnet",
    chainId: 50002,
    rpcUrlEnvVar: "PHAROS_TESTNET_RPC_URL",
    explorerBaseUrl: "https://testnet.pharosscan.xyz",
  },
};

const LANE_ALIASES: Record<string, SkillLane> = {
  investor: "investor",
  wallet: "investor",
  developer: "developer",
  dev: "developer",
  defi: "defi",
  "defi power user": "defi",
};

export function getNetworkConfig(network: SupportedNetwork): NetworkConfig {
  return NETWORKS[network];
}

export function normalizeLane(raw: string): SkillLane {
  const normalized = raw.trim().toLowerCase();
  return LANE_ALIASES[normalized] ?? "investor";
}
